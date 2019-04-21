from flask_wtf import FlaskForm
from wtforms import StringField, SelectField, BooleanField, SubmitField
from wtforms.validators import InputRequired, Length
from app.util import db_procedure, DatabaseError

class EditSiteForm(FlaskForm):

    @staticmethod
    def get_free_managers():
        args = ()
        result, error = db_procedure("get_free_managers", args)
        if error:
            raise DatabaseError("An error occurred when getting all free managers: " + error)
        return [row[0] for row in result]


    name = StringField(label="Name", validators=[InputRequired()])
    zip_code = StringField(label="Zip Code", validators=[InputRequired(), Length(min=5, max=5, message="A valid zip code must be 5 digits.")])
    address = StringField(label="Address", default="")
    manager = SelectField(label="Manager", validators=[InputRequired()], coerce=str)
    open_everyday = BooleanField(label="Open Everyday")
