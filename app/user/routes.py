from flask import render_template, request
from flask_login import login_required

from . import bp


@bp.route("/home")
@login_required
def home():
    is_visitor = request.args.get("is_visitor", False, lambda x: x if isinstance(x, bool) else x.lower() == "true")
    if is_visitor:
        return render_template("home-user-visitor.html", title="Home")
    else:
        return render_template("home-user.html", title="Home")


@bp.route("/take-transit")
def take_transit():
    pass  # TODO: implement this method
