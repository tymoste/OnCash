
import json
from flask import Flask, jsonify, request
#new user
app = Flask(__name__)

@app.route('/')
def hello_world():
    return "Hello, World!"

@app.route("/test",methods=["POST","GET"])
def test():
    data = request.get_json()
    return data

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

