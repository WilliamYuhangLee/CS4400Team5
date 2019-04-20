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
    // $('#contain_site').on('change', function () {
    //     table.columns(1).search( this.value ).draw();
    // } );
    $('#transport_type').on('change', function () {
        table.columns(2).search(this.value).draw();
    });
    $('#log_transit').on('click', {site_name:""}, function () {//missing trigger for site
        var route = table.cell('.selected', 0).data();
        var type = table.cell('.selected', 1).data();
        var date = $('#transit_date').val();
        $.getJSON('Flask.url_for("take_transit")', function() {
            console.log(route,type,date);
        });
    });
} );

