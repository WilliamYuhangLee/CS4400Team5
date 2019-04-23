from flask_wtf import FlaskForm
from wtforms import StringField, DecimalField, IntegerField, SelectMultipleField, SubmitField, DateField, TextAreaField, HiddenField
from wtforms.validators import InputRequired, ValidationError, DataRequired, NumberRange
from app.util import db_procedure, DatabaseError


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

    def validate_staff_assigned(self, field):
        if len(field.data) < self.minimum_staff_required.data:
            raise ValidationError("The number of staff assigned must not be fewer than the minimum staff required!")


class CreateEventForm(FlaskForm):
    name = StringField(label="Name", validators=[DataRequired()])
    site_name = HiddenField(render_kw={"readonly": True})
    price = DecimalField(label="Price ($)", validators=[InputRequired(), NumberRange(min=0, message="Price must not be negative!")])
    capacity = IntegerField(label="Capacity", validators=[InputRequired(), NumberRange(min=1, message="Capacity must be at least 1!")])
    minimum_staff_required = IntegerField(label="Minimum Staff Required",
                                          validators=[InputRequired(), NumberRange(min=1, message="At least 1 staff must be assigned!")])
    start_date = DateField(label="Start Date", validators=[InputRequired(), ])
    end_date = DateField(label="End Date", validators=[InputRequired()])
    description = TextAreaField(label="Description", validators=[DataRequired()])
    assign_staff = SelectMultipleField(label="Assign Staff", validators=[InputRequired()])

    def valid_name_date(self):
        result, error = db_procedure("check_event", (self.site_name.data, self.name.data, self.start_date.data))
        if error:
            raise DatabaseError(error, "check_event")
        return result[0][0]

    def valid_start_end_date(self):
        """
        Check if the start date and end date are valid (not overlapping with other events with the same name and site)
        :return: (start_date_is_valid, end_date_is_valid)
        :rtype: (bool, bool)
        """
        result, error = db_procedure("check_overlapping", (self.site_name.data, self.name.data, self.start_date.data, self.end_date.data))
        if error:
            raise DatabaseError(error, "check_overlapping")
        return result[0]

    def validate_name(self, field):
        if not self.valid_name_date():
            raise ValidationError(message="The event name and start date must be unique for this site!")

    def validate_start_date(self, field):
        if not self.valid_name_date():
            raise ValidationError(message="The event name and start date must be unique for this site!")
        if not self.valid_start_end_date()[0]:
            raise ValidationError(
                message="The start date must not overlap with another event on this site with the same name!")

    def validate_end_date(self, field):
        if not self.valid_start_end_date()[1]:
            raise ValidationError(
                message="The end date must not overlap with another event on this site with the same name!")

    def validate_assign_staff(self, field):
        if len(field.data) < self.minimum_staff_required.data:
            raise ValidationError("The number of staff assigned must not be fewer than the minimum staff required!")
