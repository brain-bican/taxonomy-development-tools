import flask
import review
import user_info

from flask import request, jsonify
from flask_cors import CORS, cross_origin


app = flask.Flask(__name__)
cors = CORS(app)
app.config["CORS_HEADERS"] = "Content-Type"


@app.route("/user_info", methods=["GET"])
@cross_origin()
def get_user_info():
    return jsonify(user_info.get_user_info())


@app.route("/all_reviews", methods=["GET"])
@cross_origin()
def get_all_reviews():
    return jsonify(review.get_all_reviews())


@app.route("/reviews", methods=["GET"])
@cross_origin()
def get_reviews():
    accession_id = request.args.get("accession_id")
    print(accession_id)
    return jsonify(review.get_reviews(accession_id))


@app.route("/reviews", methods=["POST"])
@cross_origin()
def add_review():
    data = request.json
    print(data)
    return jsonify(review.add_review(data))


@app.route("/reviews", methods=["PUT"])
@cross_origin()
def update_reviews():
    data = request.json
    print(data)
    return jsonify(review.update_reviews(data))


@app.route("/reviews", methods=["DELETE"])
@cross_origin()
def delete_review():
    data = request.json
    print(data)
    return jsonify(review.delete_review(data))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
