from enum import Enum

from flask_login import UserMixin

from app import db, login_manager


@login_manager.user_loader
def load_user(user_id):
    return User.get_by_username(user_id)


class User(UserMixin):

    class Status(Enum):
        PENDING = "Pending"
        APPROVED = "Approved"
        DECLINED = "Declined"

    def __init__(self, username, password, first_name, last_name, is_visitor=False):
        self.username = username
        self.password = password
        self.status = self.Status.PENDING
        self.first_name = first_name
        self.last_name = last_name
        self.is_visitor = is_visitor

    def create(self):
        cur = db.connection.cursor()
        cur.callproc()  # TODO: fill in procedure name and parameters to insert a row into Users table

    def get_id(self):
        return self.username

    @staticmethod
    def get_by_email(email):
        cur = db.connection.cursor()
        cur.callproc()  # TODO: fill in procedure name and parameters to query a row from Users table
        # TODO: make sure it returns None if the user does not exist

    @staticmethod
    def get_by_username(username):
        cur = db.connection.cursor()
        cur.callproc()  # TODO: fill in procedure name and parameters to query a row from Users table
        # TODO: make sure it returns None if the user does not exist
