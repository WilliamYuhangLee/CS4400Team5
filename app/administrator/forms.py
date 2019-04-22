from flask_wtf import FlaskForm
from wtforms import StringField, SelectField, BooleanField, DecimalField, SelectMultipleField, HiddenField, SubmitField
from wtforms.validators import InputRequired, Length, NumberRange, ValidationError
from app.util import db_procedure, DatabaseError
from app.models import Transit


class EditSiteForm(FlaskForm):

    @staticmethod
    def get_free_managers():
        args = ()
        result, error = db_procedure("get_free_managers", args)
        if error:
            raise DatabaseError("An error occurred when getting all free managers: " + error)
        return [row[0] for row in result]

    name = StringField(label="Name", validators=[InputRequired()])  # TODO: check duplicate validation
    zip_code = StringField(label="Zip Code", validators=[InputRequired(), Length(min=5, max=5, message="A valid zip code must be 5 digits.")])
    address = StringField(label="Address", default="")
    manager = SelectField(label="Manager", validators=[InputRequired()], coerce=str)
    open_everyday = BooleanField(label="Open Everyday")
    submit = SubmitField("Submit")


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
                raise DatabaseError("An error occurred when checking if a transit already exists: " + error)
            if result[0][0] == 0:
                raise ValidationError(message="An identical transit already exists!")

    def validate_connected_sites(self, sites_field):
        if len(sites_field.data) < 2:
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
            raise DatabaseError("An error occurred when checking if a transit already exists: " + error)
        if result[0][0] == 0:
            raise ValidationError(message="An identical transit already exists!")

    def validate_connected_sites(self, sites_field):
        if len(sites_field.data) < 2:
            raise ValidationError(message="You must select at least 2 connected sites!")
