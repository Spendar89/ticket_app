$(document).ready(function(){
    $(".datepicker").datepicker({dateFormat: "m-d-yy"} );
    $(".slider").slider({
            range: true,
            min: 10,
            max: 800,
            values: [100, 200],
            slide: function(event, ui) {
                $( "#amount_min" ).html( "$" + ui.values[ 0 ]);
                $( "#amount_max" ).html( "$" + ui.values[ 1 ]);
                $('#price_min').val(ui.values[0]);
                $('#price_max').val(ui.values[1]);
            }
   });


   $( "#amount_min" ).html( "$" + $( ".slider" ).slider( "values", 0 ));
   $( "#amount_max" ).html( "$" + $( ".slider" ).slider( "values", 1 ));


  $('.bar').ajaxStart(function(){
    $(this).css('width', '0px');
    $('.progress').fadeIn();
    $(this).animate({width: '+=100%'}, 9000);
  }).ajaxStop(function(){
    $(this).stop();
    $(this).animate({width: '+=100%'}, 100);
    $('.progress').fadeOut();
  });

});



