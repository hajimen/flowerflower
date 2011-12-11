(function() {
	var CHALLENGE_PATH = "Office/AndroidLvl/RequestAuthChallenge.ashx";
	var CHALLENGE_RESPONSE_PATH = "Office/AndroidLvl/RequestAuthToken.ashx";
	var PSKEY_ONCE_STARTED = "onceStarted";
	var EVENT_NEW_TOKEN = "newtoken";
	var isUpdatingToken = false;
	var tokenCache = null;

	if (window.ff) {
	} else {
		window.ff = {};
	}
	window.ff.AuthScheme = "Android_LVL";

	window.ff.CatalogueUpdated = function(etag, lastSid, toNextRelease) {
		window.plugins.releasenotification.updated(etag, lastSid, toNextRelease);
	};

	window.ff.AuthStartSequenceGenerator = function() { return [
		function() {
			if (localStorage.getItem(PSKEY_ONCE_STARTED) != "started") {
				window.plugins.releasenotification.start(window.ff.Site, null,
						null, window.ff.Title, window.ff.DefaultPushMessage);
				localStorage.setItem(PSKEY_ONCE_STARTED, "started");
			}
			window.plugins.releasenotification.getToken(this.$next);
			return true;
		},
		function(o) {
			if (o.token) {
				tokenCache = o.token;
			}
		}
	]; };

    window.ff.ServerConnectionSuccessed = function() {
    	// Do nothing
    };

    window.ff.RequestTokenSequenceGenerator = function() {return [
		function() {
			var scopeThis = this;
			document.addEventListener(EVENT_NEW_TOKEN, function() {
				document.removeEventListener(EVENT_NEW_TOKEN, arguments.callee, false);
				scopeThis.$parent();
			}, false);

			if (isUpdatingToken) {
			} else {
				isUpdatingToken = true;
				window.ff.RequestService(
						CHALLENGE_PATH,
						"GET",
						null,
						this.$next,
						this.$1);
			}
			return true;
		},
		[window.ff.AuthErrorSequenceFunc],
		function(challenge) {
			this.challenge = challenge;
			window.plugins.licenseVerification.query(this.$1, this.$2, challenge.nonce);
			return true;
		},
		[
			function(verificationData) {	// success
				switch (verificationData.responseCode) {
				case "LICENSED":
				case "LICENSED_OLD_KEY":
				case "ERROR_NOT_MARKET_MANAGED": {
					this.verificationData = verificationData;
					return;
				}
				default:
					alert("アプリのエラー:fa1303fc-bb80-463c-b06c-6d907395ae72 Android License Verificationに異常があります。"
							+ verificationData.responseCode);
					isUpdatingToken = false;
					this.$onError();
					return true;
				}
			},
			function(errorType) {	// error
				alert("アプリのエラー:2dcd0a9d-8548-43d8-ae63-39249d765251 Android License Verificationに異常があります。"
						+ errorType);
				isUpdatingToken = false;
				this.$onError();
				return true;
			}
		],
		function() {
			var res = {
					"id" : this.challenge.id,
					"data" : this.verificationData.signedData,
					"signature" : this.verificationData.signature
			};
			window.ff.RequestService(
					CHALLENGE_RESPONSE_PATH,
					"POST",
					res,
					this.$next,
					this.$1);
			return true;
		},
		[window.ff.AuthErrorSequenceFunc],
		function(data, status, xhr) {
			isUpdatingToken = false;
			var token = xhr.getResponseHeader(window.ff.HttpHeader.AuthToken);
			if (token) {
				window.plugins.releasenotification.setToken(token);
				tokenCache = token;
			    var e = document.createEvent('Events'); 
			    e.initEvent(EVENT_NEW_TOKEN, false, false);
			    document.dispatchEvent(e);
				return true;
			} else {
				alert("アプリのエラー:130a8877-7293-4e4e-8792-97fac201dd37 配信サーバとの通信または配信サーバに異常があります。");
				this.$onError();
				return true;
			}
		}
	]; };

    window.ff.ReceiveTokenSequenceGenerator = function() {return [
		function() {
			if (tokenCache) {
				this.token = tokenCache;
				return;
			}

			this.$1();
			return true;
		},
		window.ff.RequestTokenSequenceGenerator(),
		function() {
			this.token = tokenCache;
		}
	]; };

	window.ff.IsConnectionOk = function() {
		return navigator.network.connection.type != Connection.NONE;
	};

	window.ff.AuthClearStorage = function() {
		window.plugins.releasenotification.stop();
		window.plugins.releasenotification.clear();
	};
})();
