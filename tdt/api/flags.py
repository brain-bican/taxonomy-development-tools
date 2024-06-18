import sqlite3

from contextlib import closing

sqlite_db = "/work/build/nanobot.db"
TABLE_NAME = "flags"

# Flags
REQUEST_REVIEW = "request_review"
DISAGREE_REVIEW = "disagree_review"
AGREE_REVIEW = "agree_review"

FLAGS_PRIORITY_ORDER = [REQUEST_REVIEW, DISAGREE_REVIEW, AGREE_REVIEW]


def get_all_flags():
    """
    Gets the most important flag for each target_node_accession.
    :return: list of reviews
    """
    flags = dict()
    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            query = """
                    SELECT {0}.accession_id, {0}.flag FROM {0}
                    """
            rows = cursor.execute(query.format(TABLE_NAME)).fetchall()
            for row in rows:
                if row[0] in flags:
                    if FLAGS_PRIORITY_ORDER.index(row[1]) < FLAGS_PRIORITY_ORDER.index(flags[row[0]]):
                        flags[row[0]] = row[1]
                else:
                    flags[row[0]] = row[1]
    return flags


def get_flags(accession_id: str):
    """
    Gets all flags about a given target node accession.
    :param accession_id: target node cell set accession
    :return: list of flags
    """
    flags = []
    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            rows = cursor.execute(
                "SELECT {0}.flag FROM {0} WHERE accession_id='{1}'".format(
                    TABLE_NAME, accession_id
                )
            ).fetchall()
            for row in rows:
                flags.append(row[0])
    return flags


def add_flag(accession_id: str, flag: str):
    """
    Adds a new review to the database.
    Parameters:
        accession_id: target node cell set accession
        flag: review object
    Returns: True if the operation is successful
    """
    if flag not in FLAGS_PRIORITY_ORDER:
        raise ValueError("Invalid flag: {}".format(flag))

    if flag not in get_flags(accession_id):
        values = "('{}', '{}')".format(accession_id, flag)
        with closing(sqlite3.connect(sqlite_db)) as connection:
            with closing(connection.cursor()) as cursor:
                cursor.execute(
                    "INSERT INTO {} (accession_id, flag) VALUES {}".format(TABLE_NAME, values)
                )
                connection.commit()

    return True


def remove_flag(accession_id: str, flag: str):
    """
    Removes flag from the accession_id.
    Parameters:
        accession_id: target node cell set accession
        flag: flag to remove
    Returns: True if the operation is successful
    """
    if flag in get_flags(accession_id):
        with closing(sqlite3.connect(sqlite_db)) as connection:
            with closing(connection.cursor()) as cursor:
                cursor.execute(
                    "DELETE FROM {} WHERE accession_id='{}' and flag='{}'".format(
                        TABLE_NAME,
                        accession_id,
                        flag
                    )
                )
                connection.commit()

    return True
