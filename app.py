
import json
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
import os
import datetime
from models import *
from db import db
from sqlalchemy import and_
from sqlalchemy import or_
import random
from auth import *
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://database_owner:K9bRemQXNt2z@ep-dawn-queen-a8tf5nos.eastus2.azure.neon.tech/database?sslmode=require"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)
migrate = Migrate(app, db)




@app.route('/')
def hello_world():
    return "Hello, World!"

@app.route("/test",methods=["POST","GET"])
def test():
    data = request.get_json()
    return data
@app.route("/test/login",methods=["POST"])
def logintest():
    data = request.get_json()
    print(data)
    return jsonify({"error": "no error 4 u","username":"user.username","email":"user.email"}), 200
@app.route("/login",methods=["POST"])
def login():
    data = request.get_json()
    print(data)
    try:
        username = data["username"]
        password = data["password"]
        user = User.query.filter(or_(User.username == username, User.email == username),User.password == password).first()
        if user:
            print("LOGGED")#user.username
            return jsonify({"error": "no error 4 u","username":user.username,"email":user.email,"jwt":generate_jwt(user.username)}), 200
        else:
            print("NLOGGED")
            return jsonify({"error": "wrong passes"}), 401
    except Exception as e:
        print(e)
        return jsonify({"error": "not working"}), 500
    return f"logged username [{username}] with password: {passwd}" , 200
@app.route("/register",methods=["POST"])
def register():
    data = request.get_json()
    print(data)
    try:
        username = data["username"]
        password = data["password"]
        email = data["email"]
        if User.query.filter_by(username=username).first():
            return jsonify({"error": "already in db"}), 400
        new_user = User(username=username, password=password, email=email)
        db.session.add(new_user)
        db.session.commit()
    except Exception as e:
        print(e)
        return jsonify({"error": "not working"}), 500
    return jsonify({"error": "no error"}), 200

@app.route("/change_username",methods=["POST"])
def change_username():
    data = request.get_json()
    print(data)
    found,user = validate_jwt(data["jwt"])
    if found:
        print(user.username)
        if user.change_username(data["newUsername"]):
            return jsonify({"error": "no error","username":user.username,"jwt":"","email":user.email}), 200
        else:
            return jsonify({"error": "INTEGIRY ERROR"}),500
    else:
        return jsonify({"error": "no user"}), 400
@app.route("/change_password",methods=["POST"])
def change_password():
    data = request.get_json()
    print(data)
    found,user = validate_jwt(data["jwt"])
    if found:
        if data["oldPassword"]==user.password:
            if user.change_password(data["newPassword"]):
                return jsonify({"error": "no error","username":user.username,"jwt":"","email":user.email}), 200
            else:
                return jsonify({"error": "INTEGIRY ERROR"}),500
    else:
        return jsonify({"error": "no user"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


