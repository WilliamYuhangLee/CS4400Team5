from enum import Enum

from flask_login import UserMixin

from app import db, login_manager


@login_manager.user_loader
def load_user(user_id):
    return User.get_by_username(user_id)


class DatabaseError(Exception):
    pass


class User(UserMixin):

    class Status(Enum):
        DECLINED = "DECLINED"
        APPROVED = "APPROVED"
        PENDING = "PENDING"

    def __init__(self, username, password, first_name, last_name, is_visitor, status=Status.PENDING):
        self.username = username
        self.password = password
        self.first_name = first_name
        self.last_name = last_name
        self.status = status
        self.is_visitor = is_visitor

    def create(self):
        cur = db.connection.cursor()
        args = (self.username, self.password, self.first_name, self.last_name, int(self.is_visitor), "")
        cur.callproc("register_user", args)
        results = cur.fetchone()
        cur.close()
        db.connection.commit()
        error = results[0]
        print("error:", error)
        if error:
            raise DatabaseError("Fail to create user in database: " + error)

    def delete(self):
        cur = db.connection.cursor()
        args = (self.username, "")
        args = cur.callproc("delete_user", args)
        _, error = args
        if error is not None:
            raise DatabaseError("Fail to delete user from database!")

    def add_email(self, email):
        cur = db.connection.cursor()
        args = (self.username, email, "")
        args = cur.callproc("add_email", args)
        _, _, error = args
        if error is not None:
            raise DatabaseError("Fail to add email of user to database!")

    def delete_email(self, email):
        cur = db.connection.cursor()
        args = (email, "")
        args = cur.callproc("delete_email", args)
        _, error = args
        if error is not None:
            raise DatabaseError("Fail to delete email of user from database!")

    def get_id(self):
        return self.username

    @staticmethod
    def change_status(username, status):
        cur = db.connection.cursor()
        args = (username, status, "")
        args = cur.callproc("manage_user", args)
        _, _, error = args
        if error is not None:
            raise DatabaseError("Fail to change status of user!")

    @staticmethod
    def get_by_email(email):
        cur = db.connection.cursor()
        args = (email, "", "", "", "", "", 0, 0, "")
        args = cur.callproc("query_user_by_email", args)
        _, username, password, status, first_name, last_name, is_visitor, is_employee, error = args
        if error is not None:
            print("Query user by email failed:", error)
            return None
        user = User(username, password, status, first_name, last_name, is_visitor)
        if is_employee:
            args = (username, "", "", "", "", "", "", "", "")
            args = cur.callproc("query_employee_by_username", args)
            _, employee_id, phone, address, city, state, zip_code, title, error = args
            if error is not None:
                print("Query employee by username failed:", error)
                return None
            user = Employee(user, employee_id, phone, address, city, state, zip_code, title)
        return user

    @staticmethod
    def get_by_username(username):
        cur = db.connection.cursor()
        args = (username, "", "", "", "", 0, 0, "")
        args = cur.callproc("query_user_by_username", args)
        _, password, status, first_name, last_name, is_visitor, is_employee, error = args
        if error is not None:
            print("Query user by username failed:", error)
            return None
        user = User(username, password, status, first_name, last_name, is_visitor)
        if is_employee:
            args = (username, "", "", "", "", "", "", "", "")
            args = cur.callproc("query_employee_by_username", args)
            _, employee_id, phone, address, city, state, zip_code, title, error = args
            if error is not None:
                print("Query employee by username failed:", error)
                return None
            user = Employee(user, employee_id, phone, address, city, state, zip_code, title)
        return user


class Employee(User):
    def __init__(self, user, employee_id, phone, address, city, state, zip_code, title):

        if user is None:
            raise ValueError("Employee must be constructed with a valid User!")
        else:
            super().__init__(user.username, user.password, user.first_name, user.last_name, user.status, user.is_visitor)

        self.employee_id = employee_id
        self.phone = phone
        self.address = address
        self.city = city
        self.state = state
        self.zip_code = zip_code
        self.title = title

    def create(self):

        # Call User's create first
        super().create()
        # If successful, insert this into employee table
        cur = db.connection.cursor()
        args = (self.username, self.phone, self.address, self.city, self.state, self.zip_code, self.title, "")
        args = cur.callproc("register_employee", args)
        _, _, _, _, _, _, _, error = args
        if error is not None:
            self.delete()
            raise DatabaseError("Fail to create employee in database!")
