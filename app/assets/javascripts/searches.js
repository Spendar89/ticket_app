
var flipper = function(){
	$('.flip_button').click(function(e){
	
		$(this).parents('.ticket_partial_div').css('overflow', 'visible');
		$(this).parents('.flip-container').toggleClass('flip-container-clicked');
	});
}

var ticketFadeIn = function(){
	$('.flip-container').each(function(){
		$(this).delay('slow').fadeIn('slow');
	});
}

var changeSpan = function(){
	var windowWidth = $(window).width();
	var windowHeight = $(window).height();
	$('#outer').height(windowHeight);
	$('#line_chart_div').height(windowWidth/6);
	if (windowWidth < 920){
		$('.header_logo').css('font-size', '30px');
		$('h1').each(function(){
			$(this).css('font-size', '15px');
			
		});
		$('.ticket_spacer').each(function(){
			$(this).removeClass('span3').addClass('span6');
			$(this).removeClass('span4');
			$(this).css('max-width', '50%')					
		});
	
	}else if (windowWidth > 920 && windowWidth < 1350){
		$('.header_logo').css('font-size', '40px');
		$('h1').each(function(){
			$(this).css('font-size', '20px');
		});
		$('.ticket_spacer').each(function(){
			$(this).removeClass('span6').removeClass('span3').addClass('span4');
			$(this).css('max-width', '400px');			
		});
	}else if (windowWidth >= 1350 & windowWidth < 1800) {
		$('.header_logo').css('font-size', '45px');
		$('h1').each(function(){
			$(this).css('font-size', '25px');
		});
		$('.ticket_spacer').each(function(){
			$(this).removeClass('span4').addClass('span3');
			$(this).css('min-width', '270px').css('max-width', '23%');		
		});
	}else{
		$('.header_logo').css('font-size', '50px');
		$('h1').each(function(){
			$(this).css('font-size', '30px');
		});
		$('.ticket_spacer').each(function(){
			$(this).removeClass('span4').addClass('span3');
			$(this).css('min-width', '278px').css('max-width', '19%');
			});
	}
}


var seatView = function(){
	$('.seat_view_button').toggle(function(e) {
		e.preventDefault();
		thisId=$(this).attr('id')
		seatViewPhoto = $('#'+thisId+'_photo'); 
		seatViewPhoto.fadeIn();
		seatViewPhoto.offset({ top: e.pageY - seatViewPhoto.height() , left: e.pageX  }).offset({ top: e.pageY - seatViewPhoto.height() - 60, left: e.pageX - 26});	
		},
		function(e){
			thisId=$(this).attr('id')
			seatViewPhoto = $('#'+thisId+'_photo'); 
			seatViewPhoto.fadeOut();		
		});
}

var colorBorders = function(){
	$('.green').css('border', '4pt solid #76996B');
	$('.yellow').css('border', '4pt solid #CDDE7D');
	$('.red').css('border', '4pt solid #E66360');
}

var tokenInput = function(){
	$("#tokeninput_search").tokenInput("/token_input", {
		tokenLimit: 1,
		onAdd: function(){
			$('.update_team_button').trigger();
		}});
}

$(document).ready(function(){
	$('.search').click(function(e){
		$(this).attr('id', 'tokeninput_search');
		tokenInput();
		$(this).trigger('focus');
	});
	
	ticketFadeIn();	
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
