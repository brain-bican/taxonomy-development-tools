import subprocess
from ruamel.yaml import YAML

INFO_FILE_PATH = "/tools/tdt_info.yaml"


def get_tdt_info():
    """
    Get the tdt info from config file.
    :return: tdt_info
    """
    tdt_info = read_yaml_config(INFO_FILE_PATH)
    tdt_info["repo_url"] = get_repo_info()
    return tdt_info


def read_yaml_config(file_path: str) -> dict:
    """
    Reads the configuration object from the given path.
    :param file_path: path to the yaml file
    :return: configuration object (List of data column config items)
    """
    with open(file_path, "r") as fs:
        try:
            ryaml = YAML(typ="safe")
            return ryaml.load(fs)
        except Exception as e:
            raise Exception("Yaml read failed:" + file_path + " " + str(e))


def get_repo_info():
    """
    Get the origin repo from git.
    :return: configured repository url
    """
    origin_url = subprocess.check_output(["git", "config", "--get", "remote.origin.url"]).strip().decode()
    # parse https://token@github.com/repo_path.git/
    repo_url = "https://www." + origin_url.split("@")[-1].split(".git")[0]
    return repo_url
