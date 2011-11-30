(function() {
	if (window.ff) {
	} else {
		window.ff = {};
	}

	window.ff.RequestToken = function() {
	};

	window.ff.CatalogueUpdated = function(etag, lastSid) {
		// Do nothing
	};

	window.ff.AuthStart = function(continuation) {
		// Do nothing
		continuation();
	};

	window.ff.SetToken = function(token) {
	};

	window.ff.GetToken = function() {
		return "dummy";
	};

	window.ff.IsConnectionOk = function() {
		return true;
	};
})();
