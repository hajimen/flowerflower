(function() {
	function Fire() {
	    var e = document.createEvent('Events'); 
	    e.initEvent('contentupdated', false, false);
	    e.updated = $('.separation p');
	    document.dispatchEvent(e);
	}

	document.addEventListener("DOMContentLoaded", function(){
		Fire();
	}, false);
})();
