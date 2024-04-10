import sqlite3

from contextlib import closing

sqlite_db = "/work/build/nanobot.db"
TABLE_NAME = "review"


def get_reviews(target_node_accession: str):
    """
    Gets all reviews about a given target node accession.
    :param target_node_accession: target node cell set accession
    :return: list of reviews
    """
    reviews = []
    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            rows = cursor.execute("SELECT * FROM {}_view WHERE target_node_accession='{}'".format(TABLE_NAME, target_node_accession)).fetchall()
            columns = list(map(lambda x: x[0], cursor.description))
            columns = [column for column in columns if column not in ["message", "history"]]
            for row in rows:
                review = {}
                for column in columns:
                    review[column] = row[columns.index(column)]
                reviews.append(review)
    return reviews


def add_review(review: dict):
    """
    Adds a new review to the database.
    :param review: review object
    :return: True if the operation is successful
    """
    keys = list(review.keys())
    keys.extend(["message", "history"])
    columns = "({})".format(", ".join(keys))
    vals = list(review.values())
    vals.extend(["", ""])
    values = "('{}')".format("', '".join(vals))

    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            cursor.execute("INSERT INTO {}_view {} VALUES {}".format(TABLE_NAME, columns, values))
            connection.commit()

    return True


def update_reviews(reviews: list):
    """
    Assumes all reviews are related with the same accession. Removes all reviews related with the accession and adds
    the new ones.
    :param reviews: list of reviews
    """
    keys = list(reviews[0].keys())
    keys.extend(["message", "history"])
    columns = "({})".format(", ".join(keys))
    target_node_accession = reviews[0]["target_node_accession"]

    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            cursor.execute("DELETE  FROM {}_view WHERE target_node_accession='{}'".format(TABLE_NAME, target_node_accession))
            connection.commit()

            for review in reviews:
                vals = list(review.values())
                vals.extend(["", ""])
                values = "('{}')".format("', '".join(vals))
                cursor.execute("INSERT INTO FROM {}_view {} VALUES {}".format(TABLE_NAME, columns, values))
            connection.commit()

    return True
