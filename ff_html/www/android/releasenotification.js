/**
 *	Constructor
 */
var ReleaseNotification = function() { 
}

/**
 * start polling.
 * 
 * @param site Root path for FFSite.
 * @param lastEtag last catalogue.js's etag.
 * @param lastSid last catalogue.js's lastSid.
 * @param title Title.
 * @param defaultPushMessage Default push message.
 */
ReleaseNotification.prototype.start = function(site, lastEtag, lastSid, title, defaultPushMessage) {
    return PhoneGap.exec(null, null, 'ReleaseNotification', 'start', [site, lastEtag, lastSid, title, defaultPushMessage]);
};

/**
 * stop polling.
 */
ReleaseNotification.prototype.stop = function() {
    return PhoneGap.exec(null, null, 'ReleaseNotification', 'stop', []);
};

/**
 * Updated when app is foreground.
 * 
 * @param etag catalogue.js's etag.
 * @param sid catalogue.js's lastSid.
 * @param toNextRelease tonextrelease.txt's content.
 */
ReleaseNotification.prototype.updated = function(etag, sid, toNextRelease) {
    return PhoneGap.exec(null, null, 'ReleaseNotification', 'updated', [etag, sid, toNextRelease]);
};

ReleaseNotification.prototype.getToken = function(successFunc, errorFunc) {
    return PhoneGap.exec(successFunc, errorFunc, 'ReleaseNotification', 'getToken', []);
};

ReleaseNotification.prototype.setToken = function(token) {
    return PhoneGap.exec(null, null, 'ReleaseNotification', 'setToken', [token]);
};

/**
 * 	Load ReleaseNotification
 */

PhoneGap.addConstructor(function() {
	PhoneGap.addPlugin('releasenotification', new ReleaseNotification());
});
