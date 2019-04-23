from flask_login import current_user
from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField, DateField, SubmitField
from wtforms.validators import InputRequired, ValidationError
from app.util import db_procedure, DatabaseError


class EventDetailForm(FlaskForm):
    event = StringField(label="Event", render_kw={"readonly": True})
    site = StringField(label="Site", render_kw={"readonly": True})
    start_date = StringField(label="Start Date", render_kw={"readonly": True})
    end_date = StringField(label="End Date", render_kw={"readonly": True})
    ticket_price = IntegerField(label="Capacity", render_kw={"readonly": True})
    tickets_remaining = IntegerField(label="Tickets Remaining", render_kw={"readonly": True})
    description = StringField(label="Description", render_kw={"readonly": True})
    visit_date = DateField(label="Visit Date", validators=[InputRequired()])
    submit = SubmitField(label="Log Visit")

    def validate_visit_date(self, field):
        result, error = db_procedure("check_log_event", (current_user.username, self.site.data, self.event.data,
                                                         self.start_date.data, field.data))
        if error:
            raise DatabaseError(error, "check_log_event")
        if not result[0][0]:
            raise ValidationError("You have logged this visit already!")


class SiteDetailForm(FlaskForm):
    site = StringField(label="Site", render_kw={"readonly": True})
    open_everyday = StringField(label="Open Everyday", render_kw={"readonly": True})
    address = StringField(label="Address", render_kw={"readonly": True})
    visit_date = DateField(label="Visit Date", validators=[InputRequired()])
    submit = SubmitField(label="Log Visit")

    def validate_visit_date(self, field):
        result, error = db_procedure("check_log_site", (current_user.username, self.site.data, field.data))
        if error:
            raise DatabaseError(error, "check_log_site")
        if not result[0][0]:
            raise ValidationError("You have logged this visit already!")
