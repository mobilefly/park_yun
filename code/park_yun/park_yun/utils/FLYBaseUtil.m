//
//  FLYMemberUtil.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseUtil.h"
#import "Reachability.h"
#import "DXAlertView.h"

@implementation FLYBaseUtil

+(BOOL)checkUserLogin{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    if (token == nil || token.length <= 0) {
        return false;
    }
    return true;
}

+(void)clearUserInfo{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"token"];
    [defaults setObject:nil forKey:@"memberId"];
    [defaults setObject:nil forKey:@"memberPhone"];
    [defaults setObject:nil forKey:@"memberName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isNotEmpty:(NSString *)str{
    if (str != nil && str.length > 0) {
        return true;
    }
    return false;
}

// 是否wifi
+(BOOL) isEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否打开网络
+(BOOL) isEnableInternate {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

+(void)alertMsg:(NSString *)msg{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:msg leftButtonTitle:nil rightButtonTitle:@"确认"];
    [alert show];
}


+(void)alertErrorMsg{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"连接失败" leftButtonTitle:nil rightButtonTitle:@"确认"];
    [alert show];
}


@end
