from flask_wtf import FlaskForm
from wtforms import StringField, IntegerField, FieldList


class EventDetailForm(FlaskForm):
    event = StringField(label="Event", render_kw={"readonly": True})
    site = StringField(label="Site", render_kw={"readonly": True})
    start_date = StringField(label="Start Date", render_kw={"readonly": True})
    end_date = StringField(label="End Date", render_kw={"readonly": True})
    duration_days = IntegerField(label="Duration Days", render_kw={"readonly": True})
    staffs_assigned = FieldList(StringField(render_kw={"readonly": True}), label="Staffs Assigned")
    capacity = IntegerField(label="Capacity", render_kw={"readonly": True})
    price = IntegerField(label="Capacity", render_kw={"readonly": True})
    description = StringField(label="Description", render_kw={"readonly": True})
