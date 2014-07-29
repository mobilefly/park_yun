//
//  FLYMemberUtil.h
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLYAppDelegate.h"

@interface FLYBaseUtil : NSObject

//
+(BOOL)checkUserLogin;

+(BOOL)checkUserBindCar;

//清楚用户状态
+(void)clearUserInfo;

//字符串是否不为空
+(BOOL)isNotEmpty:(NSString *)str;

+(BOOL)isEmpty:(NSString *)str;

// 是否wifi
+(BOOL)isEnableWIFI;

// 是否打开网络
+(BOOL)isEnableInternate;

+(void)alertMsg:(NSString *)msg;
//
+(void)alertErrorMsg;

@end
