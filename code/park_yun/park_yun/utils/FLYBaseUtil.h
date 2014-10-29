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

//是否离线 YES离线 NO在线
+(BOOL)isOffline;

//无图模式
+(BOOL)isNoPic;

//获取当前城市
+(NSString *)getCity;

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

//判断是否为整形：
+(BOOL)isPureInt:(NSString*)string;

//判断是否为浮点形：
+ (BOOL)isPureFloat:(NSString*)string;

//判断是否为数字
+ (BOOL)isPureNumber:(NSString*)string;

@end
