//
//  SmartPushManager.h
//  talele
//
//  Created by Henrique Valcanaia on 5/30/15.
//  Copyright (c) 2015 Terra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SmartpushSDK/SmartpushSDK.h>

@interface SmartpushManager : NSObject{
    SmartpushDevice *device;
}

+(SmartpushManager*)sharedSmartpushManager;

-(NSString*)getDeviceAlias;
-(BOOL)hasDevice;

@end
