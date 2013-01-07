var flipper = function(){
	$('.flip_button').click(function(e){
		e.preventDefault();
		$(this).parents('.ticket_partial_div').css('overflow', 'visible');
		$(this).parents('.flip-container').toggleClass('flip-container-clicked');		
	});
}

var changeSpan = function(){
	var windowWidth = $(window).width();
	$('#outer').height($(window).height());
	if (windowWidth <= 1400){
		$('.ticket_partial_div').each(function(){
			$(this).removeClass('span3');
			$(this).addClass('span4');
			$(this).css('max-width', '400px');			
		});
	}else {
		$('.ticket_partial_div').each(function(){
			$(this).removeClass('span4');
			$(this).addClass('span3');
			$(this).css('max-width', '280px');		
		});
	}
}

var seatView = function(){
	$('.seat_view_button').toggle(function(e) {
		e.preventDefault();
		parent = $(this).parents(); 
		parent.siblings(".seat_view_image").fadeIn('fast');
		},
		function(e){
			e.preventDefault();
			parent = $(this).parents();
			parent.siblings(".seat_view_image").fadeOut('fast')				
		});
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
	
	changeSpan();
	
	$(window).resize(function(){
		changeSpan();
	});

	
	colorBorders();
	flipper();
	seatView();
});
