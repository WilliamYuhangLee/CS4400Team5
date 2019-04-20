$(document).ready(function () {
    $('#take_transit').DataTable({
        "ajax": 'data.json',
        columns: [
            { data: "Route" },
            { data: "Transport Type" },
            { data: "Price" },
            { data: "#Connected Sites" }
        ],
        columnDefs: [{
            orderable: false,
            className: 'select-checkbox',
            targets: 0
        }],
        select: {
            style: 'os',
            selector: 'td:first-child'
        },
        order: [[1, 'asc']]
    });

    $('#transit_history').DataTable({
        "ajax": 'data.json',
        columns: [
            { data: "Date" },
            { data: "Route" },
            { data: "Transport Type" },
            { data: "Price" }
        ],
    });

    $('#user_list').DataTable({
        "ajax": 'data.json',
        columns: [
            { data: "Username" },
            { data: "Email Count" },
            { data: "User Type" },
            { data: "Status" }
        ],
        columnDefs: [{
            orderable: false,
            className: 'select-checkbox',
            targets: 0
        }],
        select: {
            style: 'os',
            selector: 'td:first-child'
        },
        order: [[1, 'asc']]
    });


    // $('#contain_site').on('change', function () {
    //     table.columns(1).search( this.value ).draw();
    // } );
    $('#transport_type').on('change', function () {
        table.columns(2).search(this.value).draw();
    });
    $('#user_type').on('change', function () {
        table.columns(2).search(this.value).draw();
    });
    $('#user_status').on('change', function () {
        table.columns(3).search(this.value).draw();
    });
    $('#username_search').on('change', function () {
        table.columns(0).search(this.value).draw();
    });
    $('#log_transit').on('click', {site_name:""}, function () {//missing trigger for site
        var route = table.cell('.selected', 0).data();
        var type = table.cell('.selected', 1).data();
        var date = $('#transit_date').val();
        $.getJSON('Flask.url_for("take_transit")', (route,type,date), function() {
            console.log(route,type,date);
        });
    });
    $('#admin_manage_user_decline').on('click', {site_name:""}, function () {//missing trigger for site
        var username = table.cell('.selected', 0).data();
        var usertype = table.cell('.selected', 1).data();
        var status = "Declined"
        $.getJSON('Flask.url_for("admin_manage_user")', (username,usertype,status), function() {
            console.log(username,usertype,status);
        });
    });
    $('#admin_manage_user_approve').on('click', {site_name:""}, function () {//missing trigger for site
        var user = table.cell('.selected', 0).data();
        var usertype = table.cell('.selected', 2).data();
        var status = "Approved";
        $.getJSON('Flask.url_for("admin_manage_user")', (username,usertype,status), function() {
            console.log(username,usertype,status);
        });
    });
} );

