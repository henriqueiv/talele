//
//  SmartPushManager.m
//  talele
//
//  Created by Henrique Valcanaia on 5/30/15.
//  Copyright (c) 2015 Terra. All rights reserved.
//

#import "SmartpushManager.h"

@implementation SmartpushManager

+(SmartpushManager*)sharedSmartpushManager {
    static SmartpushManager *sharedSmartpushManager = nil;
    @synchronized(self){
        if (sharedSmartpushManager == nil) {
            sharedSmartpushManager = [[self alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:sharedSmartpushManager
                                                     selector:@selector(verificaDeviceAlias)
                                                         name:SmartpushSDKDeviceAddedNotification
                                                       object:nil];
        }
    }
    
    return sharedSmartpushManager;
}

-(BOOL)hasDevice{
    return device ? YES : NO;
}

-(void)verificaDeviceAlias{
    device = [[SmartpushSDK sharedInstance] getDevice];
    if(device){
        [[SmartpushSDK sharedInstance] requestCurretUserInformation];
    }
}

-(NSString*)getDeviceAlias{
    if (device) {
        return device.alias;
    }
    return @"";
}

@end
