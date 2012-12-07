$(document).ready(function(){
    $(".datepicker").datepicker({dateFormat: "m-d-yy"} );
    $(".slider").slider({
            range: true,
            min: 10,
            max: 500,
            values: [100, 200],
            slide: function(event, ui) {
                $("#price_min, #show_price_min").html("min: $"+ui.values[0]);
                $("#price_max, #show_price_max").html("max: $"+ui.values[1]);

            }
   });

});