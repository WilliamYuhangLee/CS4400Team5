from app import db


class DatabaseError(Exception):
    pass


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
