from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, FieldList, FormField, SelectField
from wtforms.validators import DataRequired, Email, EqualTo, ValidationError, Regexp, Length

from app.models import Employee
from app.util import db_procedure, DatabaseError


class LoginForm(FlaskForm):
    email = StringField(label="Email", validators=[DataRequired(), Email(message="Please enter a valid email address.")])
    password = PasswordField(label="Password", validators=[DataRequired()])
    remember_me = BooleanField(label="Remember Me")
    submit = SubmitField("Sign in")


class EmailEntryForm(FlaskForm):
    email = StringField(validators=[DataRequired(), Email(message="The email has been registered!")])

    def validate_email(self, email_field):
        args = (email_field.data,)
        result, error = db_procedure("check_email", args)  # return True if valid, False otherwise
        if error:
            raise DatabaseError("An error occurred when validating email with database: " + error)
        if not result:
            raise ValidationError("This email has been taken.")


class UserRegistrationForm(FlaskForm):
    first_name = StringField(label="First Name", validators=[DataRequired("Please enter your first name.")])
    last_name = StringField(label="Last Name", validators=[DataRequired("Please enter your last name.")])
    username = StringField(label="Username", validators=[DataRequired()],
                           description="A valid username must be unique and not more than 50 characters long.")
    password = PasswordField(label="Password",
                             validators=[DataRequired(),
                                         Length(min=8, message="A valid password must be at least 8 characters long.")])
    confirm_password = PasswordField(label="Confirm Password",
                                     validators=[DataRequired(),
                                                 EqualTo("password", "The passwords you entered do not match!")])
    emails = FieldList(FormField(EmailEntryForm), label="Email", min_entries=1)
    submit = SubmitField("Sign up")

    def add_email(self):
        """
        Add a FormField to the emails FieldList.

        :return: the added field
        :rtype: FormField
        """
        return self.emails.append_entry()

    def validate_username(self, username_field):
        args = (username_field.data,)
        result, error = db_procedure("check_username", args)  # return True if valid, False otherwise
        if error:
            raise DatabaseError("An error occurred when validating username with database: " + error)
        if not result:
            raise ValidationError("This username has been taken. Please enter another one.")


class EmployeeRegistrationForm(UserRegistrationForm):
    title = SelectField(label="User Type", validators=[DataRequired()], choices=Employee.Title.choices(),
                        coerce=Employee.Title.coerce, default=Employee.Title.STAFF)
    phone = StringField(label="Phone",
                        validators=[DataRequired("Please enter your phone number."),
                        Regexp(regex=r"^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$",
                               message="Please enter a valid US 10-digit phone number.")])
    address = StringField(label="Address", validators=[DataRequired("Please enter your address.")])
    city = StringField(label="City", validators=[DataRequired("Please enter your city.")])
    state = SelectField(label="State", validators=[DataRequired()], choices=Employee.State.choices(),
                        coerce=Employee.State.coerce, default=Employee.State.GA)
    zip_code = StringField(label="Zip code", validators=[DataRequired(),
                                                         Length(min=5, max=5,
                                                                message="A valid zip code must be 5 digits.")])

    def validate_phone(self, phone):
        result, error = db_procedure("check_phone", (phone,))
        if error:
            raise DatabaseError("An error occurred when validating phone number with database: " + error)
        if not result:
            raise ValidationError("This phone number has been claimed by another user.")
