/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        this.receivedEvent('deviceready');

        console.log('------------------');

        console.log('cordova.plugins = ', JSON.stringify(cordova.plugins.ChabokPush));

        let options = {
            appId: 'APP_ID/SENDER_ID',
            apiKey: 'API_KEY',
            username: 'USERNAME',
            password: 'PASSWORD',
            devMode: DEV_MODE
        }
        console.log('----- options = ', options);

        cordova.plugins.ChabokPush.init(options, function (s) {
            console.log('Initialize successfully.');
        }, function (err) {
            console.error('Could not initialize = ', err);
        });

        cordova.plugins.ChabokPush.getUserId((userId)=>{
            cordova.plugins.ChabokPush.register(userId, (s)=>{
                console.log('Registered user successfully');

                cordova.plugins.ChabokPush.track('registerAgain', {id: 123});

                cordova.plugins.ChabokPush.addTag('CORDOVA-AGAIN');

                cordova.plugins.ChabokPush.setUserInfo({firstName: 'Hussein'});
            },(e)=>{
                console.error('Fail to register user = ', e);
            });
        }, (error) => {
            cordova.plugins.ChabokPush.registerAsGuest((s)=>{
                console.log('------------------ Registered successfully');

                cordova.plugins.ChabokPush.track('guestUser', {id: 123});
                cordova.plugins.ChabokPush.addTag('CORDOVA');

                cordova.plugins.ChabokPush.setUserInfo({firstName: 'Hussein'});
            },(e)=>{
                console.error('----------------- Fail to register = ', e);
            });
        })
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();