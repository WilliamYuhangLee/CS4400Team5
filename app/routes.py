from flask import flash, redirect, url_for, render_template, request
from flask import current_app as app
from flask_login import login_user, login_required

from app import bcrypt
from app.models import User
from app.forms import LoginForm, UserRegistrationForm


@app.route("/register/user", methods=["GET", "POST"])
def register_user():
    form = UserRegistrationForm()
    if form.validate_on_submit():
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode("utf-8")
        user = User(username=form.username.data,
                    password=hashed_password,
                    first_name=form.first_name.data,
                    last_name=form.last_name.data)  # TODO: complete user instantiation logic
        user.create()  # TODO: implement User.create() method
        login_user(user, remember=True)
        flash("Your account has been created! You are now logged in.", category="success")
        return redirect(url_for("login"))
    return render_template("register.html", title="Registration", form=form)  # TODO: make sure register.html is implemented


@app.route("/login", methods=["GET", "POST"])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        user = User.get_by_email(form.email.data)  # TODO: implement User.get_by_email() method
        if user and bcrypt.check_password_hash(user.password, form.password.data):  # TODO: make sure user can be None
            login_user(user, remember=form.remember_me.data)
            next_page = request.args.get("next")
            if next_page:
                return redirect(next_page)
            else:
                return redirect(url_for("home"))
        else:
            flash("Login failed. Please check your email and password.", category="danger")
    return render_template("login.html", title="Login", form=form)  # TODO: make sure login.html is implemented


@login_required
@app.route("/home")
def home():
    pass  # TODO: implement homepage
