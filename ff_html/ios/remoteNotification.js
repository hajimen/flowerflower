function RemoteNotification() {
}

/*
* successFunc: function(devideToken): deviceToken is base64 encoded
* errorFunc: function(errorMessage): errorMessage is localized
*/
RemoteNotification.prototype.register = function(successFunc, errorFunc, options) {
    PhoneGap.exec(successFunc, errorFunc, "org.kaoriha.phonegap.plugins.remotenotification", "register_", [options]);
};

RemoteNotification.prototype.clearBadge = function(successFunc, errorFunc, options) {
    PhoneGap.exec(successFunc, errorFunc, "org.kaoriha.phonegap.plugins.remotenotification", "clearBadge", [options]);
};

RemoteNotification.prototype.enabledTypes = function(successFunc, errorFunc, options) {
    PhoneGap.exec(successFunc, errorFunc, "org.kaoriha.phonegap.plugins.remotenotification", "enabledTypes", [options]);
};

function RNglp(payload) {
    window.plugins.remoteNotification.launchPayload = null;
    if (payload !== null) {
        window.plugins.remoteNotification.launchPayload = payload;
        RemoteNotificationFireEvent(payload);
    }
    delete RNglp;
}

function RemoteNotificationFireEvent(payload) {
    var e = document.createEvent('Events'); 
    e.initEvent('remoteNotification');
    e.payload = payload;
    document.dispatchEvent(e);
}

document.addEventListener('deviceready', function() {
    PhoneGap.exec(RNglp, null, "org.kaoriha.phonegap.plugins.remotenotification", "getLaunchPayload", []);
    PhoneGap.exec(null, null, "org.kaoriha.phonegap.plugins.remotenotification", "readyRemoteNotificationFireEvent", []);
}, false);

PhoneGap.addConstructor(function() 
{
if(!window.plugins)
{
window.plugins = {};
}
window.plugins.remoteNotification = new RemoteNotification();
});