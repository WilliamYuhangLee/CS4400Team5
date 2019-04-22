from flask_wtf import FlaskForm
from wtforms import StringField, DecimalField, IntegerField, SelectMultipleField, SubmitField
from wtforms.validators import InputRequired


class EditEventForm(FlaskForm):
    name = StringField(label="Name", render_kw={"readonly": True})
    price = DecimalField(label="Price ($)", render_kw={"readonly": True})
    start_date = StringField(label="Start Date", render_kw={"readonly": True})
    end_date = StringField(label="End Date", render_kw={"readonly": True})
    minimum_staff_required = IntegerField(label="Minimum Staff Required", render_kw={"readonly": True})
    capacity = IntegerField(label="Capacity", render_kw={"readonly": True})
    staff_assigned = SelectMultipleField(label="Staff Assigned", validators=[InputRequired()])
    description = StringField(label="Description")
    submit = SubmitField(label="Update")
