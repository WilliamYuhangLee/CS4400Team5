from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, FieldList, BooleanField
from wtforms.validators import InputRequired, Regexp, ValidationError

from app.util import db_procedure, DatabaseError
from app.models import Employee
from app.main.forms import EmailEntryForm, RequiredIf


class ManageProfileForm(FlaskForm):
    first_name = StringField(label="First Name", validators=[InputRequired("Please enter your first name.")])
    last_name = StringField(label="Last Name", validators=[InputRequired("Please enter your last name.")])
    username = StringField(render_kw={'readonly': True})
    site_name = StringField(render_kw={'readonly': True})
    employee_id = StringField(render_kw={'readonly': True})
    phone = StringField(label="Phone",
                        validators=[InputRequired("Please enter your phone number."),
                        Regexp(regex=r"^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$",
                               message="Please enter a valid US 10-digit phone number.")])
    address = StringField(render_kw={'readonly': True})
    emails = FieldList(EmailEntryForm)
    email = StringField(label="Email", validators=[RequiredIf(required_field_name="add")])
    add = SubmitField(label="Add")
    visitor = BooleanField(label="Visitor Account")
    submit = SubmitField(label="Sign up")

    def validate_email(self, email_field):
        if self.add.data:
            args = (email_field.data,)
            result, error = db_procedure("check_email", args)  # return True if valid, False otherwise
            if error:
                raise DatabaseError("An error occurred when validating email with database: " + error)
            if not result[0][0]:
                raise ValidationError("This email has been taken.")
        if self.submit.data:
            if len(self.emails.entries) == 0:
                raise ValidationError("You must enter at least one email!")

    def add_email(self):
        form = EmailEntryForm()
        form.email = self.email.data
        self.email.data = None
        self.emails.append_entry(form)

    def delete_email(self):
        for form in self.emails:
            if form.remove.data:
                self.emails.entries.remove(form)
                break

    def populate(self, user):
        """
        Populate the form's fields with a given user model
        :param user: the object from which information is drawn to populate the form
        :type user: Employee
        """
        self.first_name.data = user.first_name
        self.last_name.data = user.last_name
        self.username.data = user.username
        self.employee_id.data = user.employee_id
        self.phone.data = user.phone
        self.address.data = user.address
        self.visitor.data = user.is_visitor

        args = (user.username,)
        result, error = db_procedure("query_employee_sitename", args)
        if error:
            raise DatabaseError("An error occurred when query user's site: " + error)
        self.site_name.data = result[0][0]

        result, error = db_procedure("query_email_by_username", args)
        if error:
            raise DatabaseError("An error occurred when query user's emails: " + error)
        for row in result:
            subform = EmailEntryForm()
            subform.email.data = row[0]
            self.emails.append_entry(subform)
