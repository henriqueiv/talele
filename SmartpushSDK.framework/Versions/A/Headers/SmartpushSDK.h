//
//  InstadSDK.h
//  AnunciosPush
//
//  Created by William Hass on 7/27/14.
//  Copyright (c) 2014 William Hass. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SmartpushDevice.h"
#import "SmartpushUser.h"

@protocol SmartpushSDKDelegate <NSObject>

@optional

- (void)onPushAccepted:(NSDictionary *)push;

@end

@class UIUserNotificationSettings, SmartpushUser;

@interface SmartpushSDK : NSObject

extern NSString * const SmartpushSDKDeviceAddedNotification;
extern NSString * const SmartpushSDKUserInfoObtainedNotification;
extern NSString * const SmartpushSDKBlockUserNotification;

@property (strong, nonatomic) UIWindow *window;

- (NSString *)getDeviceToken;

- (void)registerForPushNotifications;

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void)didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

+ (id)sharedInstance;

- (SmartpushDevice *)getDevice;
- (SmartpushUser *)getUserInfo;
- (void)setValue:(NSString *)value forTag:(NSString *)key;
- (void)nearestZoneWithLatitude:(double)latitude andLongitude:(double)longitude;
- (void)blockUser:(BOOL)block;
- (void)requestCurretUserInformation;

@property (weak, nonatomic) UIResponder<SmartpushSDKDelegate> * delegate;

@end
