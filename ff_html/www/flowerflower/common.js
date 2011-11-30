/*
 * Constant:
 * 		window.ff.Site: サイト
 * 		window.ff.Title: 配信タイトル
 * 		window.ff.DefaultPushMessage: デフォルトの配信メッセージ
 * 
 */
(function() {
	if (window.ff) {
	} else {
		window.ff = {};
	}
	window.ff.isUpdatingToken = false;
	window.ff.EVENT_NEW_TOKEN = "newtoken";
	window.ff.EVENT_BEFORE_REBUILD_PAGE = "beforerebuildpage";

	var EVENT_CONTENT_UPDATED = "contentupdated";
	var TO_NEXT_RELEASE_PATH = "tonextrelease.txt";
	var AUTH_PATH = "Auth/";
	var NEXT_RELEASE_UNKNOWN_SPAN = 24 * 60 * 60 * 1000;
	var NEXT_RELEASE_UPDATING_SPAN = 60 * 1000;
	var MAX_RETRY = 5;
	var retry = 0;
	var nextUpdate = 0; // 次のUpdate時刻。0なら即時
	var processingNextUpdateText = "";
	var processingCatalogueEtag = ""; // 更新処理中のカタログのETag
	var processingLastSeparationId = "";
	var processingToNextUpdate = 0;
	var updateEntryMap = {};
	var lastScroll = "";
	var isFirstRun = false;
	var isUpdating = false;
	var isTickEnabled = true;

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

	var DepotStorageKey = {
		"Index" : "INDEX_KEY"
	};

	var PreferenceStorageKey = {
		"LastSeparationId" : "ff_last_separation",
		"CatalogueETag" : "ff_catalogue_etag",
		"LastScroll" : "ff_last_scroll",
		"LastRequestCatalogueTime" : "ff_last_request_catalogue_time",
		"NextReleaseText" : "ff_next_release_text",
		"LastOpenSid" : "ff_last_open_sid"
	};

	var HttpHeader = {
		"AuthScheme" : "X-flowerflower-AuthScheme",
		"AuthToken" : "X-flowerflower-AuthToken",
		"ErrorReason" : "X-flowerflower-ErrorReason",
		"AuthStatus" : "X-flowerflower-AuthStatus"
	};

	var ErrorReason = {
		"Malformed" : "Malformed",
		"Invalid" : "Invalid",
		"Security" : "Security"
	};

	var AuthStatus = {
		"Outdated" : "Outdated"
	};

	Date.prototype.setISO8601 = function(dString) {
		var regexp = /(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/;

		if (dString.toString().match(new RegExp(regexp))) {
			var d = dString.match(new RegExp(regexp));
			var offset = 0;

			this.setUTCDate(1);
			this.setUTCFullYear(parseInt(d[1], 10));
			this.setUTCMonth(parseInt(d[3], 10) - 1);
			this.setUTCDate(parseInt(d[5], 10));
			this.setUTCHours(parseInt(d[7], 10));
			this.setUTCMinutes(parseInt(d[9], 10));
			this.setUTCSeconds(parseInt(d[11], 10));
			if (d[12])
				this.setUTCMilliseconds(parseFloat(d[12]) * 1000);
			else
				this.setUTCMilliseconds(0);
			if (d[13] != 'Z') {
				offset = (d[15] * 60) + parseInt(d[17], 10);
				offset *= ((d[14] == '-') ? -1 : 1);
				this.setTime(this.getTime() - offset * 60 * 1000);
			}
		} else {
			this.setTime(Date.parse(dString));
		}
		return this;
	};

	function GetLastScroll() {
		return localStorage.getItem(PreferenceStorageKey.LastScroll
				+ window.ff.StartSid);
	}
	function GetLastScrollHeight() {
		return parseInt(GetLastScroll().split(',')[1]);
	}

	function GetLastScrollPosition() {
		return parseInt(GetLastScroll().split(',')[0]);
	}

	function RestoreScrollPositionImpl() {
		if (GetLastScroll() != null) {
			var y = GetLastScrollPosition();
			var h = GetLastScrollHeight();
			if ($(document).height() != h) {
				y = (y * $(document).height()) / h;
			}
			window.scrollTo(0, y);
		}

		var s = document.getElementById("beforeRestoreScrollPosition");
		if (s) {
			s.disabled = true;
		}

		Tick();
		isTickEnabled = true;
	}

	function WaitForLayoutFixed(f, h) {
		setTimeout(function() {
			var nh = $(document).height();
			if (nh == h) {
				f();
			} else {
				WaitForLayoutFixed(f, nh);
			}
		}, 100);
	}

	function RestoreScrollPosition() {
		if (GetLastScroll() == null || GetLastScrollPosition() == 0) {
			RestoreScrollPositionImpl();
		} else {
			WaitForLayoutFixed(RestoreScrollPositionImpl, $(document).height());
		}
	}

	function SetStatusLine(text) {
		if (text) {
			document.getElementById("status").innerHTML = text;
		} else {
			var t = localStorage.getItem(PreferenceStorageKey.NextReleaseText);
			if (t && t.length > 0) {
				SetStatusLine("<p>次回の配信は" + t + "の予定です。</p>");
			} else {
				SetStatusLine("<p></p>");
			}
		}
	}

	function Tick() {
		if (!isTickEnabled) {
			return;
		}

		if (localStorage.getItem("h" + window.ff.StartSid) == null
				&& !window.ff.IsConnectionOk()) {
			SetStatusLine("<p>配信サーバと接続できないため、なにもお見せできません。インターネット接続が可能な状態になったら、もう一度アプリを起動してください。</p>");
			return;
		}

		if (nextUpdate < new Date().getTime() && window.ff.IsConnectionOk()) {
			Update();
		}
		var v = "" + window.pageYOffset + "," + $(document).height();
		if (lastScroll != v) {
			lastScroll = v;
			localStorage.setItem(PreferenceStorageKey.LastScroll
					+ window.ff.StartSid, v);
		}
	}

	window.ff.OnLinkClick = function(sid) {
		isTickEnabled = false;
		SetStartSid(sid);
		var s = document.getElementById("beforeRestoreScrollPosition");
		if (s) {
			s.disabled = false;
		}

		BuildDomTree();
		RestoreScrollPosition();
	}

	function FireEventContentUpdated(jo) {
		jo.each(function() {
			var h = $(this).html();
			h = h.replace(/href=(['"])([^:]*)\.html(['"])/g,
					"href=$1javascript:void(0)$3 onclick=\"window.ff.OnLinkClick('$2'); return false;\"");
			$(this).html(h);
		});

		var e = document.createEvent('Events');
		e.initEvent(EVENT_CONTENT_UPDATED, false, false);
		e.updated = jo;
		document.dispatchEvent(e);
	}

	function UpdateSuccessed() {
		localStorage.setItem(PreferenceStorageKey.CatalogueETag,
				processingCatalogueEtag);
		localStorage.setItem(PreferenceStorageKey.LastSeparationId,
				processingLastSeparationId);
		localStorage.setItem(PreferenceStorageKey.NextReleaseText,
				processingNextUpdateText);

		if (processingToNextUpdate === "-1") {
			nextUpdate = NEXT_RELEASE_UNKNOWN_SPAN + new Date().getTime();
		} else if (parseInt(processingToNextUpdate) > NEXT_RELEASE_UPDATING_SPAN) {
			nextUpdate = parseInt(processingToNextUpdate)
					+ new Date().getTime();
		}

		window.ff.CatalogueUpdated(processingCatalogueEtag,
				processingLastSeparationId, processingToNextUpdate);

		if (updateEntryMap[DepotStorageKey.Index] && isFirstRun) {
			isFirstRun = false;
			BuildDomTree();
		} else {
			// DOMツリーを更新
			if (updateEntryMap[DepotStorageKey.Index]) {
				BuildNav();
			}
			var updated = $();

			for ( var re in updateEntryMap) {
				if (updateEntryMap[re] === null && re.indexOf("h") === 0) {
					var c = document.getElementById(re.substring(1, re.length));
					if (c !== null) {
						c.parentNode.removeChild(c);
						delete c;
					}
				}
			}
			if (updateEntryMap["h" + window.ff.StartSid] != null) {
				var c = $('#' + window.ff.StartSid);
				if (c.length) {
					c.html(updateEntryMap[ue]);
				} else {
					$('#content').prepend(
							'<div class="separation" id="' + window.ff.StartSid
									+ '">'
									+ updateEntryMap["h" + window.ff.StartSid]
									+ '</div>');
				}
				updated = updated.add('#' + window.ff.StartSid);
			}

			var beforeSid = window.ff.StartSid;
			for ( var sid = localStorage.getItem("n" + window.ff.StartSid); sid !== null; sid = localStorage
					.getItem("n" + sid)) {
				for ( var ue in updateEntryMap) {
					if ("h" + sid == ue) {
						var c = $('#' + sid);
						if (c.length) {
							c.html(updateEntryMap[ue]);
						} else {
							$('#' + beforeSid).after(
									'<div class="separation" id="' + sid + '">'
											+ updateEntryMap[ue] + '</div>');
						}
						updated = updated.add('#' + sid);
					}
				}
				beforeSid = sid;
			}

			FireEventContentUpdated(updated);
		}

		updateEntryMap = {};
		retry = 0;

		var statusText = "配信を受け取りました。";
		if (processingNextUpdateText.length > 0) {
			statusText += "次回の配信は" + processingNextUpdateText + "の予定です。";
		}
		SetStatusLine("<p>" + statusText + "</p>");

		var s = document.getElementById("beforeBuildDomTree");
		if (s != null) {
			s.parentNode.removeChild(s);
			delete s;
		}

		isUpdating = false;
	}

	function SyncDepot(diffFilenameList) {
		if (diffFilenameList.length == 0) {
			UpdateSuccessed();
			return;
		}

		SetStatusLine("<p>配信を受け取っています...</p>");
		var dfn = diffFilenameList.shift();
		RequestJson(AUTH_PATH + dfn + ".json", null,
				function(data, status, xhr) {
					for ( var k in data) {
						if (data[k] === null) {
							localStorage.removeItem(k);
							updateEntryMap[k] = null;
						} else {
							localStorage.setItem(k, data[k]);
							updateEntryMap[k] = data[k];
						}
					}

					SyncDepot(diffFilenameList);
				}, window.ff.AuthErrorHandler);
	}

	function CatalogueUpdated(catalogue) {
		if (catalogue.next_release) {
			var d = new Date();
			d.setISO8601(catalogue.next_release);
			var year = d.getFullYear(); // 年
			var mon = d.getMonth() + 1; // 月
			var date = d.getDate(); // 日
			var hour = d.getHours(); // 時
			var min = d.getMinutes(); // 分

			processingNextUpdateText = year + "年" + mon + "月" + date + "日 "
					+ hour + "時" + min + "分";
		} else {
			processingNextUpdateText = "";
		}

		var lastSid = localStorage
				.getItem(PreferenceStorageKey.LastSeparationId);
		var local = catalogue.local;
		var from = 0;
		for ( var i = 0; i < local.length; i++) {
			if (local[i] == lastSid) {
				from = i + 1;
				break;
			}
		}

		var express = catalogue.express;
		var diffFilenameList = [];
		var jumpTo = null;
		for ( var i = from; i < local.length; i++) {
			if (jumpTo != null) {
				if (jumpTo == local[i]) {
					jumpTo = null;
				}
				continue;
			}
			if (express[local[i]]) {
				diffFilenameList.push(local[i] + express[local[i]]);
				jumpTo = express[local[i]];
			} else {
				diffFilenameList.push(local[i]);
			}
		}
		if (diffFilenameList.length == 0) {
			return;
		}

		processingLastSeparationId = diffFilenameList[diffFilenameList.length - 1];
		SyncDepot(diffFilenameList);
	}

	function RequestJsonWithToken(path, etag, token, successFunc, errorFunc) {
		var url = window.ff.Site + path;
		var opt = {
			"type" : "GET",
			"url" : url,
			"cache" : false,
			"success" : function(data, status, xhr) {
				var authStatus = xhr
						.getResponseHeader(window.ff.HttpHeader.AuthStatus);
				successFunc(data, status, xhr);
				if (authStatus == window.ff.AuthStatus.Outdated) {
					if (!window.ff.isUpdatingToken) {
						window.ff.RequestToken();
					}
				} else if (authStatus) {
					alert("アプリのエラー:c1f98b43-296f-48c5-a497-d087d6bd5d37 アプリのバージョンが古いか、あるいは配信サーバとの通信に異常があります。");
				}
			},
			"error" : errorFunc,
			"beforeSend" : function(xhr) {
				xhr.setRequestHeader(window.ff.HttpHeader.AuthToken, token);
				xhr.setRequestHeader(window.ff.HttpHeader.AuthScheme,
						window.ff.AuthScheme);
				if (etag) {
					xhr.setRequestHeader("If-None-Match", etag);
				} else {
					xhr.setRequestHeader("If-None-Match", '"never-match-this"');
				}
			},
			"timeout" : 3000
		};
		$.ajax(opt);
	}

	function RequestJson(path, etag, successFunc, errorFunc) {
		var token = window.ff.GetToken();
		if (token) {
			RequestJsonWithToken(path, etag, token, successFunc, errorFunc);
		} else {
			document.addEventListener(window.ff.EVENT_NEW_TOKEN, function() {
				RequestJsonWithToken(path, etag, window.ff.GetToken(),
						successFunc, errorFunc);
			}, false);
			if (!window.ff.isUpdatingToken) {
				window.ff.RequestToken();
			}
		}
	}
	;

	function Update() {
		nextUpdate = NEXT_RELEASE_UPDATING_SPAN + new Date().getTime();
		if (isUpdating) {
			return;
		}
		isUpdating = true;

		var opt = {
			"type" : "GET",
			"dataType" : "text",
			"url" : window.ff.Site + TO_NEXT_RELEASE_PATH,
			"cache" : false,
			"success" : function(data) {
				processingToNextUpdate = data;
				SetStatusLine("<p>配信サーバと通信しています...</p>");
				RequestJson(
						AUTH_PATH + "catalogue.json",
						localStorage
								.getItem(PreferenceStorageKey.CatalogueETag),
						function(data, status, xhr) {
							if (window.ff.ServerConnectionSuccessed != null) {
								window.ff.ServerConnectionSuccessed();
							}
							if (status == "notmodified") {
								if (processingToNextUpdate === "-1") {
									nextUpdate = NEXT_RELEASE_UNKNOWN_SPAN
											+ new Date().getTime();
								} else if (parseInt(processingToNextUpdate) > NEXT_RELEASE_UPDATING_SPAN) {
									nextUpdate = parseInt(processingToNextUpdate)
											+ new Date().getTime();
								}
								SetStatusLine(null);
								isUpdating = false;
								return;
							}
							processingCatalogueEtag = xhr
									.getResponseHeader("ETag");
							CatalogueUpdated(data);
						}, window.ff.AuthErrorHandler);
			},
			"error" : function(xhr, status, errorThrown) {
				isUpdating = false;
				var statusLine = "<p>配信サーバと接続できませんでした。</p>";
				if (window.ff.IsConnectionOk()) {
					statusLine += '<p><input type="button" value="再接続" onclick="window.ff.FireUpdate();" /></p>';
				}
				SetStatusLine(statusLine);

                if (retry < MAX_RETRY) {
					retry++;
				} else {
					alert("アプリのエラー:d9e836bf-bdf2-4ba1-896e-370ee585ca8c 配信サーバとの通信または配信サーバに異常があります。");
					retry = 0;
				}
			},
			"timeout" : 3000
		};
		$.ajax(opt);
	}

	function BuildNav() {
		var indexJson = localStorage.getItem(DepotStorageKey.Index);
		var nav = "";
		var indexList = $.parseJSON(indexJson);
		if (indexList.length > 0 && window.ff.StartSid == "") {
			SetStartSid(indexList[0].start);
		}
		for ( var i = 0; i < indexList.length; i++) {
			var index = indexList[i];
			nav += '<li><a href="javascript:void(0)" onclick="window.ff.OnLinkClick(\'' + index.start + '\'); return false;">'
					+ index.name + '</a></li>';
			if (index.start == window.ff.StartSid) {
				document.title = index.name;
			}
		}
		nav += '<li><a href="javascript:void(0)" onclick="window.ff.OnLinkClick(\'character_note\'); return false;">登場人物紹介</a></li>';
		nav += '<li><a href="http://kaoriha.org/latest_item.html">近刊案内</a></li>';
		nav += '<li><a href="about.html">このアプリについて</a></li>';

		$('#nav ul').html(nav);

		return indexList;
	}

	function BuildDomTree() {
		window.scrollTo(0, 0);
		var e = document.createEvent('Events');
		e.initEvent(window.ff.EVENT_BEFORE_REBUILD_PAGE, false, false);
		document.dispatchEvent(e);

		var indexJson = localStorage.getItem(DepotStorageKey.Index);
		if (indexJson != null) {
			BuildNav();

			var content = "";
			for ( var sid = window.ff.StartSid; sid !== null; sid = localStorage
					.getItem("n" + sid)) {
				if (localStorage.getItem("h" + sid)) {
					content += '<div class="separation" id="' + sid + '">';
					content += localStorage.getItem("h" + sid);
					content += '</div>';
				}
			}
			document.getElementById("content").innerHTML = content;
			FireEventContentUpdated($('.separation'));
		}
	}

	window.ff.HttpHeader = HttpHeader;

	window.ff.AuthStatus = AuthStatus;

	window.ff.CharacterNoteElement = '<a href="javascript:void(0)" onclick="window.ff.OnLinkClick(\'character_note\'); return false;">';

	window.ff.AuthErrorHandler = function(xhr, status) {
		isUpdating = false;
		var statusText = "配信を受け取れませんでした。";
		window.ff.isUpdatingToken = false;
		if (xhr.status != 400) { // 400 bad request
			statusText += "配信サーバとの通信または配信サーバに異常があります。アプリまたは本体を再起動し、インターネットとの接続状態を確認してください。ステータスコード:" + xhr.status;
			SetStatusLine("<p>" + statusText + "</p>");
			if (retry < MAX_RETRY) {
				retry++;
			} else {
				alert("アプリのエラー:51de90c4-b592-4b97-a02f-85bec5d97b13  配信サーバとの通信または配信サーバに異常があります。ステータスコード:" + xhr.status);
				retry = 0;
			}
			return;
		}
		var errorReason = xhr.getResponseHeader(HttpHeader.ErrorReason);
		switch (errorReason) {
		case ErrorReason.Malformed:
			statusText += "配信サーバとの通信経路または配信サーバに異常があります。";
			SetStatusLine("<p>" + statusText + "</p>");
			if (retry < MAX_RETRY) {
				retry++;
			} else {
				alert("アプリのエラー:8128648a-17b1-41d3-83d2-0ef99524a335  配信サーバとの通信または配信サーバに異常があります。");
				retry = 0;
			}
			break;
		case ErrorReason.Invalid:
			alert("アプリのエラー:25f65c6b-a769-410b-8630-c67610a951d5  配信サーバがこのアプリの認証を拒否しました。");
			break;
		case ErrorReason.Security:
			alert("アプリのエラー:a5b36c3a-66bd-42cb-a5bf-e82cd32c3a86 不正アクセスなどの理由により配信サーバがこのアプリの認証を拒否しました。");
			break;
		default:
			alert("アプリのエラー:7d6b3e00-345c-4faa-9d37-dad1ab153b1c なんらかの理由により配信サーバがこのアプリの認証を拒否しました。");
			break;
		}
	};

	window.ff.FireUpdate = function(after) {
		if (window.ff.IsConnectionOk()) {
			SetStatusLine("<p>配信サーバと接続しています...</p>");
		}
		if (after) {
			nextUpdate = after + new Date().getTime();
		} else {
			nextUpdate = 0;
		}
	}

	function SetStartSid(sid) {
		localStorage.setItem(PreferenceStorageKey.LastOpenSid, sid);
		window.ff.StartSid = sid;
	}

	function SetStartSidAsLast() {
		window.ff.StartSid = localStorage
				.getItem(PreferenceStorageKey.LastOpenSid);
	}

	window.ff.Start = function() {
		if (localStorage.getItem(DepotStorageKey.Index) == null) {
			isFirstRun = true;
		}

		if (localStorage.getItem(PreferenceStorageKey.LastOpenSid) != null) {
			SetStartSidAsLast();
		} else {
			window.ff.StartSid = "";
		}

		document.addEventListener("resume", function() {
			window.ff.FireUpdate(1000);
		}, false);

		document.addEventListener(EVENT_CONTENT_UPDATED, function() {
			RestoreScrollPosition();
			document.removeEventListener(EVENT_CONTENT_UPDATED,
					arguments.callee, false);
		}, false);

		window.ff.AuthStart(function() {
			setInterval(Tick, 1000);
			if (localStorage.getItem(DepotStorageKey.Index) == null) {
				if (window.ff.IsConnectionOk()) {
					SetStatusLine("<p>配信サーバと接続しています...</p>");
					Update();
				} else {
					SetStatusLine("<p>配信サーバと接続できないため、なにもお見せできません。インターネット接続が可能な状態になったら、もう一度アプリを起動してください。</p>");
					return;
				}
			} else {
				BuildDomTree();

				var s = document.getElementById("beforeBuildDomTree");
				if (s == null) {
				} else {
					s.parentNode.removeChild(s);
					delete s;
				}

				SetStatusLine(null);
			}
		});
	};

	document.addEventListener('deviceready', function() {
		window.ff.Start();
	}, false);
})();
