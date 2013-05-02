(function() {
	if (window.ff) {
	} else {
		window.ff = {};
	}
	window.ff.AuthScheme = "Web";

	window.ff.CatalogueUpdated = function(etag, lastSid) {
		// Do nothing
	};

	function OnOrientationChanged(event) {
		window.ff.RestoreScrollPosition.Start();
	}

	window.ff.AuthStartSequenceGenerator = function() { return [
		function() {
			document.addEventListener("orientationchange", OnOrientationChanged);
			window.ff.Site = "../";
		}
	]; };

	window.ff.ServerConnectionSuccessed = function() {
		// do nothing
	};

	window.ff.RequestTokenSequenceGenerator = function() { return [
		function() {
		}
	]; };

    window.ff.ReceiveTokenSequenceGenerator = function() { return [function() {
    	this.token = "dummy";
    }]; };

	window.ff.IsConnectionOk = function() {
		return true;
	};

	window.ff.AuthClearStorage = function() {
	};
})();
