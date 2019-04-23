from flask_login import UserMixin

from app.util import db_procedure, DatabaseError, EnumAttribute


class User(UserMixin):
    class Status(EnumAttribute):
        DECLINED = "DECLINED"
        APPROVED = "APPROVED"
        PENDING = "PENDING"

    def __init__(self, username, password, first_name, last_name, is_visitor, status=Status.PENDING):
        """
        Construct a User instance with default approval status as PENDING.

        :param username: the username selected by the user
        :type username: str
        :param password: a utf-8 sequence hashed from the password entered by the user
        :type password: str
        :param first_name: the user's first name
        :type first_name: str
        :param last_name: the user's last name
        :type last_name: str
        :param is_visitor: if the user is a visitor
        :type is_visitor: bool
        :param status: the status for approval of the user's registration
        :type status: User.Status
        """
        self.username = username
        self.password = password
        self.first_name = first_name
        self.last_name = last_name
        self.is_visitor = is_visitor
        self.status = User.Status.coerce(status)

    def create(self):
        args = (self.username, self.password, self.first_name, self.last_name, self.is_visitor)
        result, error = db_procedure("register_user", args)
        if error:
            raise DatabaseError("Fail to create user in database: " + error)

    def delete(self):
        args = (self.username,)
        result, error = db_procedure("delete_user", args)
        if error:
            raise DatabaseError("Fail to delete user from database: " + error)

    def add_email(self, email):
        args = (self.username, email)
        result, error = db_procedure("add_email", args)
        if error:
            raise DatabaseError("Fail to add email of user to database: " + error)

    def delete_email(self, email):
        args = (email,)
        result, error = db_procedure("delete_email", args)
        if error:
            raise DatabaseError("Fail to delete email of user from database: " + error)

    def is_employee(self) -> bool:
        return isinstance(self, Employee)

    # Flask Login required functions
    @property
    def is_active(self):
        return self.status == User.Status.coerce(User.Status.APPROVED)

    def get_id(self):
        return self.username

    @staticmethod
    def change_status(username, status):
        args = (username, status)
        result, error = db_procedure("manage_user", args)
        if error:
            raise DatabaseError("Fail to change status of user: " + error)

    @staticmethod
    def get_by_email(email):
        args = (email,)
        result, error = db_procedure("query_user_by_email", args)
        if error:
            print("Query user by email failed: " + error)
            return None
        username, *params, is_employee = result[0]
        user = User(username, *params)
        if is_employee:
            args = (username,)
            result, error = db_procedure("query_employee_by_username", args)
            if error:
                print("Query employee by username failed: " + error)
                return None
            user = Employee(user, *result[0])
        return user

    @staticmethod
    def get_by_username(username):
        args = (username,)
        result, error = db_procedure("query_user_by_username", args)
        if error:
            print("Query user by username failed: " + error)
            return None
        *params, is_employee = result[0]
        user = User(username, *params)
        if is_employee:
            result, error = db_procedure("query_employee_by_username", args)
            if error:
                print("Query employee by username failed: " + error)
                return None
            user = Employee(user, *result[0])
        return user


class Employee(User):
    class Title(EnumAttribute):
        ADMINISTRATOR = "ADMINISTRATOR"
        MANAGER = "MANAGER"
        STAFF = "STAFF"

    class State(EnumAttribute):
        AL = 'AL'
        AK = 'AK'
        AZ = 'AZ'
        AR = 'AR'
        CA = 'CA'
        CO = 'CO'
        CT = 'CT'
        DE = 'DE'
        FL = 'FL'
        GA = 'GA'
        HI = 'HI'
        ID = 'ID'
        IL = 'IL'
        IN = 'IN'
        IA = 'IA'
        KS = 'KS'
        KY = 'KY'
        LA = 'LA'
        ME = 'ME'
        MD = 'MD'
        MA = 'MA'
        MI = 'MI'
        MN = 'MN'
        MS = 'MS'
        MO = 'MO'
        MT = 'MT'
        NE = 'NE'
        NV = 'NV'
        NH = 'NH'
        NJ = 'NJ'
        NM = 'NM'
        NY = 'NY'
        NC = 'NC'
        ND = 'ND'
        OH = 'OH'
        OK = 'OK'
        OR = 'OR'
        PA = 'PA'
        RI = 'RI'
        SC = 'SC'
        SD = 'SD'
        TN = 'TN'
        TX = 'TX'
        UT = 'UT'
        VT = 'VT'
        VA = 'VA'
        WA = 'WA'
        WV = 'WV'
        WI = 'WI'
        WY = 'WY'
        OTHER = 'OTHER'

    def __init__(self, user, phone, address, city, state, zip_code, title, employee_id=None):
        """
        Construct an Employee object with an existing User object and some additional parameters.

        :param user: the User object from which this Employee instance is constructed from
        :type user: User
        :param phone: a 10-digit US phone number, without hyphens, brackets or spaces
        :type phone: str
        :param address: the employee's home address
        :type address: str
        :param city: the employee's city
        :type city: str
        :param state: the employee's state, one of the 50 US states
        :type state: str
        :param zip_code:
        :type zip_code: str
        :param title:
        :type title: Employee.Title
        :param employee_id: generated ID for the employee, may be None if approval status is PENDING or DECLINED
        :type employee_id: str
        """
        if user is None:
            raise ValueError("Employee must be constructed with a valid User!")
        else:
            super().__init__(user.username, user.password, user.first_name, user.last_name, user.is_visitor,
                             user.status)

        self.phone = phone
        self.address = address
        self.city = city
        self.state = Employee.State.coerce(state)
        self.zip_code = zip_code
        self.title = Employee.Title.coerce(title)
        self.employee_id = employee_id

    def create(self):

        # Call User's create first
        super().create()
        # If successful, insert this into employee table
        args = (self.username, self.phone, self.address, self.city, self.state, self.zip_code, self.title)
        result, error = db_procedure("register_employee", args)
        if error:
            self.delete()
            raise DatabaseError("Fail to create employee in database: " + error)

    def update(self):
        args = (self.username, self.first_name, self.last_name, self.is_visitor, self.phone)
        result, error = db_procedure("edit_profile", args)
        if error:
            raise DatabaseError(error, "updating user profile")

    @staticmethod
    def get_free_managers():
        args = ()
        result, error = db_procedure("get_free_managers", args)
        if error:
            raise DatabaseError(error, "getting all free managers")
        return [row[0] for row in result]


class Transit:
    class Type(EnumAttribute):
        BUS = "BUS"
        MARTA = "MARTA"
        BIKE = "BIKE"

    def __init__(self, route, transport_type, price, num_of_connected_sites=None):
        self.route = route
        self.transport_type = Transit.Type.coerce(transport_type)
        self.price = price
        if num_of_connected_sites:
            self.num_of_connected_sites = num_of_connected_sites

    @staticmethod
    def get_all():
        result, error = db_procedure("get_all_transit", ())
        if error:
            raise DatabaseError(error, "querying all transits")
        transits = []
        for row in result:
            transits.append(Transit(*row))
        return transits

    @staticmethod
    def get_by_site_name(site_name):
        args = (site_name, "", "", 0, 0)
        result, error = db_procedure("filter_transit", args)
        if error:
            raise DatabaseError(error, "querying transits by site name")
        transits = []
        for row in result:
            transits.append(Transit(*row))
        return transits


class Site:

    @staticmethod
    def get_all_sites():
        result, error = db_procedure("get_all_sites", ())
        if error:
            raise DatabaseError(error, "getting all sites")
        return result
