
const  bridgeName = 'ChabokPush';

var ChabokPush = function () {}


ChabokPush.prototype.init = function (options, success, error) {
    var params = Array.from(Object.values(options), k => k);
    cordova.exec(success, error, bridgeName, 'init', params);
};

ChabokPush.prototype.registerAsGuest = function (success, error) {
    cordova.exec(success, error, bridgeName, 'registerAsGuest');
};

ChabokPush.prototype.register = function (userId, success, error) {
    cordova.exec(success, error, bridgeName, 'register', [userId]);
};

ChabokPush.prototype.unregister = function () {
    cordova.exec(function () {
    }, function () {
    }, bridgeName, 'unregister', []);
};

ChabokPush.prototype.addTag = function (tagName, success, error) {
    cordova.exec(success, error, bridgeName, 'addTag', [tagName]);
};

ChabokPush.prototype.removeTag = function (tagName, success, error) {
    cordova.exec(success, error, bridgeName, 'removeTag', [tagName]);
};

ChabokPush.prototype.appWillOpenUrl = function (url) {
    cordova.exec(function () {
    }, function () {
    }, bridgeName, 'appWillOpenUrl', [url]);
};

ChabokPush.prototype.getUserInfo = function (success, error) {
    cordova.exec(success, error, bridgeName, 'getUserInfo', []);
};

ChabokPush.prototype.setUserInfo = function (userInfo) {
    cordova.exec(function () {
    }, function () {
    }, bridgeName, 'setUserInfo', [userInfo]);
};

ChabokPush.prototype.setDefaultTracker = function (trackerName) {
    cordova.exec(function () {
    }, function () {
    }, bridgeName, 'setDefaultTracker', [trackerName]);
};

ChabokPush.prototype.track = function (trackName, data) {
    cordova.exec(function () {
    }, function () {
    }, bridgeName, 'track', [trackName, data]);
};

ChabokPush.prototype.resetBadge = function () {
    cordova.exec(function () {
    }, function () {
    }, bridgeName, 'resetBadge', []);
};

ChabokPush.prototype.publish = function (message, success, error) {
    cordova.exec(success, error, bridgeName, 'publish', [message]);
};

ChabokPush.prototype.getUserId = function (success, error) {
    cordova.exec(success, error, bridgeName, 'getUserId', []);
};

ChabokPush.prototype.getInstallationId = function (success, error) {
    cordova.exec(success, error, bridgeName, 'getInstallationId', []);
};


//-------------------------------------------------------------------

if(!window.plugins)
    window.plugins = {};

if (!window.plugins.OneSignal)
    window.plugins.ChabokPush = new ChabokPush();

if (typeof module != 'undefined' && module.exports)
    module.exports = ChabokPush;
