function ScaleChangedFireEvent(val) {
	var e = document.createEvent('Events');
	e.initEvent('scaleChanged');
	e.val = val;
	document.dispatchEvent(e);
}

function ScaleChangedHandler(event) {
	var scale = event.val.scale;
	var width = event.val.width;
	document.querySelector('meta[name=viewport]').setAttribute(
			'content',
			'width=' + width + ', minimum-scale=' + scale + ', maximum-scale='
					+ scale + ', initial-scale=' + scale, false);
	document.body.addEventListener('gesturestart', function() {
		document.querySelector('meta[name=viewport]').setAttribute(
				'content',
				'width=' + width + ', minimum-scale=' + scale
						+ ', maximum-scale=' + scale * 10.0, false);
		document.body.removeEventListener('gesturestart', arguments.callee,
				false);
	});
}

document.addEventListener('deviceready', function() {
	cordova.exec(null, null, "org.kaoriha.phonegap.plugins.scalechanger",
			"ready", []);
	document.addEventListener("scaleChanged", ScaleChangedHandler, false);
}, false);
