from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, FormField, FieldList
from wtforms.validators import DataRequired, Email, EqualTo


class EmailEntryForm(FlaskForm):
    email = StringField(validators=[DataRequired(), Email()])


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


class LoginForm(FlaskForm):
    email = StringField(label="Email", validators=[DataRequired(), Email(message="Please enter a valid email address.")])
    password = PasswordField(label="Password", validators=[DataRequired()])
    remember_me = BooleanField(label="Remember Me")
    submit = SubmitField("Sign in")
