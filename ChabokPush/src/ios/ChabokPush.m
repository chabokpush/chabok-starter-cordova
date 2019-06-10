/********* ChabokPush.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import <AdpPushClient/AdpPushClient.h>

id <CDVCommandDelegate> pluginCommandDelegate;

void successCallback(NSString* callbackId, NSDictionary* data) {
    CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
    commandResult.keepCallback = @1;
    [pluginCommandDelegate sendPluginResult:commandResult callbackId:callbackId];
}

void failureCallback(NSString* callbackId, NSDictionary* data) {
    CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:data];
    commandResult.keepCallback = @1;
    [pluginCommandDelegate sendPluginResult:commandResult callbackId:callbackId];
}

@interface ChabokPush : CDVPlugin <PushClientManagerDelegate> {
    NSString * _onMessageCallback;
    NSString * _onRegisterCallback;
    NSString * _onConnectionStatusCallback;
}
  // Member variables go here.
@property (nonatomic, retain) NSString *appId;

//@property (class) NSDictionary *coldStartNotificationResult;

@property (nonatomic, retain) NSString *onMessageCallback;
@property (nonatomic, retain) NSString *onRegisterCallback;
@property (nonatomic, retain) NSString *onConnectionStatusCallback;
//@property (nonatomic, retain) NSString *notificationOpenedCallback;

-(void)init:(CDVInvokedUrlCommand *)command;
-(void)registerAsGuest:(CDVInvokedUrlCommand *)command;
-(void)register:(CDVInvokedUrlCommand *)command;
-(void) unregister:(CDVInvokedUrlCommand *)command;

-(void) getUserId:(CDVInvokedUrlCommand *) command;
-(void) getInstallationId:(CDVInvokedUrlCommand *) command;

-(void) addTag:(CDVInvokedUrlCommand *) command;
-(void) removeTag:(CDVInvokedUrlCommand *) command;

-(void) publish:(CDVInvokedUrlCommand *) command;
-(void) resetBadge:(CDVInvokedUrlCommand *) command;
-(void) track:(CDVInvokedUrlCommand *) command;
-(void) setDefaultTracker:(CDVInvokedUrlCommand *) command;

@end

@implementation ChabokPush

@synthesize onRegisterCallback = _onRegisterCallback;

//@dynamic coldStartNotificationResult;
//static NSDictionary *_coldStartNotificationResult;

-(void)init:(CDVInvokedUrlCommand*)command {
    
    BOOL devMode = [command.arguments objectAtIndex:4];
    NSString *appId = [command.arguments objectAtIndex:0];
    NSString *apiKey = [command.arguments objectAtIndex:1];
    NSString *username = [command.arguments objectAtIndex:2];
    NSString *password = [command.arguments objectAtIndex:3];
    
    if (!appId || !apiKey || !username || !password) {
        NSLog(@"Invalid initialize parameters.");
    }
    
    [PushClientManager setDevelopment:devMode];
    [PushClientManager.defaultManager setEnableLog:YES];
    [PushClientManager.defaultManager addDelegate:self];

    NSArray *appIds = [appId componentsSeparatedByString:@"/"];
    self.appId = appIds.firstObject;
    
    BOOL state = [PushClientManager.defaultManager registerApplication:self.appId
                                                                apiKey:apiKey
                                                              userName:username
                                                              password:password];
    
    CDVPluginResult* pluginResult = nil;
    if (state) {
        NSString *msg = @"Initilized sucessfully";
        
        NSLog(msg);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:msg];
    } else {
        NSString *msg = @"Could not init chabok parameters";
        
        NSLog(msg);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
    }

    //[PushClientManager.defaultManager application:UIApplication.sharedApplication
    //                didFinishLaunchingWithOptions:nil];
    
    if (!command.callbackId) {
        return;
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - Register

-(void)registerAsGuest:(CDVInvokedUrlCommand*)command {
    NSLog(@"--------------------- registerAsGuest command = %@ , callbackId = %@", command, command.callbackId);
    NSString *callbackId = command.callbackId;
    NSLog(@"--------------------- registerAsGuest callbackId = %@ && type = %@", callbackId, [callbackId class]);

//    _onRegisterCallback = @"TESTT";
    [self setOnRegisterCallback:command];
    NSLog(@"--------------------- registerAsGuest onRegisterCallback = %@", _onRegisterCallback);
    
    BOOL state = [PushClientManager.defaultManager registerAsGuest];
}

-(void)register:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    
    NSString *userId = [command.arguments objectAtIndex:0];
    if (!userId || [userId isEqual:[NSNull null]]){
        NSString *msg = @"Could not register userId to chabok";
        
        NSLog(msg);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
        return;
    }
    
    BOOL state = [PushClientManager.defaultManager registerUser:userId
                                                       channels:@[] registrationHandler:^(BOOL isRegistered, NSString *userId, NSError *error) {
                                                           CDVPluginResult* pluginResult = nil;

                                                           NSLog(@"isRegistered : %d userId : %@ error : %@",isRegistered, userId, error);
                                                           
                                                           if (error) {
                                                               if (command.callbackId) {
                                                                   NSDictionary *jsonDic = @{@"registered": @(NO),
                                                                                            @"error": error
                                                                                            };
                                                                   NSString *json = [self dictionaryToJson:jsonDic];
                                                                   
                                                                   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:json];
                                                                   
                                                                   [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                               }
                                                               
                                                               if (_onRegisterCallback){
                                                                   successCallback(_onRegisterCallback, @(false));
                                                               }
                                                           } else {
                                                               
                                                               if (command.callbackId) {
                                                                   NSDictionary *jsonDic = @{@"registered": @(YES)};
                                                                   NSString *json = [self dictionaryToJson:jsonDic];
                                                                   
                                                                   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json];
                                                                   
                                                                   [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                               }
                                                               if (_onRegisterCallback){
                                                                   successCallback(_onRegisterCallback, @(true));
                                                               }
                                                           }
                                                       }];
}

#pragma mark - unregister

-(void) unregister:(CDVInvokedUrlCommand*)command {
    [PushClientManager.defaultManager unregisterUser];
}

#pragma mark - user
-(void) getInstallationId:(CDVInvokedUrlCommand*) command {
    CDVPluginResult* pluginResult = nil;

    NSString *installationId = [PushClientManager.defaultManager getInstallationId];
    if (!installationId) {
        NSString *msg = @"The installationId is null, You didn't register yet!";
        
        NSLog(msg);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:installationId];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) getUserId:(CDVInvokedUrlCommand*) command {
    CDVPluginResult* pluginResult = nil;

    NSString *userId = [PushClientManager.defaultManager userId];
    if (!userId) {
        NSString *msg = @"The userId is null, You didn't register yet!";
        
        NSLog(msg);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:userId];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - tags

-(void) addTag:(CDVInvokedUrlCommand *) command {
    CDVPluginResult* pluginResult = nil;

    NSString *tagName = [command.arguments objectAtIndex:0];
    
    //TODO: This should handle in android sdk
    if (![PushClientManager.defaultManager getInstallationId]) {
        if (!command.callbackId) {
            return;
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"UserId not registered yet."];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    [PushClientManager.defaultManager addTag:tagName
                                     success:^(NSInteger count) {
                                         if (!command.callbackId) {
                                             return;
                                         }
                                         NSDictionary *jsonDic = @{@"count": @(count)};
                                         NSString *json = [self dictionaryToJson:jsonDic];
                                         
                                         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json];
                                         
                                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                     } failure:^(NSError *error) {
                                         if (!command.callbackId) {
                                             return;
                                         }

                                         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];

                                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                     }];
}

-(void) removeTag:(CDVInvokedUrlCommand *) command {
    CDVPluginResult* pluginResult = nil;
    
    NSString *tagName = [command.arguments objectAtIndex:0];
    
    [PushClientManager.defaultManager removeTag:tagName
                                     success:^(NSInteger count) {
                                         if (!command.callbackId) {
                                             return;
                                         }
                                         
                                         NSDictionary *jsonDic = @{@"count": @(count)};
                                         NSString *json = [self dictionaryToJson:jsonDic];
                                         
                                         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json];
                                         
                                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                     } failure:^(NSError *error) {
                                         if (!command.callbackId) {
                                             return;
                                         }
                                         
                                         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                                         
                                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                     }];
}

#pragma mark - publish

-(void) publish:(CDVInvokedUrlCommand *) command{
    CDVPluginResult* pluginResult = nil;

    NSDictionary *message = [command.arguments objectAtIndex:0];
    
    NSDictionary *data = [message valueForKey:@"data"];
    NSString *userId = [message valueForKey:@"userId"];
    NSString *content = [message valueForKey:@"content"];
    NSString *channel = [message valueForKey:@"channel"];
    
    PushClientMessage *chabokMessage;
    if (data) {
        chabokMessage = [[PushClientMessage alloc] initWithMessage:content withData:data toUserId:userId channel:channel];
    } else {
        chabokMessage = [[PushClientMessage alloc] initWithMessage:content toUserId:userId channel:channel];
    }
    
    BOOL publishState = [PushClientManager.defaultManager publish:chabokMessage];
    
    if (publishState) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    if (!command.callbackId) {
        return;
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - badge
-(void) resetBadge:(CDVInvokedUrlCommand *) command {
    [PushClientManager resetBadge];
}

#pragma mark - track
-(void) track:(CDVInvokedUrlCommand *) command {
    
    //TODO: This should handle in SDK
    if (![PushClientManager.defaultManager getInstallationId] || PushClientManager.defaultManager.connectionState != PushClientServerConnectedState) {
        NSLog(@"chabokpush ----------- Not connected, Queue the operation");
        [self enqueueWhenSessionIsConnected:^{
            NSLog(@"chabokpush ----------- Now connected and dequeue");
            [self track:command];
        }];
        return;
    }
    NSLog(@"chabokpush ----------- Track event called");
    NSString *trackName = [command.arguments objectAtIndex:0];
    NSDictionary *trackData = [command.arguments objectAtIndex:1];
    
    [PushClientManager.defaultManager track:trackName data:trackData];
}

#pragma mark - default tracker
-(void) setDefaultTracker:(CDVInvokedUrlCommand *) command {
    NSString *defaultTracker = [command.arguments objectAtIndex:0];

    [PushClientManager.defaultManager setDefaultTracker:defaultTracker];;
}

#pragma mark - userInfo
-(void) setUserInfo:(CDVInvokedUrlCommand *) command {
    NSDictionary *userInfo = [command.arguments objectAtIndex:0];

    [PushClientManager.defaultManager setUserInfo:userInfo];;
}

-(void) getUserInfo:(CDVInvokedUrlCommand *) command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary *userInfo = PushClientManager.defaultManager.userInfo;
    
    NSString *json = [self dictionaryToJson:userInfo];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:json];
    if (!command.callbackId) {
        return;
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - deeplink
-(void) appWillOpenUrl:(CDVInvokedUrlCommand *) command {
    CDVPluginResult* pluginResult = nil;
    NSString *link = [command.arguments objectAtIndex:0];

    if(!link){
        return;
    }
    
    NSURL *url = [[NSURL alloc] initWithString:link];
    [PushClientManager.defaultManager appWillOpenUrl:url];
}

//-(void) setNotificationOpenedHandler:(CDVInvokedUrlCommand *) command {
//    CDVPluginResult* pluginResult = nil;
//
//    [self sendEventWithName:@"notificationOpened" body:_coldStartNotificationResult];
//}

#pragma mark - callback
-(void) setOnMessageCallback:(CDVInvokedUrlCommand *) command{
    self.onMessageCallback = command.callbackId;
}

-(void) setOnRegisterCallback:(CDVInvokedUrlCommand *) command{
    _onRegisterCallback = command.callbackId;
}

-(void) setOnConnectionStatusCallback:(CDVInvokedUrlCommand *) command {
    self.onConnectionStatusCallback = command.callbackId;
}

//-(void) setNotificationOpenedHandler:(CDVInvokedUrlCommand *) command{
//    self.notificationOpened = command.callbackId;
//}

#pragma mark - delegate method
-(void) pushClientManagerDidChangedServerConnectionState {
    NSString *connectionState = @"";
    if (PushClientManager.defaultManager.connectionState == PushClientServerConnectedState) {
        connectionState = @"CONNECTED";
    } else if (PushClientManager.defaultManager.connectionState == PushClientServerConnectingState ||
               PushClientManager.defaultManager.connectionState == PushClientServerConnectingStartState) {
        connectionState = @"CONNECTING";
    } else if (PushClientManager.defaultManager.connectionState == PushClientServerDisconnectedState ||
               PushClientManager.defaultManager.connectionState == PushClientServerDisconnectedErrorState) {
        connectionState = @"DISCONNECTED";
    } else  if (PushClientManager.defaultManager.connectionState == PushClientServerSocketTimeoutState) {
        connectionState = @"SocketTimeout";
    } else {
        connectionState = @"NOT_INITIALIZED";
    }
    
    if (self.onConnectionStatusCallback) {
        successCallback(self.onConnectionStatusCallback, connectionState);
    }
}

-(void) pushClientManagerDidReceivedMessage:(PushClientMessage *)message{
    NSMutableDictionary *messageDict = [NSMutableDictionary.alloc initWithDictionary:[message toDict]];
    [messageDict setObject:message.channel forKey:@"channel"];
    
    if (self.onMessageCallback) {
        successCallback(self.onMessageCallback, messageDict);
    }
}

// called when PushClientManager Register User Successfully
- (void)pushClientManagerDidRegisterUser:(BOOL)registration{
    NSLog(@"------------ %@ %@ cid = %@",@(__PRETTY_FUNCTION__),@(registration), _onRegisterCallback);
    
    if (_onRegisterCallback) {
        NSDictionary *successDic = @{@"regisered":@(registration)};
        CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:successDic];
        [self.commandDelegate sendPluginResult:commandResult callbackId:_onRegisterCallback];
    }
}

// called when PushClientManager Register User failed
- (void)pushClientManagerDidFailRegisterUser:(NSError *)error{
    NSLog(@"------------ %@ %@ cid = %@",@(__PRETTY_FUNCTION__),error, _onRegisterCallback);
    
    if (_onRegisterCallback) {
        NSDictionary *errorDic = @{@"error":error.localizedDescription};
        CDVPluginResult* commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errorDic];
        [self.commandDelegate sendPluginResult:commandResult callbackId:_onRegisterCallback];
    }
}


#pragma mark - json
-(NSString *) dictionaryToJson:(NSDictionary *) dic{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - private
-(void) enqueueWhenSessionIsConnected:(void(^)(void))block{
    NSString *observerKey = kPushClientDidChangeServerConnectionStateNotification;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    __block __weak id observer = [[NSNotificationCenter defaultCenter]
                                  addObserverForName:observerKey
                                  object:nil
                                  queue:queue
                                  usingBlock:^(NSNotification * _Nonnull note) {
                                      if( PushClientManager.defaultManager.connectionState == PushClientServerConnectedState ) {
                                          [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                          block();
                                      }
                                  }];
}

@end
