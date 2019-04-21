from flask import render_template, request, jsonify
from flask_login import login_required, current_user
from . import bp
from app.util import db_procedure, DatabaseError
from app.models import User


@bp.route("/home")
@login_required
def home():
    return render_template("home-administrator.html", title="Home")


@bp.route("/manage_user")
@login_required
def manage_user():
    result, error = db_procedure("filter_user", ("", "", ""))
    if error:
        raise DatabaseError("An error occurred when getting all users: " + error)
    users = []
    for row in result:
        users.append({"username": row[0], "email_count": row[1], "user_type": row[2], "status": row[3]})
    return render_template("administrator-manage-user.html", title="Manage Users", users=users)


@bp.route("/manage_user/_send_data", methods=["POST"])
@login_required
def manage_user_send_data():
    username = request.args.get("username")
    status = request.args.get("status", type=User.Status.coerce)
    if current_user.status == status:
        return jsonify({"result": False, "message": "The user status has not been changed."})
    if status == User.Status.PENDING.value:
        return jsonify({"result": False, "message": "You can not change a user's status to PENDING!"})
    if current_user.status == User.Status.APPROVED.value:
        return jsonify({"result": False, "message": "You can not change an approved user's status!"})
    args = (username, status)
    result, error = db_procedure("manage_user", args)
    if error:
        return jsonify({"result": False, "message": "An internal error prevented the user's status from being updated: " + error})
    current_user.status = User.Status[status]
    return jsonify({"result": True, "message": "Successfully updated the user's status."})


@bp.route("/manage_site")
@login_required
def manage_site():
    result, error = db_procedure("filter_site_adm", ("", "", 0))
    if error:
        raise DatabaseError("An error occurred when getting all sites: " + error)
    sites = []
    for row in result:
        sites.append({
            "site_name": row[0],
            "manager_name": row[1],
            "open_every_date": row[2]
        })
    return render_template("administrator-manage-site.html", title="Manage Sites", sites=sites)


@bp.route("/manage_site/_send_data", methods=["DELETE"])
@login_required
def manage_site_send_data():
    site_name = request.args.get("site_name", type=str)
    result, error = db_procedure("delete_site", (site_name,))
    if error:
        return jsonify({"result": False, "message": "An error occurred preventing deletion of the site: " + error})
    result, error = db_procedure("filter_site_adm", ("", "", 0))
    if error:
        raise DatabaseError("An error occurred when getting all sites: " + error)
    sites = []
    for row in result:
        sites.append({
            "site_name": row[0],
            "manager_name": row[1],
            "open_every_date": row[2]
        })
    return jsonify({"result": True, "message": "Successfully deleted site.", "sites": sites})

@bp.route("/edit-site")
@login_required
def edit_site():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/create-site")
@login_required
def create_site():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/manage-transit")
@login_required
def manage_transit():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/edit-transit")
@login_required
def edit_transit():
    return "Not implemented yet!"  # TODO: implement this method


@bp.route("/create-transit")
@login_required
def create_transit():
    return "Not implemented yet!"  # TODO: implement this method
