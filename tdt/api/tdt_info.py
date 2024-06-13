from ruamel.yaml import YAML

INFO_FILE_PATH = "/tools/tdt_info.yaml"


def get_tdt_info():
    """
    Get the tdt info from config file.
    :return: tdt_info
    """
    # Read the tdt info from the config file
    return read_yaml_config(INFO_FILE_PATH)


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
