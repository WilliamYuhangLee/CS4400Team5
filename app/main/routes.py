from flask import request, redirect, url_for, flash, render_template, session
from flask_login import login_user, login_required, logout_user, current_user
from app import bcrypt
from app.models import User, Employee
from app.util import process_phone
from .forms import LoginForm, UserRegistrationForm, EmployeeRegistrationForm

from . import bp


@bp.route("/register/", methods=["GET", "POST"])
def register():
    is_employee = request.args.get("is_employee", False, lambda x: x if isinstance(x, bool) else x.lower() == "true")
    form = EmployeeRegistrationForm() if is_employee else UserRegistrationForm()
    if form.validate_on_submit():
        if form.submit.data:
            hashed_password = bcrypt.generate_password_hash(form.password.data).decode("utf-8")
            user = User(username=form.username.data,
                        password=hashed_password,
                        first_name=form.first_name.data,
                        last_name=form.last_name.data,
                        is_visitor=form.visitor.data)
            if is_employee:
                phone = process_phone(form.phone.data)
                user = Employee(user, phone, form.address.data, form.city.data, form.state.data, form.zip_code.data, form.title.data)
            user.create()
            for email_form in form.emails.entries:
                user.add_email(email_form.email.data)
            flash("Your have submitted your registration. Please wait for an administrator to approve your request.", category="success")
            return redirect(url_for(".login"))
        elif form.add.data:
            form.add_email()
        else:
            form.delete_email()
    if is_employee:
        template = "register-employee.html"
    else:
        template = "register-user.html"
    return render_template(template, title="Registration", form=form)


def redirect_authenticated_user(user):
    """
    Redirect an authenticated user to their homepage.
    :type user: User
    :return the response object corresponding to the redirected page
    :rtype werkzeug.wrappers.response.Response
    """
    next_page = request.args.get("next")
    if next_page:
        return redirect(next_page)
    if user.is_employee():
        user: Employee
        return redirect(url_for(user.title.lower() + ".home"))
    else:
        return redirect(url_for("user.home"))


@bp.route("/", methods=["GET", "POST"])
@bp.route("/login", methods=["GET", "POST"])
def login():
    if current_user.is_authenticated:
        return redirect_authenticated_user(current_user)
    form = LoginForm()
    if form.validate_on_submit():
        user = User.get_by_email(form.email.data)
        if user and bcrypt.check_password_hash(user.password, form.password.data):
            if user.status == User.Status.PENDING.value:
                flash("Your registration has not been approved. Please wait for an administrator to approve your "
                      "request or contact support if needed.", category="warning")
            elif user.status == User.Status.DECLINED.value:
                flash("Your registration has been declined. Please contact administrator for support.", category="error")
            else:
                login_user(user, remember=form.remember_me.data)
                return redirect_authenticated_user(user)
        else:
            flash("Login failed. Please check your email and password.", category="danger")
    return render_template("login.html", title="Login", form=form)


@bp.route("/logout")
@login_required
def logout():
    session.clear()
    logout_user()
    return redirect(url_for(".login"))


@bp.route("/register_options/", methods=["GET"])
def nav_register():
    return render_template("nav-register.html", title="Registration Options")


@bp.app_errorhandler(404)
def error_404(e):
    return render_template("main-error-404.html", title="Page Not Found")


@bp.app_errorhandler(403)
def error_403(e):
    return render_template("main-error-403.html", title="Permission Required")


@bp.app_errorhandler(500)
def error_500(e):
    return render_template("main-error-500.html", title="Internal Error")
