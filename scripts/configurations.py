import os
import click
import logging
import subprocess
from pathlib import Path
from ruamel.yaml import YAML

GITHUB_TOKEN_ENV = 'GITHUB_AUTH_TOKEN'
TOKEN_FILE = "mytoken.txt"


@click.group()
def cli():
    pass


@cli.command()
@click.option('-r', '--root_folder', type=click.Path(exists=True), help='Root folder path.')
def configure_git(root_folder):
    configs = retrieve_configs(Path(root_folder).absolute(),
                               "github_user_email", "github_user_name", "github_org", "repo")

    github_user_email = configs[0]
    github_user_name = configs[1]
    github_org = configs[2]
    repo = configs[3]

    if not github_user_email:
        github_user_email = os.getenv("GITHUB_EMAIL", default=None)
    if github_user_email:
        runcmd("git config --global user.email \"{}\"".format(github_user_email))

    if not github_user_name:
        github_user_name = os.getenv("GITHUB_USER", default=None)
    if github_user_name:
        runcmd("git config --global user.name \"{}\"".format(github_user_name))

    runcmd("git config --global credential.helper store")

    remotes = runcmd("git remote -v")

    if "origin" in remotes and os.getenv("GITHUB_AUTH_TOKEN", default=None):
        runcmd("git remote set-url origin https://{gh_token}@github.com/{gh_org}/{gh_repo}.git/".format(gh_token=os.getenv("GITHUB_AUTH_TOKEN"), gh_org=github_org, gh_repo=repo))
    else:
        print("WARN: The project has not been pushed to GitHub yet, resulting in incomplete GitHub authentication.")

    purl_folder = os.path.join(Path(root_folder).absolute(), "purl")
    print(purl_folder)
    gh_login(purl_folder)
    cleanup(purl_folder)


def gh_login(purl_folder):
    github_token = os.environ.get(GITHUB_TOKEN_ENV)
    token_file = os.path.join(purl_folder, TOKEN_FILE)
    with open(token_file, 'w') as f:
        f.write(github_token)

    runcmd("git config --global credential.helper store")
    runcmd("gh auth login --with-token < {}".format(token_file))
    runcmd("gh auth setup-git")

    return token_file


def cleanup(purl_folder):
    """
    Cleanups all intermediate file/folders.
    :param purl_folder: path of the purl folder where intermediate files are added
    """
    token_file = os.path.join(purl_folder, TOKEN_FILE)
    if os.path.exists(token_file):
        os.remove(token_file)


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


def runcmd(cmd):
    logging.info("RUNNING: {}".format(cmd))
    p = subprocess.Popen([cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, universal_newlines=True)
    (out, err) = p.communicate()
    logging.info('OUT: {}'.format(out))
    if err:
        logging.error(err)
    if p.returncode != 0:
        raise Exception('Failed: {}'.format(cmd))
    return out


if __name__ == '__main__':
    cli()
