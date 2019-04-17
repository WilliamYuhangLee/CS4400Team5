from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, FormField, FieldList
from wtforms.validators import DataRequired, Email, EqualTo
from app.util import db_procedure, DatabaseError


class EmailEntryForm(FlaskForm):
    email = StringField(validators=[DataRequired(), Email(message="The email has been registered!")])

    def validate_email(self, email_field):
        args = (email_field.data,)
        result, error = db_procedure("check_email", args)  # return True if valid, False otherwise
        if error:
            raise DatabaseError("An error occurred when validating email with database: " + error)
        return result


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
        args = (username_field.data,)
        result, error = db_procedure("check_username", args)  # return True if valid, False otherwise
        if error:
            raise DatabaseError("An error occurred when validating username with database: " + error)
        return result


class LoginForm(FlaskForm):
    email = StringField(label="Email", validators=[DataRequired(), Email(message="Please enter a valid email address.")])
    password = PasswordField(label="Password", validators=[DataRequired()])
    remember_me = BooleanField(label="Remember Me")
    submit = SubmitField("Sign in")
