import os
import click
import yaml
import json
import subprocess
from jinja2 import Template
from dataclasses import dataclass, field
from dataclasses_jsonschema import JsonSchemaMixin
from dataclasses_json import dataclass_json
from dacite import from_dict
from typing import Optional, Set, List, Union, Dict, Any
import shutil
from shutil import copy, copymode
import logging


# Primitive Types
TaxonomyId = str ## CCNxxxx
Person = str ## ORCID or github handle


@dataclass_json
@dataclass
class TaxonomyProject(JsonSchemaMixin):
    """
    A configuration for a taxonomy project/repository.
    """

    id: TaxonomyId = ""
    """Id for this taxonomy."""

    title: str = ""
    """Concise descriptive text about this taxonomy"""

    git_user: str = ""
    """GIT user name (necessary for generating releases)"""

    repo: str = ""
    """Name of repo (do not include org). E.g. mouse-mtg-taxonomy"""

    github_org: str = ""
    """Name of github org or username where repo will live. Examples: brain-bican, hkir-dev"""

    git_main_branch: str = "main"
    """The main branch for your repo, such as main, or (now discouraged) master."""

    license: str = "https://creativecommons.org/licenses/unspecified"
    """Which license is taxonomy supplied under - must be an IRI."""

    export_project_yaml: bool = False
    """Flag to set if you want a full project.yaml to be exported, including all the default options."""

    description: str = "None"
    """Provide a short description of the taxonomy"""

    contact: Optional[Person] = None
    """Single contact for taxonomy as required by BICAN"""


@dataclass
class ExecutionContext(JsonSchemaMixin):
    """
    Top level object that is passed to Jinja2 templates
    """
    project: Optional[TaxonomyProject] = None
    meta: str = ""


@dataclass
class Generator(object):
    """
    Utility class for generating a variety of taxonomy project artefacts
    from jinja2 templates
    """

    ## TODO: consider merging Generator and ExecutionContext?
    context: ExecutionContext = ExecutionContext()

    def generate(self, input: str) -> str:
        """
        Given a path to an input template, renders the template
        using the current execution context
        """
        with open(input) as file_:
            template = Template(file_.read())
            if "ODK_VERSION" in os.environ:
                return template.render(project=self.context.project, env={"ODK_VERSION": os.getenv("ODK_VERSION")})
            else:
                return template.render(project=self.context.project)

    def load_config(self,
                    config_file: Optional[str] = None,
                    title: Optional[str] = None,
                    org: Optional[str] = None,
                    repo: Optional[str] = None):
        """
        Parses a project.yaml file and uses the contents to
        set the current execution context.
        Optionally injects additional values
        """
        if config_file is None:
            project = TaxonomyProject()
        else:
            with open(config_file, 'r') as stream:
                try:
                    obj = yaml.load(stream, Loader=yaml.FullLoader)
                except yaml.YAMLError as exc:
                    print(exc)
            project = from_dict(data_class=TaxonomyProject, data=obj)
        if title:
            project.title = title
        if org:
            project.github_org = org
        if repo:
            project.repo = repo
        self.context = ExecutionContext(project=project)


def save_project_yaml(project: TaxonomyProject, path: str):
    """
    Saves a taxonomy project to a file in YAML format
    """
    # This is a slightly ridiculous bit of tomfoolery, but necessary
    # As PyYAML will attempt to save as a python object using !!,
    # so we must first serialize as JSON then parse than JSON to get
    # a class-free python dict tha can be safely saved
    json_str = project.to_json()
    json_obj = json.loads(json_str)
    with open(path, "w") as f:
        f.write(yaml.dump(json_obj, default_flow_style=False))


## ========================================
## Command Line Wrapper
## ========================================
## this could potentially be moved to a separate file
## somewhat convenient to lump for now


@click.group()
def cli():
    pass


@cli.command()
@click.option('-C', '--config',       type=click.Path(exists=True),
              help="""
              path to a YAML configuration.
              See examples folder for examples.
              This is optional, configuration can also be passed
              by command line, but an explicit config file is preferred.
              """)
@click.option('-c', '--clean/--no-clean', default=False)
@click.option('-D', '--outdir',       default=None)
@click.option('-t', '--title',        type=str)
@click.option('-u', '--user',         type=str)
@click.option('-v', '--verbose',      count=True)
@click.option('-g', '--skipgit',      default=False, is_flag=True)
@click.option('-n', '--gitname',      default=None)
@click.option('-e', '--gitemail',     default=None)
@click.argument('repo', nargs=-1)
def seed(config, clean, outdir, title, user, verbose, repo, skipgit, gitname, gitemail):
    """
    Seed the taxonomy project.
    """
    tgts = []
    mg = Generator()
    if len(repo) > 0:
        if len(repo) > 1:
            raise Exception('max one repo; current={}'.format(repo))
        repo = repo[0]
    else:
        repo = None
    mg.load_config(config,
                   title=title,
                   org=user,
                   repo=repo)
    project = mg.context.project
    if project.id is None or project.id == "":
        project.id = repo
    if outdir is None:
        outdir = "target/{}".format(project.repo)
    if clean:
        if os.path.exists(outdir):
            shutil.rmtree(outdir)
    if not os.path.exists(outdir):
        os.makedirs(outdir, exist_ok=True)
    tgt_project_file = "{}/project.yaml".format(outdir)
    if project.export_project_yaml:
        save_project_yaml(project, tgt_project_file)
        tgts.append(tgt_project_file)
    tdt_config_file = "{}/{}_project_config.yaml".format(outdir, project.id)
    tgts.append(tdt_config_file)
    if config is not None:
        copy(config, tdt_config_file)
    else:
        save_project_yaml(project, tdt_config_file)
    logging.info("Created files:")

    # create folder structure
    os.makedirs(outdir + "/input_data", exist_ok=True)
    os.makedirs(outdir + "/curation_tables", exist_ok=True)
    os.makedirs(outdir + "/purl", exist_ok=True)
    with open("{}/{}.json".format(outdir, project.id), "w") as f:
        f.write("{}")
    for tgt in tgts:
        logging.info("  File: {}".format(tgt))
    if not skipgit:
        if gitname is not None:
            os.environ['GIT_AUTHOR_NAME'] = gitname
            os.environ['GIT_COMMITTER_NAME'] = gitname
        if gitemail is not None:
            os.environ['GIT_AUTHOR_EMAIL'] = gitemail
            os.environ['GIT_COMMITTER_EMAIL'] = gitemail
        runcmd("cd {dir} && git init && git add {files}".
               format(dir=outdir,
                      files=" ".join([t.replace(outdir, ".", 1) for t in tgts])))
        # runcmd(
        #     "cd {dir}/src/ontology && make && git commit -m 'initial commit' -a && git branch -M {branch} && make prepare_initial_release && git commit -m 'first release'".format(
        #         dir=outdir, branch=project.git_main_branch))
        print("\n\n####\nNEXT STEPS:")
        print(" 0. Examine {} and check it meets your expectations. If not blow it away and start again".format(outdir))
        print(" 1. Go to: https://github.com/new")
        print(" 2. The owner MUST be {org}. The Repository name MUST be {repo}".format(org=project.github_org,
                                                                                       repo=project.repo))
        print(" 3. Do not initialize with a README (you already have one)")
        print(" 4. Click Create")
        print(" 5. See the section under '…or push an existing repository from the command line'")
        print("    E.g.:")
        print("cd {}".format(outdir))
        print(
            "git remote add origin git\@github.com:{org}/{repo}.git".format(org=project.github_org, repo=project.repo))
        print("git branch -M {branch}\n".format(branch=project.git_main_branch))
        print("git push -u origin {branch}\n".format(branch=project.git_main_branch))
        print("BE BOLD: you can always delete your repo and start again\n")
        print("")
        # print("FINAL STEPS:")
        # print("Follow your customized instructions here:\n")
        # print("    https://github.com/{org}/{repo}/blob/main/src/ontology/README-editors.md".format(
        #     org=project.github_org, repo=project.repo))
    else:
        print("Repository files have been successfully copied, but no git commands have been run.")


def runcmd(cmd):
    logging.info("RUNNING: {}".format(cmd))
    p = subprocess.Popen([cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, universal_newlines=True)
    (out, err) = p.communicate()
    logging.info('OUT: {}'.format(out))
    if err:
        logging.error(err)
    if p.returncode != 0:
        raise Exception('Failed: {}'.format(cmd))


if __name__ == "__main__":
    cli()
