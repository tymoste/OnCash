from datetime import datetime
from db import db

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(128), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=True)
    email = db.Column(db.String(128), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    groups = db.relationship('Group', secondary='user_groups', back_populates='members')
    expenses = db.relationship('Expense', back_populates='user')
    
    def __repr__(self):
        return f'<User {self.username}>'
    
    def to_dict(self):
        return {
           'id': self.id,
           'username': self.username,
           'email': self.email,
           'created_at': self.created_at.isoformat()
       }
    def change_username(self, new_username):
        self.username = new_username
        try:
            db.session.commit()
            return True
        except IntegrityError:
            db.session.rollback()
            return False
    def change_password(self, new_username):
        self.password = new_username
        try:
            db.session.commit()
            return True
        except IntegrityError:
            db.session.rollback()
            return False

class Expense(db.Model):
    __tablename__ = 'expenses'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(512), nullable=False)
    price = db.Column(db.Float, nullable=False)
    description = db.Column(db.String(2048), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    group_id = db.Column(db.Integer, db.ForeignKey('groups.id'), nullable=True)
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'), nullable=True)
    
    user = db.relationship('User', back_populates='expenses')
    group = db.relationship('Group', back_populates='expenses')
    category = db.relationship('Category', back_populates='expenses')

class Group(db.Model):
    __tablename__ = "groups"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False)
    privite = db.Column(db.Boolean, primary_key=False)
    image = db.Column(db.LargeBinary, nullable=True)  
    image_mimetype = db.Column(db.String(128), nullable=True)  
    owner_id = db.Column(db.Integer, nullable=True)
    members = db.relationship('User', secondary='user_groups', back_populates='groups')
    expenses = db.relationship('Expense', back_populates='group')

class Category(db.Model):
    __tablename__ = "categories"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128), nullable=False)
    
    group_id = db.Column(db.Integer, db.ForeignKey('groups.id'), nullable=True)
    
    expenses = db.relationship('Expense', back_populates='category')



class Invite(db.Model):
    __tablename__ = "invites"
    id = db.Column(db.Integer, primary_key=True)
    group_id = db.Column(db.Integer, db.ForeignKey('groups.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    status = db.Column(db.String(128), nullable=True)


user_groups = db.Table(
    'user_groups',
    db.Column('user_id', db.Integer, db.ForeignKey('users.id'), primary_key=True),
    db.Column('group_id', db.Integer, db.ForeignKey('groups.id'), primary_key=True)
)






