(function() {
	if (window.ff) {
	} else {
		window.ff = {};
	}

	function GetLastScrollHeight() {
		return $.cookie('last_scroll_height' + location.href);
	}

	function SetLastScrollHeight(height) {
		$.cookie('last_scroll_height' + location.href, "" + height, {expires: 3650, path: '/'});
	}

	function GetLastScrollPosition() {
		return $.cookie('last_scroll_position' + location.href);
	}

	function SetLastScrollPosition(pos) {
		$.cookie('last_scroll_position' + location.href, "" + pos, {expires: 3650, path: '/'});
	}

	function Tick() {
		SetLastScrollPosition(window.pageYOffset);
		SetLastScrollHeight($(document).height());
	}
	
	function RemoveStyleElement() {
		var s = document.getElementById("beforeRestoreScrollPosition");
		if (s) {
			s.disabled = true;
		}
	}
	
	function RestoreScrollPosition() {
		setTimeout(function() {
			if (GetLastScrollHeight() != null) {
				var y = parseInt(GetLastScrollPosition());
				var h = parseInt(GetLastScrollHeight());
				if ($(document).height() != h) {
					y = (y * $(document).height()) / h;
				}
				window.scrollTo( 0, y);
			}
			setTimeout(function() {
				RemoveStyleElement();
			}, 1 );
		}, 1 );
	};
	
	function ContentUpdated() {
		if  (!navigator.cookieEnabled) {
			RemoveStyleElement();
			return;
		}

		RestoreScrollPosition();
		setInterval(Tick, 1000);
	}

	window.ff.CharacterNoteElement = '<a href="character_note.html">';

	document.addEventListener("contentupdated", function(){
		ContentUpdated();
	}, false);
})();
