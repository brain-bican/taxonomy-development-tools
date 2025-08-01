import os
import csv
import json
import click
import logging
import subprocess
import zipfile
import shutil
import pandas as pd
from dataclasses import asdict

from importlib import resources
from pathlib import Path
from ruamel.yaml import YAML

from tdta.git_utils import add_new_files_to_git

from cas.ingest.ingest_user_table import ingest_user_data
from cas.flatten_data_to_tables import serialize_to_tables
from cas.file_utils import read_cas_json_file
from cas_schema import schemas

# see Dockerfile
WORKSPACE = "/tools"


@click.group()
def cli():
    pass


@cli.command()
@click.option('-i', '--input', type=click.Path(exists=True), help='Data folder path.')
@click.option('-ct', '--curation_tables', type=click.Path(exists=True), help='TDT curation tables folder path.')
@click.option('-f', '--force', is_flag=True, default=False, help="Forcefully drops and recreates tables.")
@click.option('-p', '--preserve', is_flag=True, default=False, help='Preserve existing annotations.')
def import_data(input, curation_tables, force, preserve):
    """
    Imports user data to the system
    Parameters:
        input (str): Path to the input data folder
        curation_tables: TDT curation tables folder path.
        force: Forcefully drops and recreates tables.
        preserve: Preserve existing annotations.
    """
    global last_accession_id, accession_ids
    last_accession_id = 0
    accession_ids = list()
    new_files = list()

    user_data_path = None
    user_config_path = None
    user_cas_path = None
    unzipped_files = unzip_files_in_folder(input)
    for filename in os.listdir(input):
        f = os.path.join(input, filename)
        if os.path.isfile(f):
            if (filename.endswith(".tsv") or filename.endswith(".csv")) and "_std." not in filename:
                user_data_path = f
                new_files.append(user_data_path)
            elif filename.endswith(".yaml") or filename.endswith(".yml"):
                user_config_path = f
                new_files.append(user_config_path)
            elif filename.endswith(".json"):
                user_cas_path = f
                if user_cas_path not in unzipped_files:
                    new_files.append(user_cas_path)

    # provide either json or tsv + yaml
    if user_cas_path:
        print("Loading data from CAS data file: " + user_cas_path)
        user_file_name = os.path.splitext(os.path.basename(user_cas_path))[0]
        std_data = read_cas_json_file(user_cas_path)
    else:
        if user_data_path:
            print("Loading data from annotation file: " + user_data_path)
        else:
            raise Exception("Couldn't find the cell type annotation config file (with yaml or yml extension) in folder: " + input)

        if user_config_path:
            user_file_name = os.path.splitext(os.path.basename(user_data_path))[0]
            std_data = ingest_user_data(user_data_path, user_config_path, True)
        else:
            raise Exception("Couldn't find the config data files (with yaml or yml extension) in folder: " + input)
    if preserve:
        print("Preserving existing annotations.")
        preserve_existing_annotations(std_data, curation_tables)

    project_config = retrieve_project_config(Path(input).parent.absolute())
    std_tables = serialize_to_tables(std_data, user_file_name, input, project_config)
    tdt_tables = generate_tdt_tables(std_data, input)
    std_tables.extend(tdt_tables)

    cas_schema = read_cas_schema()
    for table_path in std_tables:
        user_data_ct_path = add_user_table_to_nanobot(table_path, curation_tables, cas_schema, True, force)
        if user_data_ct_path:
            new_files.append(user_data_ct_path)

    # delete unzipped files
    for file_path in unzipped_files:
        os.remove(file_path)
    project_folder = os.path.dirname(os.path.abspath(input))
    add_new_files_to_git(project_folder, new_files)


def preserve_existing_annotations(cas_obj, curation_tables_folder):
    """
    Copies existing annotations to the new ingested data.
    Parameters:
        cas_obj: cas python object instance
        curation_tables_folder: curation tables folder path
    """
    columns_to_preserve = ["cell_ontology_term_id", "cell_ontology_term", "rationale", "rationale_dois"]

    existing_annotations_table = os.path.join(curation_tables_folder, "annotation.tsv")
    if os.path.isfile(existing_annotations_table):
        headers, data = read_csv_to_dict(existing_annotations_table, delimiter="\t", id_column_name="cell_label")
        new_annotations = dict()
        for annotation in cas_obj.annotations:
            cell_label = annotation.cell_label
            new_annotations[cell_label] = annotation

        for cell_label in data:
            records = data[cell_label]
            for column in columns_to_preserve:
                if records.get(column):
                    if cell_label in new_annotations:
                        if column not in asdict(new_annotations[cell_label]):  # don't overwrite existing values
                            new_annotations[cell_label][column] = records[column]
                    else:
                        print("Couldn't transferred the '{}' column of the '{}'.".format(column, cell_label))
    else:
        print("Existing annotations couldn't be found in the folder to copy: " + curation_tables_folder)


def unzip_files_in_folder(folder_path):
    files_in_folder = os.listdir(folder_path)
    unzipped_files = []
    for file_name in files_in_folder:
        if file_name.endswith('.zip'):
            zip_path = os.path.join(folder_path, file_name)
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                extracted_files = zip_ref.namelist()
                zip_ref.extractall(folder_path)
                for extracted_file in extracted_files:
                    unzipped_files.append(os.path.join(folder_path, extracted_file))
            print(f"Extracted '{zip_path}'.")
    return unzipped_files


def add_user_table_to_nanobot(user_data_path, curation_tables_folder, cas_schema, delete_source=False, force=False):
    """
    Adds user data to the relatable. Adds user table to the curation tables folder.
    """
    user_data_ct_path = os.path.join(curation_tables_folder, Path(user_data_path).name)
    if os.path.isfile(user_data_ct_path) is False or os.path.getsize(user_data_ct_path) == 0 or force:
        user_data_ct_path = copy_file(user_data_path, curation_tables_folder)

    if delete_source:
        os.remove(user_data_path)
    return user_data_ct_path


def get_column_description(cas_schema, table_name, column_name):
    """
    Extracts column description from the cell annotation schema.
    """
    schema_section = cas_schema
    if table_name == "annotation":
        schema_section = cas_schema["definitions"]["Annotation"]["properties"]
    elif table_name == "labelset":
        schema_section = cas_schema["definitions"]["Labelset"]["properties"]
    elif table_name == "metadata":
        schema_section = cas_schema["properties"]
    elif table_name == "annotation_transfer":
        schema_section = cas_schema["definitions"]["Annotation_transfer"]["properties"]

    desc = extract_definition_from_cas_object(cas_schema, column_name, schema_section)

    return desc


def extract_definition_from_cas_object(cas_schema, column_name, schema_section):
    desc = ""
    if column_name in schema_section and "description" in schema_section[column_name]:
        desc = schema_section[column_name]["description"]
        desc = str(desc).strip().replace("\t", " ").replace("\n", " ")
        if schema_section[column_name]["type"] == "array":
            desc = desc + " Multiple values can be concatenated by using the '|' character as a delimiter."
            desc = desc.strip()
    else:
        # handle nested objects
        parts = column_name.split("_")
        nested_obj_name = parts[0]
        for i in range(1, len(parts) - 1):
            if nested_obj_name in schema_section:
                inner_schema_section = cas_schema["definitions"][nested_obj_name]["properties"]
                inner_column_name = column_name.replace(nested_obj_name + "_", "")
                if inner_column_name in inner_schema_section:
                    return extract_definition_from_cas_object(cas_schema, inner_column_name, inner_schema_section)
            else:
                nested_obj_name = nested_obj_name + "_" + parts[i]
    return desc


def copy_file(source_file, target_folder):
    """
    Copies source file to the target location and applies header normalizations for nanobot compatibility.
    Nanobot column name requirement: All names must match: ^[\w_ ]+$' for to_url()
    """
    # new_data_path = shutil.copy(source_file, target_folder)
    source_file_name = os.path.basename(source_file)
    new_data_path = os.path.join(target_folder, source_file_name)

    sf = open(source_file, 'r')
    tf = open(new_data_path, 'w')

    row_num = 0
    for line in sf:
        if row_num == 0:
            source_file_extension = os.path.splitext(source_file)[1]
            if source_file_extension == ".tsv":
                headers = line.split("\t")
                new_headers = []
                for header in headers:
                    new_headers.append(normalize_column_name(header))
                tf.write("\t".join(new_headers) + "\n")
            elif source_file_extension == ".csv":
                headers = line.split(",")
                new_headers = []
                for header in headers:
                    new_headers.append(normalize_column_name(header))
                tf.write(",".join(new_headers))
        else:
            tf.write(line)
        row_num += 1

    sf.close()
    tf.close()

    return new_data_path


def normalize_column_name(column_name: str) -> str:
    """
    Normalizes column name for nanobot compatibility.
    Nanobot column name requirement: All names must match: ^[\w_ ]+$' for to_url()

    Parameters:
        column_name: current column name
    Returns:
        normalized column_name
    """
    return column_name.strip().replace("(", "_").replace(")", "_").replace("-", "_")


def read_tsv_to_dict(tsv_path, id_column=0, generated_ids=False):
    """
    Reads tsv file content into a dict. Key is the first column value and the value is dict representation of the
    row values (each header is a key and column value is the value).
    Parameters:
        tsv_path: Path of the TSV file
        id_column: Id column becomes the key of the dict. This column should be unique. Default value is first column.
        generated_ids: If 'True', uses row number as the key of the dict. Initial key is 0.
    Returns:
        Function provides two return values: first; headers of the table and second; the TSV content dict. Key of the
        content is the first column value and the values are dict of row values.
    """
    return read_csv_to_dict(tsv_path, id_column=id_column, delimiter="\t", generated_ids=generated_ids)


def read_csv_to_dict(csv_path, id_column=0, id_column_name="", delimiter=",", id_to_lower=False, generated_ids=False):
    """
    Reads tsv file content into a dict. Key is the first column value and the value is dict representation of the
    row values (each header is a key and column value is the value).
    Parameters:
        csv_path: Path of the CSV file
        id_column: Id column becomes the keys of the dict. This column should be unique. Default is the first column.
        id_column_name: Alternative to the numeric id_column, id_column_name specifies id_column by its header string.
        delimiter: Value delimiter. Default is comma.
        id_to_lower: applies string lowercase operation to the key
        generated_ids: If 'True', uses row number as the key of the dict. Initial key is 0.

    Returns:
        Function provides two return values: first; headers of the table and second; the CSV content dict. Key of the
        content is the first column value and the values are dict of row values.
    """
    records = dict()

    headers = []
    with open(csv_path) as fd:
        rd = csv.reader(fd, delimiter=delimiter, quotechar='"')
        row_count = 0
        for row in rd:
            _id = row[id_column]
            if id_to_lower:
                _id = str(_id).lower()

            if generated_ids:
                _id = row_count

            if row_count == 0:
                headers = row
                if id_column_name and id_column_name in headers:
                    id_column = headers.index(id_column_name)
            else:
                row_object = dict()
                for column_num, column_value in enumerate(row):
                    row_object[headers[column_num]] = column_value
                records[_id] = row_object

            row_count += 1

    return headers, records


def retrieve_project_config(root_folder_path):
    """
    Reads project configuration from the root folder and returns the accession prefix.
    Parameters:
        root_folder_path: path of the project root folder.
    Returns: Accession id prefix defined in the project configuration.
    """
    for filename in os.listdir(root_folder_path):
        f = os.path.join(root_folder_path, filename)
        if os.path.isfile(f):
            if filename.endswith("_project_config.yaml"):
                ryaml = YAML(typ='safe')
                with open(f, "r") as fs:
                    try:
                        data = ryaml.load(fs)

                        if "accession_id_prefix" in data:
                            prefix = str(data["accession_id_prefix"]).strip()
                            if not prefix.endswith("_"):
                                prefix = prefix + "_"
                            data["accession_id_prefix"] = prefix
                        else:
                            data["accession_id_prefix"] = str(data["id"]).strip() + "_"

                    except Exception as e:
                        raise Exception("Yaml read failed:" + f + " " + str(e))
    return data


def generate_tdt_tables(cas_data, output_folder):
    """
    Along with the CAS standard tables, TDT has some tables required for its execution. This function generates these.
    Parameters:
        cas_data: CAS data
        output_folder: output folder path
    Returns: List of TDT tables
    """
    tdt_tables = list()
    tdt_tables.append(generate_flags_table(output_folder))
    return tdt_tables


def generate_flags_table(out_folder):
    """
    Generates annotation flags (requires review etc.) table.

    Parameters:
        out_folder: output folder path.
    """
    table_path = str(os.path.join(out_folder + "flags.tsv"))
    row = ["accession_id", "flag"]
    with open(table_path, "w") as f_output:
        tsv_output = csv.writer(f_output, delimiter="\t")
        tsv_output.writerow(row)
    return table_path


def read_cas_schema():
    schema_file = (resources.files(schemas) / "BICAN_schema.json")
    with schema_file.open("rt") as f:
        return json.loads(f.read())


def runcmd(cmd):
    logging.info("RUNNING: {}".format(cmd))
    p = subprocess.Popen([cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, universal_newlines=True)
    (out, err) = p.communicate()
    logging.info('OUT: {}'.format(out))
    if err:
        logging.error(err)
    if p.returncode != 0:
        raise Exception('Failed: {}'.format(cmd))


if __name__ == '__main__':
    cli()
