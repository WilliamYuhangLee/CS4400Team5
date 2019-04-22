from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField, DateField, SubmitField
from wtforms.validators import InputRequired


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

    def validate_visit_date(self):
        pass  # TODO: implement validation logic


class SiteDetailForm(FlaskForm):
    site = StringField(label="Site", render_kw={"readonly": True})
    open_everyday = StringField(label="Open Everyday", render_kw={"readonly": True})
    address = StringField(label="Address", render_kw={"readonly": True})
    visit_date = DateField(label="Visit Date", validators=[InputRequired()])
    submit = SubmitField(label="Log Visit")

    def validate_visit_date(self):
        pass  # TODO: implement validation logic
