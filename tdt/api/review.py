import sqlite3

from contextlib import closing

sqlite_db = "/work/build/nanobot.db"
TABLE_NAME = "review"


def get_all_reviews():
    """
    Gets the type ('Agree'/'Disagree') of the latest reviews for each target_node_accession.
    :return: list of reviews
    """
    reviews = dict()
    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            # get the latest reviews for each target node accession
            query = """
                    SELECT review.target_node_accession as node, review.review as type
                    FROM review
                    INNER JOIN
                        (SELECT target_node_accession, MAX(time) AS latestReviewDate
                        FROM review
                        GROUP BY target_node_accession) grouped_review 
                    ON review.target_node_accession = grouped_review.target_node_accession 
                    AND review.time = grouped_review.latestReviewDate
                    """
            rows = cursor.execute(query.format(TABLE_NAME)).fetchall()
            for row in rows:
                reviews[row[0]] = row[1]
    return reviews


def get_reviews(target_node_accession: str):
    """
    Gets all reviews about a given target node accession.
    :param target_node_accession: target node cell set accession
    :return: list of reviews
    """
    reviews = []
    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            rows = cursor.execute(
                "SELECT * FROM {} WHERE target_node_accession='{}'".format(
                    TABLE_NAME, target_node_accession
                )
            ).fetchall()
            columns = list(map(lambda x: x[0], cursor.description))
            # columns = [column for column in columns if column not in ["message", "history"]]
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
    # keys.extend(["message", "history"])
    columns = "({})".format(", ".join(keys))
    vals = list(review.values())
    # vals.extend(["", ""])
    values = "('{}')".format("', '".join(vals))

    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            cursor.execute(
                "INSERT INTO {} {} VALUES {}".format(TABLE_NAME, columns, values)
            )
            connection.commit()

    return True


def update_reviews(review: dict):
    """
    Updates the given reviews in the database.
    :param review: review to update
    """
    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            cursor.execute(
                "UPDATE {} SET review='{}', explanation='{}'  WHERE target_node_accession='{}' and name='{}' and time='{}'".format(
                    TABLE_NAME,
                    review.get("review", ""),
                    review.get("explanation", ""),
                    review.get("target_node_accession", ""),
                    review.get("name", ""),
                    review.get("time", ""),
                )
            )
            connection.commit()

    return True


def delete_review(review: dict):
    """
    Deletes a new review from the database.
    :param review: review object
    :return: True if the operation is successful
    """
    with closing(sqlite3.connect(sqlite_db)) as connection:
        with closing(connection.cursor()) as cursor:
            cursor.execute(
                "DELETE FROM {} WHERE target_node_accession='{}' and name='{}' and time='{}'".format(
                    TABLE_NAME,
                    review.get("target_node_accession", ""),
                    review.get("name", ""),
                    review.get("time", ""),
                )
            )
            connection.commit()

    return True
