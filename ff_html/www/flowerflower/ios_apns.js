(function() {
	var PSKEY_TOKEN = "token";
	var REQUEST_TOKEN_PATH = "Office/IosApns/RequestAuthToken.ashx";
	var isUpdatingToken = false;
	var deviceToken = null;

	if (window.ff) {
	} else {
		window.ff = {};
	}
    window.ff.AuthScheme = "iOS_APNs";

	// iPad 3.2 bug workaround
	var localStorage = {
			'setItem' : function(k, v) {
				if (window.localStorage.getItem(k) != null) {
					window.localStorage.removeItem(k);
				}
				window.localStorage.setItem(k, v);
			},
			'getItem' : function(k) { return window.localStorage.getItem(k); },
			'clear' : function() { window.localStorage.clear(); },
			'removeItem' : function(k) { window.localStorage.removeItem(k); }
	};

	function RequestJsonService(path, type, data, successFunc, errorFunc) {
		var url = window.ff.Site + path;
		var opt = {
				"type" : type,
				"url" : url,
				"cache" : false,
				"success" : successFunc,
				"error" : errorFunc,
				"timeout" : 3000
		};
		if (data) {
			opt.data = data;
		}
		$.ajax(opt);
	}

    function RegisterError(message) {
        alert("アプリのエラー:11d97b4e-eca6-4c7e-b6ad-8da4d9df1e3f " + message);
    }

    window.ff.RequestToken = function() {
		window.ff.isUpdatingToken = true;
		if (deviceToken == null) {
			alert("アプリのエラー:8d8541ea-a324-41fe-927b-258130a6233e リモート通知に必要なデバイストークンを取得できません。");
			return;
		}
		var lastStatusLine = GetStatusLine();
		SetStatusLine("<p>アプリを認証しています...</p>");
    	RequestJsonService(REQUEST_TOKEN_PATH, "POST", {"deviceToken" : deviceToken}, function() {
    		SetStatusLine(lastStatusLine);
    	}, window.ff.AuthErrorHandler);
	};

	window.ff.CatalogueUpdated = function(etag, lastSid) {
		// Do nothing
	};

	function SetStatusLine(text) {
		$('#status').html(text);
	}

	function GetStatusLine() {
		return $('#status').html();
	}

	window.ff.AuthStart = function(continuation) {
		document.addEventListener("remoteNotification", function(event) {
			if (event.payload.authToken) {
				window.ff.SetToken(event.payload.authToken);
			} else {
				window.ff.FireUpdate(1000);
			}
		}, false);
		var lastStatusLine = GetStatusLine();
		SetStatusLine("<p>リモート通知を有効にしています...</p>");
		window.plugins.remoteNotification.register(function(t) {
	    	deviceToken = t;
			SetStatusLine(lastStatusLine);
			continuation();
		}, RegisterError, {
			"Badge" : 1,
			"Alert" : 1,
			"Sound" : 0
		});
	};

    window.ff.ServerConnectionSuccessed = function() {
        window.plugins.remoteNotification.clearBadge();
    };

    window.ff.SetToken = function(token) {
		localStorage.setItem(PSKEY_TOKEN, token);
		isUpdatingToken = false;
	    var e = document.createEvent('Events'); 
	    e.initEvent(window.ff.EVENT_NEW_TOKEN, false, false);
	    document.dispatchEvent(e);
	};
	
	window.ff.GetToken = function() {
		return localStorage.getItem(PSKEY_TOKEN);
	};

	window.ff.IsConnectionOk = function() {
        var t = navigator.network.connection.type;
		return t != Connection.NONE && t != Connection.UNKNOWN;
	};
})();
