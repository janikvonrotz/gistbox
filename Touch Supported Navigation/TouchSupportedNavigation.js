/* open dropdown navigation on touch devices */
jQuery('.touch nav').on('click','ul.nav>li:not(.active)',function(event){
  if(jQuery(this).find('ul').length > 0){
		event.preventDefault();
		jQuery('.overlay').show();
		jQuery(this).siblings().removeClass('active');
		jQuery(this).addClass('active');	
	}else{
		jQuery(this).siblings().removeClass('active');
		jQuery('.overlay').hide();
	}
});

/* open dropdown navigation on non touch devices */
jQuery('.no-touch nav').on('mouseenter','ul.nav>li:not(.active)',function(event){
	if(jQuery(this).find('ul').length > 0){
		event.preventDefault();
		jQuery('.overlay').show();
		jQuery(this).siblings().removeClass('active');
		jQuery(this).addClass('active');	
	}else{
		jQuery(this).siblings().removeClass('active');
		jQuery('.overlay').hide();
	}
});

/* close dropdown menu on click outside navigation */
jQuery('.overlay').on('click',function(event){
	jQuery('nav ul li').removeClass('active');
	jQuery('.overlay').hide();
});

/* button to show or hide menu on phone view */
jQuery('nav p.toggle-menu').on('click', function(event){
	jQuery('.phone nav>div>ul').toggleClass('hidden-phone');
});