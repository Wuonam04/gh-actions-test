import os

import redis
from flask import Flask, jsonify, request

app = Flask(__name__)
redis_client = redis.StrictRedis(
    host=os.environ.get("REDIS_HOST", "localhost"),
    port=6379,
    db=0,
    decode_responses=True,
)


@app.route("/")
def home():
    return "Hello from Flask"


@app.route("/greet", methods=["GET"])
def greet():
    name = request.args.get("name", "World")
    return jsonify({"message": f"Hello, {name}!"})


@app.route("/products", methods=["POST"])
def create_product():
    product = request.json
    if not product or "name" not in product:
        return jsonify({"error": "Product name is required"}), 400

    product_id = f"product:{product['name']}"
    redis_client.hset("products", product_id, str(product))
    return jsonify({"message": "Product created successfully", "product": product}), 201


@app.route("/products", methods=["GET"])
def list_products():
    products_data = redis_client.hgetall("products")
    products = []
    for key, value in products_data.items():
        products.append(eval(value))
    return jsonify({"products": products})


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
