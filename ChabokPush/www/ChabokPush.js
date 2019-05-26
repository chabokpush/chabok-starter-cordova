var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {

    console.log('~~~~~~~~~~~~~~~~~~~~>>>>>>>>>');
    exec(success, error, 'ChabokPush', 'coolMethod', [arg0]);
};

console.log('cccccccccccc')