(function() {
	var CHALLENGE_PATH = "Office/AndroidLvl/RequestAuthChallenge.ashx";
	var CHALLENGE_RESPONSE_PATH = "Office/AndroidLvl/RequestAuthToken.ashx";
	var PSKEY_ONCE_STARTED = "onceStarted";
	var EVENT_TOKEN_SET = "tokenset";
	var tokenCache;

	if (window.ff) {
	} else {
		window.ff = {};
	}
	window.ff.AuthScheme = "Android_LVL";

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

	function RequestChallengeResponseSuccess(data, status, xhr) {
		var token = xhr.getResponseHeader(window.ff.HttpHeader.AuthToken);
		if (token) {
			window.ff.SetToken(token);
		} else {
			alert("アプリのエラー:130a8877-7293-4e4e-8792-97fac201dd37 配信サーバとの通信または配信サーバに異常があります。");
			window.ff.isUpdatingToken = false;
		}
	}

		
	function RequestChallengeSuccess(challenge) {
		window.plugins.licenseVerification
				.query(
						function(verificationData) {
							switch (verificationData.responseCode) {
							case "LICENSED":
							case "LICENSED_OLD_KEY":
							case "ERROR_NOT_MARKET_MANAGED": {
								var res = {
									"id" : challenge.id,
									"data" : verificationData.signedData,
									"signature" : verificationData.signature
								};
								RequestJsonService(CHALLENGE_RESPONSE_PATH,
										"POST", res,
										RequestChallengeResponseSuccess,
										window.ff.AuthErrorHandler);
								break;
							}
							default:
								alert("アプリのエラー:fa1303fc-bb80-463c-b06c-6d907395ae72 Android License Verificationに異常があります。"
										+ verificationData.responseCode);
								break;
							}
						},
						function(errorType) {
							alert("アプリのエラー:2dcd0a9d-8548-43d8-ae63-39249d765251 Android License Verificationに異常があります。"
									+ errorType);
							window.ff.isUpdatingToken = false;
						}, challenge.nonce);
	}

	window.ff.RequestToken = function() {
		window.ff.isUpdatingToken = true;
		RequestJsonService(CHALLENGE_PATH, "GET", null,
				RequestChallengeSuccess, window.ff.AuthErrorHandler);
	};

	window.ff.CatalogueUpdated = function(etag, lastSid, toNextRelease) {
		window.plugins.releasenotification
				.updated(etag, lastSid, toNextRelease);
	};

	window.ff.AuthStart = function(continuation) {
		if (localStorage.getItem(PSKEY_ONCE_STARTED) != "started") {
			window.plugins.releasenotification.start(window.ff.Site, null,
					null, window.ff.Title, window.ff.DefaultPushMessage);
			localStorage.setItem(PSKEY_ONCE_STARTED, "started");
		}
		document.addEventListener(EVENT_TOKEN_SET, function() {
			continuation();
			document.addEventListener("resume", window.ff.GetToken, false);
			document.removeEventListener(EVENT_TOKEN_SET, arguments.callee,
					false);
		}, false);
		window.ff.GetToken();
	};

	window.ff.SetToken = function(token) {
		window.plugins.releasenotification.setToken(token);
		tokenCache = token;
		window.ff.isUpdatingToken = false;
		var e = document.createEvent('Events');
		e.initEvent(window.ff.EVENT_NEW_TOKEN, false, false);
		document.dispatchEvent(e);
	};

	window.ff.GetToken = function() {
		window.plugins.releasenotification.getToken(function(o) {
			tokenCache = o.token;
			var e = document.createEvent('Events');
			e.initEvent(EVENT_TOKEN_SET, false, false);
			document.dispatchEvent(e);
		});
		return tokenCache;
	};

	window.ff.IsConnectionOk = function() {
		return navigator.network.connection.type != Connection.NONE;
	};
})();
