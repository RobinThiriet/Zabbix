from flask import Flask, jsonify, request

app = Flask(__name__)

products = []


@app.route('/product', methods=['GET', 'POST'])
def product_management():
    if request.method == 'GET':
        return jsonify(products)

    new_product = request.json
    products.append(new_product)
    return jsonify(new_product), 201


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
