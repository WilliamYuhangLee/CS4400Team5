$(document).ready(function () {
    $('#take_transit').DataTable({
        "ajax": {
            "url": "{{url_for('take_transit_get_table_data')}}",
            "dataType": "json",
            "dataSrc": "data",
            "contentType": "application/json"
        },
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


    $('#contain_site').on('change', function () {
        table.columns(1).search( this.value ).draw();
    } );
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
    $('#open_everyday').on('change', function () {
        table.columns(2).search(this.value).draw();
    });
    $('#log_transit').on('click', function () {
        var route = table.cell('.selected', 0).data();
        var type = table.cell('.selected', 1).data();
        var date = $('#transit_date').val();
        $.getJSON('Flask.url_for("user.take_transit")', (route,type,date), function() {
            console.log(route,type,date);
        });
    });
    $('#filter_take_transit').on('click', function () {
        var site = $( "#contain_site option:selected" ).text();
        $.getJSON('Flask.url_for("user.take_transit")', (site), function() {
            console.log(site);
        });
    });
    $('#filter_transit_history').on('click', function () {
        var site = $( "#contain_site option:selected" ).text();
        $.getJSON('Flask.url_for("user.transit_history")', (site), function() {
            console.log(site);
        });
    });
    $('#filter_site').on('click', function () {
        var site = $( "#contain_site option:selected" ).text();
        $.getJSON('Flask.url_for("administrator.manage_site")', (site), function() {
            console.log(site);
        });
    });
    $('#filter_manager').on('click', function () {
        var manager = $( "#contain_manager option:selected" ).text();
        $.getJSON('Flask.url_for("administrator.manage_site")', (site), function() {
            console.log(site);
        });
    });
    $('#filter_manage_site').on('click', function () {
        var manager = $( "#contain_manager option:selected" ).text();
        var site = $( "#contain_site option:selected" ).text();
        $.getJSON('Flask.url_for("administrator.manage_user")', (site), function() {
            console.log(site , manager);
        });
    });
    $('#administrator_manage_user_decline').on('click', function () {
        var username = table.cell('.selected', 0).data();
        var usertype = table.cell('.selected', 1).data();
        var status = "Declined";
        $.getJSON('Flask.url_for("administrator.manage_user")', (username,usertype,status), function() {
            console.log(username,usertype,status);
        });
    });
    $('#administrator_manage_user_approve').on('click', function () {
        var user = table.cell('.selected', 0).data();
        var usertype = table.cell('.selected', 2).data();
        var status = "Approved";
        $.getJSON('Flask.url_for("administrator.manage_user")', (username,usertype,status), function() {
            console.log(username,usertype,status);
        });
    });
} );
