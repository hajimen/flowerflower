(function() {
	var userAgent = navigator.userAgent.toLowerCase();
	if (userAgent.match(/android 2/)) {
		var d = document;
		var link = d.createElement('link');
		link.href = '../android/ruby_fix.css';
		link.rel = 'stylesheet';
		link.type = 'text/css';
		var h = d.getElementsByTagName('head')[0];
		h.appendChild(link);
	}
})();