(function() {
	var PSKEY_TOKEN = "token";
	var PSKEY_HAS_PUSH_AGREEMENT = "pushAgreement";
	var REQUEST_TOKEN_PATH = "Office/IosApns/RequestAuthToken.ashx";
	var EVENT_NEW_TOKEN = "newtoken";
	var EVENT_NEW_TOKEN_TIMEOUT = 30000;

	var isUpdatingToken = false;
	var deviceToken = null;
	var tokenCache = null;
	var eventNewTokenTimeout = null;

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
		'getItem' : function(k) {
			return window.localStorage.getItem(k);
		},
		'clear' : function() {
			window.localStorage.clear();
		},
		'removeItem' : function(k) {
			window.localStorage.removeItem(k);
		}
	};

	window.ff.CatalogueUpdated = function(etag, lastSid) {
		// Do nothing
	};

	function RemoteNotificationHanlder(event) {
		if (event.payload.authToken) {
			if (eventNewTokenTimeout) {
				clearTimeout(eventNewTokenTimeout);
				eventNewTokenTimeout = null;
			}
			tokenCache = event.payload.authToken;
			localStorage.setItem(PSKEY_TOKEN, tokenCache);
			isUpdatingToken = false;
			var e = document.createEvent('Events');
			e.initEvent(EVENT_NEW_TOKEN, false, false);
			e.isOk = true;
			document.dispatchEvent(e);
		} else {
			window.ff.FireUpdate(1000);
		}
	}

	window.ff.AuthStartSequenceGenerator = function() { return [
		function() {
			if (localStorage.getItem(PSKEY_HAS_PUSH_AGREEMENT) === null) {
				this.isFirstRun = true;
				navigator.notification.confirm(
						'このアプリはリモート通知を使います。よろしいですか？',
						this.$1,
						window.ff.Title, 'いいえ,はい');
			} else {
				this.$next();
			}
			return true;
		},
		[
			function(button) {
				if (button === 2) {
					localStorage.setItem(PSKEY_HAS_PUSH_AGREEMENT, "true");
					return;
				} else {
					navigator.notification.alert(
							'リモート通知を許可されない場合、このアプリはご利用になれません。',
							this.$onError,
							window.ff.Title,
							'OK');
					return true;
				}
			}
		],
		function() {
			document.addEventListener("remoteNotification", RemoteNotificationHanlder, false);
			tokenCache = localStorage.getItem(PSKEY_TOKEN);
			window.ff.StatusSection.PushAction("リモート通知を有効にしています...");
			var scopeThis = this;
			window.plugins.remoteNotification.register(
					this.$next,
					function(message) {
						alert("アプリのエラー:11d97b4e-eca6-4c7e-b6ad-8da4d9df1e3f " + message);
						scopeThis.$onError();
					}, {
						"Badge" : 1,
						"Alert" : 1,
						"Sound" : 0
					});
			return true;
		},
		function(t) {
			deviceToken = t;
			window.ff.StatusSection.PopAction();
			if (this.isFirstRun) {
				window.ff.ScreenMode.Set(window.ff.ScreenMode.Authenticating);
				window.ff.StatusSection.PushAction("アプリを認証しています...");
				this.$1();
				return true;
			}
		},
		window.ff.RequestTokenSequenceGenerator(),
		function() {
			window.ff.StatusSection.PopAction();
			window.ff.ScreenMode.Set(window.ff.ScreenMode.Loading);
		}
	]; };

	window.ff.ServerConnectionSuccessed = function() {
		window.plugins.remoteNotification.clearBadge();
	};

	window.ff.RequestTokenSequenceGenerator = function() { return [
		function() {
			window.plugins.remoteNotification.enabledTypes(this.$next);
			return true;
		},
		function(enabledTypes) {
			if (!enabledTypes.Badge && !enabledTypes.Alert) {
				navigator.notification.alert(
						'このアプリはリモート通知を使います。ホーム画面の[設定]→[通知]から['
								+ window.ff.Title
								+ ']のバッジと通知を有効にしてください。',
						this.$onError,
						window.ff.Title,
						'OK');
				return true;
			}
			var scopeThis = this;
			var l = function(event) {
				document.removeEventListener(EVENT_NEW_TOKEN, arguments.callee, false);
				if (event.isOk) {
					scopeThis.$parent();
				} else {
					scopeThis.$onError();
				}
			};
			document.addEventListener(EVENT_NEW_TOKEN, l, false);
			this.tokenEventListener = l;

			if (isUpdatingToken) {
			} else {
				isUpdatingToken = true;
				eventNewTokenTimeout = setTimeout(NewTokenTimeouted, EVENT_NEW_TOKEN_TIMEOUT);
				window.ff.RequestService(REQUEST_TOKEN_PATH, "POST", {
					"deviceToken" : deviceToken
				}, null, this.$next);
			}
			return true;
		},
		function(xhr, status) {
			document.removeEventListener(EVENT_NEW_TOKEN, this.tokenEventListener, false);
			this.$next(xhr, status);
			return true;
		}, window.ff.AuthErrorSequenceFunc
	]; };

	function NewTokenTimeouted() {
		if (window.ff.IsConnectionOk()) {
			alert("アプリのエラー:5c358cdf-7bc8-4ad0-b209-8300da00ceff リモート通知を受け取れませんでした。配信サーバとの通信または配信サーバに異常があります。");
		}
		var e = document.createEvent('Events');
		e.initEvent(EVENT_NEW_TOKEN, false, false);
		e.isOk = false;
		document.dispatchEvent(e);
		isUpdatingToken = false;
	}

	window.ff.ReceiveTokenSequenceGenerator = function() { return [
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
		var t = navigator.network.connection.type;
		return t != Connection.NONE && t != Connection.UNKNOWN;
	};

	window.ff.AuthClearStorage = function() {
	};
})();
