//
//  AppDelegate+ChabokPush
//  pushtest
//
//  Created by Chabok Realtime Solutions on 2019.
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
@import UserNotifications;
#import "AppDelegate+ChabokPush.h"
#import <AdpPushClient/AdpPushClient.h>

@implementation AppDelegate (ChabokPush)

// its dangerous to override a method from within a category.
// Instead we will use method swizzling. we set this up in the load call.
+ (void)load
{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

    //Launch:
    SwizzleInstanceMethods(self,
                           @selector(application:didFinishLaunchingWithOptions:),
                           @selector(swizzled_application:didFinishLaunchingWithOptions:));
    
    //Notification:
    SwizzleInstanceMethods(self,
                       @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:),
                       @selector(swizzled_application:didRegisterForRemoteNotificationsWithDeviceToken:));
    SwizzleInstanceMethods(self,
                       @selector(application:didFailToRegisterForRemoteNotificationsWithError:),
                       @selector(swizzled_application:didFailToRegisterForRemoteNotificationsWithError:));
    SwizzleInstanceMethods(self,
                       @selector(application:didRegisterUserNotificationSettings:),
                       @selector(swizzled_application:didRegisterUserNotificationSettings:));

    //Deep-link:
    SwizzleInstanceMethods(self,
                           @selector(application:openURL:options:),
                           @selector(swizzled_application:openURL:options:));

    SwizzleInstanceMethods(self,
                           @selector(application:continueUserActivity:restorationHandler:),
                           @selector(swizzled_application:continueUserActivity:restorationHandler:));
#pragma clang diagnostic pop
}

static void SwizzleInstanceMethods(Class klass, SEL original, SEL new)
{
    Method origMethod = class_getInstanceMethod(klass, original);
    Method newMethod = class_getInstanceMethod(klass, new);
    
    if (class_addMethod(klass, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(klass, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

#pragma mark - Launch
- (BOOL)swizzled_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [PushClientManager.defaultManager addDelegate:self];
    [PushClientManager.defaultManager application:UIApplication.sharedApplication
                    didFinishLaunchingWithOptions:launchOptions];
    
    return [self swizzled_application:application didFinishLaunchingWithOptions:launchOptions];
}

#pragma mark - Notification permission

- (void)swizzled_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    // Hook and handle failure of get Device token from Apple APNS Server
    [PushClientManager.defaultManager application:application
 didFailToRegisterForRemoteNotificationsWithError:error];
    NSLog(@"---------\n\n didFailToRegisterForRemoteNotificationsWithError \n\n");
}

- (void)swizzled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    // Manager hook and handle receive Device Token From APNS Server
    [PushClientManager.defaultManager application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    NSLog(@"---------\n\n didRegisterForRemoteNotificationsWithDeviceToken \n\n");
}

- (void)swizzled_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    // Manager hook and Handle iOS 8 remote Notificaiton Settings
    [PushClientManager.defaultManager application:application didRegisterUserNotificationSettings:notificationSettings];
    NSLog(@"---------\n\n didRegisterUserNotificationSettings \n\n");
}

#pragma mark - deep link

-(BOOL) swizzled_application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    [PushClientManager.defaultManager appWillOpenUrl:url];
    
    return [self swizzled_application:app openURL:url options:options];
}

//TODO: FIX build by xcode 9
-(BOOL) swizzled_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [PushClientManager.defaultManager appWillOpenUrl:[userActivity webpageURL]];
    }
    
    return [self swizzled_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

@end
