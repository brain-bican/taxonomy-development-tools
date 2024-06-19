import flask
import review
import user_info
import tdt_info
import flags

from flask_caching import Cache
from flask import request, jsonify
from flask_cors import CORS, cross_origin


app = flask.Flask(__name__)
cors = CORS(app)
app.config["CORS_HEADERS"] = "Content-Type"
cache = Cache(app, config={'CACHE_TYPE': 'simple'})


@app.route("/user_info", methods=["GET"])
@cross_origin()
@cache.cached(timeout=3600)
def get_user_info():
    return jsonify(user_info.get_user_info())


@app.route("/tdt_info", methods=["GET"])
@cross_origin()
@cache.cached(timeout=36000)
def get_tdt_info():
    return jsonify(tdt_info.get_tdt_info())


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


@app.route("/all_flags", methods=["GET"])
@cross_origin()
def get_all_flags():
    return jsonify(flags.get_all_flags())


@app.route("/flags", methods=["GET"])
@cross_origin()
def get_flags():
    accession_id = request.args.get("accession_id")
    print(accession_id)
    return jsonify(flags.get_flags(accession_id))


@app.route("/flags", methods=["POST"])
@cross_origin()
def add_flag():
    data = request.json
    print(data)
    return jsonify(flags.add_flag(data["accession_id"], data["flag"]))


@app.route("/flags", methods=["DELETE"])
@cross_origin()
def delete_flag():
    data = request.json
    print(data)
    return jsonify(flags.remove_flag(data["accession_id"], data["flag"]))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
