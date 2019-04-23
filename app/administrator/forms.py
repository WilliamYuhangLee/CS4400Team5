from flask_wtf import FlaskForm
from wtforms import StringField, SelectField, BooleanField, DecimalField, SelectMultipleField, HiddenField, SubmitField
from wtforms.validators import InputRequired, Length, NumberRange, ValidationError, DataRequired
from app.util import db_procedure, DatabaseError
from app.models import Transit


class EditSiteForm(FlaskForm):

    name = StringField(label="Name", validators=[DataRequired()])
    old_name = HiddenField()
    zip_code = StringField(label="Zip Code", validators=[InputRequired(), Length(min=5, max=5, message="A valid zip code must be 5 digits.")])
    address = StringField(label="Address", default="")
    manager = SelectField(label="Manager", validators=[InputRequired()], coerce=str)
    open_everyday = BooleanField(label="Open Everyday")
    submit = SubmitField("Submit")

    def validate_name(self, field):
        if field.data != self.old_name.data:
            result, error = db_procedure("check_site", (field.data,))
            if error:
                raise DatabaseError(error, "check_site")
            if not result[0][0]:
                raise ValidationError("There is already a site with the same name!")


class EditTransitForm(FlaskForm):
    transport_type = StringField(label="Transport Type", render_kw={"readonly": True})
    route = StringField(label="Route", validators=[InputRequired()])
    old_route = HiddenField()
    price = DecimalField(label="Price ($)", validators=[InputRequired(), NumberRange(min=0, message="The price must not be nagative!")])
    connected_sites = SelectMultipleField(label="Connected Sites")
    submit = SubmitField(label="Update")

    def validate_route(self, route_field):
        if route_field.data != self.old_route.data:
            result, error = db_procedure("check_transit", (route_field.data, self.transport_type.data))
            if error:
                raise DatabaseError(error, "checking if a transit already exists")
            if result[0][0] == 0:
                raise ValidationError(message="An identical transit already exists!")

    def validate_connected_sites(self, sites_field):
        if not sites_field.data or len(sites_field.data) < 2:
            raise ValidationError(message="You must select at least 2 connected sites!")


class CreateTransitForm(FlaskForm):
    transport_type = SelectField(label="Transport Type", validators=[InputRequired()], choices=Transit.Type.choices())
    route = StringField(label="Route", validators=[InputRequired()])
    price = DecimalField(label="Price ($)",
                         validators=[InputRequired(), NumberRange(min=0, message="The price must not be nagative!")])
    connected_sites = SelectMultipleField(label="Connected Sites")
    submit = SubmitField(label="Create")

    def validate_route(self, route_field):
        result, error = db_procedure("check_transit", (route_field.data, self.transport_type.data))
        if error:
            raise DatabaseError(error, "checking if a transit already exists")
        if result[0][0] == 0:
            raise ValidationError(message="An identical transit already exists!")

    def validate_connected_sites(self, sites_field):
        if not sites_field.data or len(sites_field.data) < 2:
            raise ValidationError(message="You must select at least 2 connected sites!")
