from flask import render_template, jsonify, request, flash
from flask_login import login_required, current_user, fresh_login_required

from . import bp
from .forms import ManageProfileForm
from app.models import Employee, Transit
from app.util import validate_date, db_procedure, DatabaseError, process_phone


@bp.route("/home")
@login_required
def home():
    return render_template("home-user.html", title="Home")


@bp.route("/take-transit")
@login_required
def take_transit():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/transit-history")
@login_required
def transit_history():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/manage_profile", methods=["GET", "POST"])
@fresh_login_required
def manage_profile():
    form = ManageProfileForm()
    if form.validate_on_submit():
        if form.submit.data:
            user = current_user  # type: Employee
            user.first_name = form.first_name.data
            user.last_name = form.last_name.data
            user.phone = process_phone(form.phone.data)
            user.is_visitor = form.visitor.data
            user.update()
            for email_form in form.emails.entries:
                user.add_email(email_form.email.data)
            flash("Your account has been updated!", category="success")
        elif form.add.data:
            form.add_email()
        else:
            form.delete_email()
    else:
        form.populate(current_user)
    return render_template("user-manage-profile.html", title="Manage Account", form=form)
