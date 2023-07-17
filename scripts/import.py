import os
import csv
import click
import shutil
import pandas as pd
from ctat.cell_type_annotation import format_data


@click.group()
def cli():
    pass


@cli.command()
@click.option('-i', '--input', type=click.Path(exists=True), help='Data folder path.')
@click.option('-s', '--schema', type=click.Path(exists=True), help='Nanobot schema folder path.')
@click.option('-ct', '--curation_tables', type=click.Path(exists=True), help='TDT curation tables folder path.')
def import_data(input, schema, curation_tables):
    """
    Imports user data to the system
    Parameters:
        input (str): Path to the input data folder
    """
    user_data_path = None
    user_config_path = None
    for filename in os.listdir(input):
        f = os.path.join(input, filename)
        if os.path.isfile(f):
            if (filename.endswith(".tsv") or filename.endswith(".csv")) and "_std." not in filename:
                user_data_path = f
            elif filename.endswith(".yaml") or filename.endswith(".yml"):
                user_config_path = f

    add_user_table_to_nanobot(user_data_path, schema, curation_tables)

    user_file_name = os.path.splitext(os.path.basename(user_data_path))[0]
    std_data = format_data(user_data_path, user_config_path, os.path.join(input, user_file_name + ".json"))

    std_data_path = convert_standard_json_to_table(std_data, user_file_name, input)
    add_user_table_to_nanobot(std_data_path, schema, curation_tables)


def convert_standard_json_to_table(std_data: dict, source_file_name: str, input_folder: str):
    """
    Converts the standardized data json to tsv to be represented by nanobot.
    Parameters:
        std_data: standard json data content as dictionary
        source_file_name: name of the user file
        input_folder: tdt input data folder path
    """
    std_data_path = os.path.join(input_folder, source_file_name + "_std.tsv")
    std_records = list()
    for annotation_object in std_data["annotationObjects"]:
        if "accessionId" in annotation_object:
            record = dict()
            record["accessionId"] = annotation_object["accessionId"]
            record["cellLabel"] = annotation_object["cellLabel"]
            record["parentNodeName"] = annotation_object["parentNodeName"]
            record["markerGenes"] = annotation_object["markerGenes"]
            if "userAnnotations" in annotation_object:
                for user_annot in annotation_object["userAnnotations"]:
                    record[normalize_column_name(user_annot["annotationSet"])] = user_annot["cellLabel"]
            std_records.append(record)
    std_records_df = pd.DataFrame.from_records(std_records)
    std_records_df.to_csv(std_data_path, sep="\t", index=False)
    return std_data_path


def add_user_table_to_nanobot(user_data_path, schema_folder, curation_tables_folder):
    """
    Adds user data to the nanobot. Adds user table to the curation tables folder and updates the nanobot table schema.
    """
    # update nanobot table.tsv
    user_data_ct_path = copy_file(user_data_path, curation_tables_folder)
    user_table_name = os.path.splitext(os.path.basename(user_data_ct_path))[0]
    table_tsv_path = os.path.join(schema_folder, "table.tsv")
    with open(table_tsv_path, 'a') as fd:
        fd.write(('\n{table_name}\t{path}\t\t\t').format(table_name=user_table_name, path=user_data_ct_path))

    user_data_extension = os.path.splitext(user_data_ct_path)[1]
    user_headers = []
    user_data = dict()
    if user_data_extension == ".tsv":
        user_headers, user_data = read_tsv_to_dict(user_data_ct_path, generated_ids=True)
    elif user_data_extension == ".csv":
        user_headers, user_data = read_csv_to_dict(user_data_ct_path, generated_ids=True)

    # update nanobot column.tsv
    column_tsv_path = os.path.join(schema_folder, "column.tsv")
    with open(column_tsv_path, 'a') as fd:
        for index, header in enumerate(user_headers):
            # TODO fix assumption, first column is the id column
            if index == 0:
                fd.write("\n" + user_table_name + "\t" + normalize_column_name(header) + "\t" +
                         normalize_column_name(header) + "\t\tword\tprimary\t")
            else:
                # TODO fix assumption, all data types are text for now
                fd.write("\n" + user_table_name + "\t" + normalize_column_name(header) + "\t" +
                         normalize_column_name(header) + "\tempty\ttext\t\t")


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
    return column_name.strip().replace("(", "_").replace(")", "_")


def read_tsv_to_dict(tsv_path, id_column=0, generated_ids=False):
    """
    Reads tsv file content into a dict. Key is the first column value and the value is dict representation of the
    row values (each header is a key and column value is the value).
    Args:
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
    Args:
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


if __name__ == '__main__':
    cli()
