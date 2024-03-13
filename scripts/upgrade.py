import os
import click
import logging

from pathlib import Path
from ruamel.yaml import YAML
from shutil import copyfile

# see Dockerfile
WORKSPACE = "/tools"

logging.basicConfig(level=logging.INFO)


@click.group()
def cli():
    pass


@cli.command()
@click.option('-r', '--root_folder', type=click.Path(exists=True), help='Root folder path.')
@click.option('-w', '--workspace', type=click.Path(exists=True), help='Workspace folder path.')
def upgrade(root_folder, workspace):
    print("Upgrading local files...")
    configs = retrieve_configs(Path(root_folder).absolute(), "id")
    project_id = configs[0]
    outdir = root_folder

    tgts = []
    create_nanobot_toml(outdir, project_id, tgts)
    create_run_script(outdir, tgts)
    create_ontodev_tables(outdir, project_id, tgts)
    create_ontodev_static_files(outdir, tgts)
    create_gitignore(outdir, tgts)
    create_makefile(outdir, tgts)
    print("Upgrade completed successfully.")


def create_ontodev_tables(outdir, project_id, tgts):
    table_source = WORKSPACE + "/nanobot/src/schema/table.tsv"
    with open(table_source, "r") as f:
        content = f.read()
    content = content.replace("{taxonomy_id}", project_id)
    table_target = "{}/src/schema/table.tsv".format(outdir)
    with open(table_target, "w") as f:
        f.write(content)
    tgts.append(table_target)

    table_source = WORKSPACE + "/nanobot/src/schema/column.tsv"
    with open(table_source, "r") as f:
        content = f.read()
    content = content.replace("{taxonomy_id}", project_id)
    table_target = "{}/src/schema/column.tsv".format(outdir)
    with open(table_target, "w") as f:
        f.write(content)
    tgts.append(table_target)

    file_target = "{}/src/schema/datatype.tsv".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/schema/datatype.tsv", file_target)


def create_ontodev_static_files(outdir, tgts):
    file_target = "{}/src/assets/bstreeview.css".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/assets/bstreeview.css", file_target)

    file_target = "{}/src/assets/bstreeview.js".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/assets/bstreeview.js", file_target)

    file_target = "{}/src/assets/ols-autocomplete.css".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/assets/ols-autocomplete.css", file_target)

    file_target = "{}/src/assets/ols-autocomplete.js".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/assets/ols-autocomplete.js", file_target)

    file_target = "{}/src/assets/styles.css".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/assets/styles.css", file_target)

    file_target = "{}/src/resources/cross_taxonomy.html".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/resources/cross_taxonomy.html", file_target)

    file_target = "{}/src/resources/taxonomy_view.html".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/resources/taxonomy_view.html", file_target)

    file_target = "{}/src/resources/ols_form.html".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/resources/ols_form.html", file_target)

    file_target = "{}/src/resources/table.html".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/resources/table.html", file_target)

    file_target = "{}/src/resources/page.html".format(outdir)
    tgts.append(file_target)
    copyfile(WORKSPACE + "/nanobot/src/resources/page.html", file_target)


def create_nanobot_toml(outdir, project_id, tgts):
    nanobot_source = WORKSPACE + "/nanobot/nanobot.toml"
    with open(nanobot_source, "r") as f:
        content = f.read()
    content = content.replace("$$TAXONOMY_ID$$", project_id)
    nanobot_target = "{}/nanobot.toml".format(outdir)
    with open(nanobot_target, "w") as f:
        f.write(content)
    tgts.append(nanobot_target)


def create_makefile(outdir, tgts):
    mf_source = WORKSPACE + "/Makefile"
    mf_target = "{}/Makefile".format(outdir)
    tgts.append(mf_target)
    copyfile(mf_source, mf_target)


def create_run_script(outdir, tgts):
    run_script_source = WORKSPACE + "/scripts/run.sh"
    run_script_target = "{}/run.sh".format(outdir)
    tgts.append(run_script_target)
    copyfile(run_script_source, run_script_target)

    run_script_source_win = WORKSPACE + "/scripts/run.bat"
    run_script_target_win = "{}/run.bat".format(outdir)
    tgts.append(run_script_target_win)
    copyfile(run_script_source_win, run_script_target_win)


def create_gitignore(outdir, tgts):
    gitignore_source = WORKSPACE + "/scripts/.gitignore"
    gitignore_target = "{}/.gitignore".format(outdir)
    tgts.append(gitignore_target)
    copyfile(gitignore_source, gitignore_target)


def retrieve_configs(root_folder_path, *properties):
    """
    Reads project configuration from the root folder and returns the config values.
    Params:
        root_folder_path: path of the project root folder.
        properties: positional arguments for config property names
    Returns: Git configurations list. List length is same with the `properties` argument and values are provided in
    the same order with `properties`.
    """
    values = list()
    for filename in os.listdir(root_folder_path):
        f = os.path.join(root_folder_path, filename)
        if os.path.isfile(f):
            if filename.endswith("_project_config.yaml"):
                ryaml = YAML(typ='safe')
                with open(f, "r") as fs:
                    try:
                        data = ryaml.load(fs)
                        for prop in properties:
                            if prop in data and data[prop]:
                                values.append(str(data[prop]).strip())
                            else:
                                values.append(None)
                    except Exception as e:
                        raise Exception("Yaml read failed:" + f + " " + str(e))
    return values


if __name__ == '__main__':
    cli()
