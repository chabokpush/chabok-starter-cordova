var exec = require('cordova/exec');

const bridgeName = 'ChabokPush';

exports.init = function (options, success, error) {
    var params = Array.from(Object.values(options), k => k);
    exec(success, error, bridgeName, 'init', params);
};

exports.registerAsGuest = function (success, error) {
    exec(success, error, bridgeName, 'registerAsGuest');
};

exports.register = function (userName, success, error) {
    exec(success, error, bridgeName, 'register', [userName]);
};

exports.unregister = function () {
    exec(function () {
    }, function () {
    }, bridgeName, 'unregister', []);
};

exports.addTag = function (tagName, success, error) {
    exec(success, error, bridgeName, 'addTag', [tagName]);
};

exports.removeTag = function (tagName, success, error) {
    exec(success, error, bridgeName, 'removeTag', [tagName]);
};

exports.appWillOpenUrl = function (url) {
    exec(function () {
    }, function () {
    }, bridgeName, 'appWillOpenUrl', [url]);
};

exports.getUserInfo = function (success, error) {
    exec(success, error, bridgeName, 'getUserInfo', []);
};

exports.setUserInfo = function (userInfo) {
    exec(function () {
    }, function () {
    }, bridgeName, 'setUserInfo', [userInfo]);
};

exports.setDefaultTracker = function (trackerName) {
    exec(function () {
    }, function () {
    }, bridgeName, 'setDefaultTracker', [trackerName]);
};

exports.track = function (trackName, data) {
    exec(function () {
    }, function () {
    }, bridgeName, 'track', [trackName, data]);
};

exports.resetBadge = function () {
    exec(function () {
    }, function () {
    }, bridgeName, 'resetBadge', []);
};

exports.publish = function (message, success, error) {
    exec(success, error, bridgeName, 'publish', [message]);
};

exports.getUserId = function (success, error) {
    exec(success, error, bridgeName, 'getUserId', []);
};

exports.getInstallationId = function (success, error) {
    exec(success, error, bridgeName, 'getInstallationId', []);
};