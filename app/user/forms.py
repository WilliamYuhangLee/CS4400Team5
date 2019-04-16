from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, FormField, FieldList
from wtforms.validators import DataRequired, Email, EqualTo
from app import db


class EmailEntryForm(FlaskForm):
    email = StringField(validators=[DataRequired(), Email(message="The email has been registered!")])

    def validate_email(self, email_field):
        cur = db.connection.cursor()
        args = (email_field.data, 0, "")
        args = cur.callproc("check_email", args)
        _, is_unique, error = args
        if error is not None:
            print("An error occurred when checking with database for the validness of email:", error)
        return error is None and is_unique


class UserRegistrationForm(FlaskForm):
    first_name = StringField(label="First Name", validators=[DataRequired()])
    last_name = StringField(label="Last Name", validators=[DataRequired()])
    username = StringField(label="Username", validators=[DataRequired()])
    password = PasswordField(label="Password", validators=[DataRequired()])
    confirm_password = PasswordField(label="Confirm Password",
                                     validators=[DataRequired(),
                                                 EqualTo("password", "The passwords you entered do not match!")])
    emails = FieldList(FormField(EmailEntryForm), label="Email", min_entries=1)

    def add_email(self):
        """
        Add a FormField to the emails FieldList.

        :return: the added field
        :rtype: FormField
        """
        return self.emails.append_entry()

    def validate_username(self, username_field):
        cur = db.connection.cursor()
        args = (username_field.data, 0, "")
        args = cur.callproc("check_username", args)
        _, is_unique, error = args
        if error is not None:
            print("An error occurred when checking with database for the validness of username:", error)
        return error is None and is_unique


class LoginForm(FlaskForm):
    email = StringField(label="Email", validators=[DataRequired(), Email(message="Please enter a valid email address.")])
    password = PasswordField(label="Password", validators=[DataRequired()])
    remember_me = BooleanField(label="Remember Me")
    submit = SubmitField("Sign in")
