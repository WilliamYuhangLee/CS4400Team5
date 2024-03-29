from enum import Enum
from datetime import datetime
from functools import wraps
from flask import flash, abort
from flask_login import current_user, login_required
from app import db


class DatabaseError(Exception):
    def __init__(self, dberror=None, message=None):
        result = "An error occurred during DB operation"
        if message is not None:
            result += " (%s)" % message
        if dberror is not None:
            result += ": " + dberror
        super(DatabaseError, self).__init__(result)


class EnumAttribute(Enum):
    def __str__(self):
        return self.value

    @classmethod
    def choices(cls):
        return [(choice.value, choice.value) for choice in cls]

    @classmethod
    def coerce(cls, item):
        if isinstance(item, cls):
            return item.value
        elif isinstance(item, str) and item.upper() in cls.__members__:
            return item.upper()
        else:
            raise ValueError("The coerced value is not a member of %s class." % cls.__name__)


def db_procedure(procedure_name, args):
    """
    A handler method for calling database procedures.

    :param procedure_name: the name of the procedure as specified in the database
    :type procedure_name: str
    :param args: arguments to pass in to the procedure
    :type args: tuple
    :return: a 2D tuple for result (becomes () if there is error), an error message (None if no error)
    :rtype: (tuple, str)
    """

    cur = db.connection.cursor()
    result, error = (), None
    try:
        cur.callproc(procedure_name, args)
        result = cur.fetchall()
    except:
        error = db.connection.error()
    finally:
        cur.close()
        db.connection.commit()
    return result, error


def process_phone(phone):
    """
    Remove all non-numeric characters (including space) from a phone number
    :param phone: a phone number as a string that needs to be processed
    :type phone: str
    :return: the phone number strip of +-() and space
    :rtype: str
    """
    return ''.join(c for c in phone if c not in "+() -")


def validate_date(date_string):
    """
    Check if a data string is in concordance with the YYYY-MM-DD format.

    :param date_string: a date string to validate
    :type date_string: str
    :return: True if the string is valid, False otherwise
    :rtype: bool
    """
    try:
        datetime.strptime(date_string, '%Y-%m-%d')
        return True
    except ValueError:
        print("Incorrect data format, should be YYYY-MM-DD (got %s)" % date_string)
        return False


def role_required(role="ANY"):
    def wrapper(func):
        @wraps(func)
        def decorated_view(*args, **kwargs):

            permission_flash_message = "You do not have the permission to view this page."

            login_func = login_required(func)

            if role == "ANY" or role == "USER":
                return login_func(*args, **kwargs)
            elif role == "VISITOR":
                if current_user.is_visitor:
                    return login_func(*args, **kwargs)
                else:
                    flash(message=permission_flash_message)
                    abort(403)
            elif role == "EMPLOYEE":
                if current_user.is_employee():
                    return login_func(*args, **kwargs)
                else:
                    flash(message=permission_flash_message)
                    abort(403)
            elif role == "STAFF" or role == "MANAGER" or role == "ADMINISTRATOR":
                if current_user.is_employee() and current_user.title == role:
                    return login_func(*args, **kwargs)
                else:
                    flash(message=permission_flash_message)
                    abort(403)
            else:
                raise ValueError("Invalid argument for @role_required()!")
        return decorated_view
    return wrapper
