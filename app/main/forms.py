from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField, FieldList, FormField, SelectField
from wtforms.widgets import PasswordInput
from wtforms.validators import DataRequired, Email, EqualTo, ValidationError, Regexp, Length, InputRequired

from app.models import Employee
from app.util import db_procedure, DatabaseError, process_phone


class LoginForm(FlaskForm):
    email = StringField(label="Email", validators=[DataRequired(), Email(message="Please enter a valid email address.")])
    password = PasswordField(label="Password", validators=[DataRequired()])
    remember_me = BooleanField(label="Remember Me")
    submit = SubmitField("Sign in")


class EmailEntryForm(FlaskForm):
    email = StringField(render_kw={'readonly': True})
    remove = SubmitField(label="Remove")


class RequiredIf(object):
    """
    a validator which makes a field required if another field is set and has a truthy value
    """
    def __init__(self, required_field_name, message=None):
        self.required_field_name = required_field_name
        self.message = message

    def __call__(self, form, field):
        required_field = form._fields.get(self.required_field_name)
        if required_field is None:
            raise Exception('No field named "%s" in form' % self.required_field_name)
        if bool(required_field.data):
            DataRequired(message=self.message)(form, field)


class UserRegistrationForm(FlaskForm):
    first_name = StringField(label="First Name", validators=[DataRequired("Please enter your first name.")])
    last_name = StringField(label="Last Name", validators=[DataRequired("Please enter your last name.")])
    username = StringField(label="Username", validators=[DataRequired()],
                           description="A valid username must be unique and not more than 50 characters long.")
    password = PasswordField(label="Password", widget=PasswordInput(hide_value=False),
                             validators=[DataRequired(),
                                         Length(min=8, message="A valid password must be at least 8 characters long.")])
    confirm_password = PasswordField(label="Confirm Password", widget=PasswordInput(hide_value=False),
                                     validators=[DataRequired(),
                                                 EqualTo("password", "The passwords you entered do not match!")])
    emails = FieldList(FormField(EmailEntryForm))
    email = StringField(label="Email", validators=[RequiredIf(required_field_name="add")])
    add = SubmitField(label="Add")
    visitor = BooleanField(label="Create Visitor Account")
    submit = SubmitField(label="Sign up")

    def validate_username(self, username_field):
        args = (username_field.data,)
        result, error = db_procedure("check_username", args)  # return True if valid, False otherwise
        if error:
            raise DatabaseError(error, "validating username with database")
        if not result[0][0]:
            raise ValidationError("This username has been taken. Please enter another one.")

    def validate_email(self, email_field):
        if self.add.data:
            args = (email_field.data,)
            result, error = db_procedure("check_email", args)  # return True if valid, False otherwise
            if error:
                raise DatabaseError(error, "validating email with database")
            if not result[0][0]:
                raise ValidationError("This email has been taken.")
        if self.submit.data:
            if len(self.emails.entries) == 0:
                raise ValidationError("You must enter at least one email!")

    def add_email(self):
        form = EmailEntryForm()
        form.email.data = self.email.data
        self.email.data = None
        self.emails.append_entry(form)

    def delete_email(self):
        for form in self.emails.entries:
            if form.remove.data:
                self.emails.entries.remove(form)
                break


class EmployeeRegistrationForm(UserRegistrationForm):
    title = SelectField(label="User Type", validators=[DataRequired()], choices=Employee.Title.choices(),
                        coerce=Employee.Title.coerce)
    phone = StringField(label="Phone",
                        validators=[DataRequired("Please enter your phone number."),
                        Regexp(regex=r"^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$",
                               message="Please enter a valid US 10-digit phone number.")])
    address = StringField(label="Address", validators=[DataRequired("Please enter your address.")])
    city = StringField(label="City", validators=[DataRequired("Please enter your city.")])
    state = SelectField(label="State", validators=[InputRequired()], choices=Employee.State.choices(),
                        coerce=Employee.State.coerce, default=Employee.State.GA.value)
    zip_code = StringField(label="Zip code", validators=[DataRequired(),
                                                         Length(min=5, max=5,
                                                                message="A valid zip code must be 5 digits.")])

    def validate_phone(self, phone_field):
        result, error = db_procedure("check_phone", (process_phone(phone_field.data),))
        if error:
            raise ValidationError("Please enter a valid US 10-digit phone number.")
        if not result[0][0]:
            raise ValidationError("This phone number has been claimed by another user.")
