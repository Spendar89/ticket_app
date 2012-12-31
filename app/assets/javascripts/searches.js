var flipper = function(){
	$('.flip_button').click(function(e){
		e.preventDefault();
		$(this).parents('.ticket_partial_div').css('overflow', 'visible');
		$(this).parents('.flip-container').toggleClass('flip-container-clicked');		
	});
}

var seatView = function(){
	$('.popover-with-html').on('click', function(e) {e.preventDefault(); return true;});
	$('.popover-with-html').popover({ html : true });
}

var colorBorders = function(){
	$('.green').css('border', '4pt solid #76996B');
	$('.yellow').css('border', '4pt solid #CDDE7D');
	$('.red').css('border', '4pt solid #E66360');
}

$(document).ready(function(){
		
	$(".update_team_button" ).click(function(){
		$('#new_team_loader_div').fadeIn('slow');
		$('#new_team_loader_div').height($(document).height());
		
	})
	
	//calendar 
    $(".datepicker").datepicker({dateFormat: "m-d-yy"} );
	//ui_slider
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
	
	//price-range slider
	$( "#amount_min" ).html( "$" + $( ".slider" ).slider( "values", 0 ));
	$( "#amount_max" ).html( "$" + $( ".slider" ).slider( "values", 1 ));

	colorBorders();
	flipper();
	seatView();
});
