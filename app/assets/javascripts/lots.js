jQuery(document).ready(function() {
  $('#lots-datatable').dataTable({
    "processing": true,
    "serverSide": true,
    "ajax": $('#lots-datatable').data('source'),
    "pagingType": "full_numbers",
    "columns": [
      {"data": "id"},
      {"data": "lot_name"},
      {"data": "terrasse_text"},
      {"data": "parking_text"},
      {"data": "city_text"},
      {"data": "expected_delivery"},
      {"data": "expected_actability"},
      {"data": "price_text"},
      {"data": "notary_fee"},
      {"data": "security_deposit"},
      {"data": "images", "orderable": false, "searchable": false},
    ]
  });
});
