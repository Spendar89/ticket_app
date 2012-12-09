$(document).ready(function(){
    $(".datepicker").datepicker({dateFormat: "m-d-yy"} );
    $(".slider").slider({
            range: true,
            min: 10,
            max: 500,
            values: [100, 200],
            slide: function(event, ui) {
                $( "#amount" ).html( "Price Range:  $" + ui.values[ 0 ] + "  -  $" + ui.values[ 1 ] );
                $('#price_min').val(ui.values[0]);
                $('#price_max').val(ui.values[1]);

            }
   });
   $( "#amount" ).html( "Price Range:  $" + $( ".slider" ).slider( "values", 0 ) +
               "  -  $" + $( ".slider" ).slider( "values", 1 ) );

});