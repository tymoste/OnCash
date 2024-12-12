
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
import base64
from google.oauth2 import id_token
from google.auth.transport import requests

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://database_owner:K9bRemQXNt2z@ep-dawn-queen-a8tf5nos.eastus2.azure.neon.tech/database?sslmode=require&connect_timeout=30"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)
migrate = Migrate(app, db)


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
        
        group = Group(name=username+"_private",privite=1)
        group.members.extend([new_user])
        db.session.add(new_user)
        db.session.add(group)
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

@app.route("/google_test", methods=["POST"])
def google_test():
    try:
        data = request.get_json()
        token = data["token"]
        idinfo = id_token.verify_oauth2_token(token, requests.Request())
        email = idinfo.get("email")
        name = idinfo.get("name", email.split('@')[0]) 
        
        user = User.query.filter_by(email=email).first()
        if not user:
            user = User(username=name, password="", email=email)
            group = Group(name=name + "_private", privite=1)
            group.members.extend([user])
            
            db.session.add(user)
            db.session.add(group)
            db.session.commit()
            print(f"New user created: {user.username}")

        jwt_token = generate_jwt(user.username)
        
        return jsonify({
            "error": "no error",
            "username": user.username,
            "email": user.email,
            "jwt": jwt_token
        }), 200

    except ValueError as ve:
        print(f"Google token verification error: {ve}")
        return jsonify({"error": "invalid token"}), 400
    except Exception as e:
        print(f"Error during Google login: {e}")
        return jsonify({"error": "server error"}), 500


@app.route("/create_group",methods=["POST"])
def create_group():
    jwt = request.form.get("jwt")
    group_name = request.form.get("name")
    file = request.files.get("file")
    if not file:
        return jsonify({"error": "no file"}), 400
    print(file)

    found , user = validate_jwt(jwt)
    if found:
        group = Group(name=group_name,privite=0,image=file.read(),owner_id=user.id)
        group.members.extend([user])
        db.session.add(group)
        db.session.commit()
        return jsonify({"error": "no error"}), 200
    else:
        return jsonify({"error": "no user"}), 400
@app.route("/get_groups",methods=["POST"])
def get_groups():
    data = request.get_json()
    print(data)
    jwt = data["jwt"]
    found , user = validate_jwt(data["jwt"])
    if found:
        groups = user.groups
        group_list = [{'is_admin':group.owner_id==user.id,'id': group.id, 'name': group.name,"private":group.privite,"img":base64.b64encode(group.image).decode('utf-8') if group.image else ""} for group in groups]
        return jsonify({"error": "no error","groups":group_list}), 200
    else:
        return jsonify({"error": "wrong jwt"}), 400
@app.route("/invite",methods=["POST"])
def invite():
    data = request.get_json()
    print(data)
    jwt = data["jwt"]
    group_id=data["group_id"]
    email=data["email"]
    found , user = validate_jwt(data["jwt"])
    if found:
        invited = User.query.filter_by(email=email).first()
        if invited:
            invite = Invite(user_id=invited.id,group_id=group_id,status="PENDING")
            db.session.add(invite)
            db.session.commit()
            return jsonify({"error": "no error"}), 200
        else:
            return jsonify({"error": "no user with that email"}), 400
    else:
        return jsonify({"error": "wrong jwt"}), 400
@app.route("/get_invites",methods=["POST"])
def get_invites():
    data = request.get_json()
    print(data)
    jwt = data["jwt"]
    found , user = validate_jwt(data["jwt"])
    if found:
        invites = Invite.query.filter_by(user_id=user.id,status="PENDING").all()
        invites_list = [{'group_id': invite.group_id,"invite_id":invite.id} for invite in invites]
        
        return jsonify({"error": "no error","invites":invites_list}), 200
    else:
            return jsonify({"error": "wrong jwt"}), 400
@app.route("/get_group_info",methods=["POST"])
def get_group_info():
    data = request.get_json()
    jwt = data["jwt"]
    group_id=data["id"]
    found , user = validate_jwt(jwt)
    if found:
        group = Group.query.filter_by(id=group_id).first()
        #group_info={'id': group.id, 'name': group.name,"img":base64.b64encode(group.image).decode('utf-8') if group.image else ""}
        return jsonify({"error": "no error",'id': group.id, 'name': group.name,"img":base64.b64encode(group.image).decode('utf-8') if group.image else ""}), 200
    else:
        return jsonify({"error": "wrong jwt"}), 400
@app.route("/accept_invite",methods=["POST"])
def accept_invite():
    data = request.get_json()
    print(data)
    jwt = data["jwt"]
    invite_id=data["invite_id"]
    found , user = validate_jwt(data["jwt"])
    if found:
        invite = Invite.query.filter_by(user_id=user.id,status="PENDING",id=invite_id).first()
        group = Group.query.filter_by(id=invite.group_id).first()
        group.members.extend([user])
        invite.status="ACCEPTED"
        db.session.add(group)
        db.session.add(invite)
        db.session.commit()
        
        return jsonify({"error": "no error"}), 200
    else:
        return jsonify({"error": "wrong jwt"}), 400

@app.route("/decline_invite",methods=["POST"])
def decline_invite():
    data = request.get_json()
    print(data)
    jwt = data["jwt"]
    invite_id=data["invite_id"]
    found , user = validate_jwt(data["jwt"])
    if found:
        invite = Invite.query.filter_by(user_id=user.id,status="PENDING",id=invite_id).first()
        invite.status="DECLINED"
        db.session.add(invite)
        db.session.commit()
        return jsonify({"error": "no error"}), 200
    else:
        return jsonify({"error": "wrong jwt"}), 400
@app.route("/get_users",methods=["POST"])
def get_users():
    data = request.get_json()
    print(data)
    jwt = data["jwt"]
    group_id = data["group_id"]
    found , user = validate_jwt(jwt)
    if found:
        group = Group.query.filter_by(id=group_id).first()
        users = group.members
        users_list = [{'user_id': user.id,"username":user.username,"email":user.email} for user in users]
        return jsonify({"error": "no error","users":users_list}), 200

@app.route("/add_category",methods=["POST"])
def add_category():
    data = request.get_json()
    jwt = data["jwt"]
    category_name = data["name"]
    group_id=data["group_id"]

    found , user = validate_jwt(jwt)
    if found:
        if group_id=="":
            category=Category(name=category_name)
        else:
            category=Category(name=category_name,group_id=group_id)
        db.session.add(category)
        db.session.commit()
        return jsonify({"error": "no error"}), 200
    else:
        return jsonify({"error": "no user"}), 400

@app.route("/get_categories",methods=["POST"])
def get_categories():
    data = request.get_json()
    jwt = data["jwt"]
    group_id=data["group_id"]
    found , user = validate_jwt(jwt)
    if found:
        output=[]
        categories = Category.query.filter_by(group_id=group_id).all()
        for cat in categories:
            output.append({"category_name":cat.name,"category_id":cat.id})
        categories = Category.query.filter_by(group_id=None).all()
        for cat in categories:
            output.append({"category_name":cat.name,"category_id":cat.id})

        return jsonify({"error": "no error","categories":output}), 200
    else:
        return jsonify({"error": "no user"}), 400

@app.route("/add_expense",methods=["POST"])
def add_expense():
    data = request.get_json()
    jwt = data["jwt"]
    name= data["name"]
    price = data["price"]
    desc = data["description"]
    group_id = data["group_id"]
    cat_id=data["category_id"]

    found , user = validate_jwt(jwt)
    if found:
        expense=Expense(name=name,price=price,description=desc,group_id=group_id,user_id=user.id,category_id=cat_id)
        db.session.add(expense)
        db.session.commit()
        return jsonify({"error": "no error"}), 200
    else:
        return jsonify({"error": "no user"}), 400

@app.route("/get_expenses",methods=["POST"])
def get_expenses():
    data = request.get_json()
    jwt = data["jwt"]
    group_id= data["group_id"]
    found , user = validate_jwt(jwt)
    if found:
        group=Group.query.filter_by(id=group_id).first()
        expenses=group.expenses
        output=[]
        for e in expenses:
            cat=e.category
            output.append({
                "id":e.id,
                "name":e.name,
                "price":e.price,
                "category_name":cat.name,
                "category_id":cat.id,
                "date":e.created_at
            })
        return jsonify({"error": "no error","expenses":output}), 200
    else:
        return jsonify({"error": "no user"}), 400


@app.route("/get_group_allinfo",methods=["POST"])
def get_group_allinfo():
    pass

@app.route("/delete_expense",methods=["POST"])
def delete_expense():
    data = request.get_json()
    jwt = data["jwt"]
    expense_id= data["expense_id"]
    found , user = validate_jwt(jwt)
    if found:
        expense = Expense.query.get(expense_id)
        if not expense:
            return jsonify({"error": "no expense with that id"}),400
        db.session.delete(expense)
        db.session.commit()
        return jsonify({"error": "no error"}), 200
    else:
        return jsonify({"error": "no user"}), 400
@app.route("/remove_user",methods=["POST"])
def remove_user():
    data = request.get_json()
    jwt = data["jwt"]
    print(data)
    group_id= int(data["group_id"])
    id_to_delete= int(data["user_id"])
    found , user = validate_jwt(jwt)
    if found:
        result = db.session.execute(
            user_groups.delete().where(
                user_groups.c.user_id == id_to_delete,
                user_groups.c.group_id == group_id
            )
        )
        db.session.commit()
        return jsonify({"error": "no error"}), 200
    else:
        return jsonify({"error": "no user"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

