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
#import "FLYToast.h"


//NSUserDefaults
//1.token 用户令牌
//2.memberId 用户ID
//3.memberPhone 用户账号
//4.memberName 用户姓名
//5.memberCarno 用户默认车牌号
//6.memberType 用户类型
//7.offline 离线浏览模式
//8.city    上次缓存城市
//9.regionVersion   版本

@implementation FLYBaseUtil

+(BOOL)checkUserLogin{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *memberId = [defaults stringForKey:@"memberId"];
    if (token == nil || memberId == nil || token.length <= 0 || memberId.length <= 0) {
        return false;
    }
    return true;
}

+(BOOL)checkUserBindCar{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
    if (memberCarno == nil || memberCarno.length <= 0) {
        return false;
    }
    return true;
}

+(BOOL)isOffline{
    BOOL flag = NO;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *offline = [defaults stringForKey:@"offline"];
    //离线请求数据库
    if ([FLYBaseUtil isNotEmpty:offline] && [offline isEqualToString:@"YES"]) {
        flag = YES;
    }
    return flag;
}

+(BOOL)isNoPic{
    BOOL flag = NO;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *offline = [defaults stringForKey:@"noPic"];
    //离线请求数据库
    if ([FLYBaseUtil isNotEmpty:offline] && [offline isEqualToString:@"YES"]) {
        flag = YES;
    }
    return flag;
}

+(NSString *)getCity{
    NSString *city = nil;
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([FLYBaseUtil isNotEmpty:appDelegate.city]) {
        city = appDelegate.city;
    }else{
        city = [defaults stringForKey:@"city"];
    }
    
    if ([FLYBaseUtil isEmpty:city]) {
        city = @"武汉市";
    }
    return city;
}


+(void)clearUserInfo{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"token"];
    [defaults setObject:nil forKey:@"memberId"];
    [defaults setObject:nil forKey:@"memberPhone"];
    [defaults setObject:nil forKey:@"memberName"];
    [defaults setObject:nil forKey:@"memberCarno"];
    [defaults setObject:nil forKey:@"memberType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isNotEmpty:(NSString *)str{
    if (str != nil && str.length > 0) {
        return true;
    }
    return false;
}

+(BOOL)isEmpty:(NSString *)str{
    if (str == nil || str.length == 0) {
        return true;
    }
    return false;
}

// 是否wifi
+(BOOL)isEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否打开网络
+(BOOL)isEnableInternate {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

+(void)showMsg:(NSString *)msg{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:msg leftButtonTitle:nil rightButtonTitle:@"确认"];
    [alert show];
}

+(void)networkError{
    [FLYToast showWithText:@"连接失败"];
}

//判断是否为整形：
+(BOOL)isPureInt:(NSString*)string{
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：
+ (BOOL)isPureFloat:(NSString*)string{
    NSScanner *scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

//判断是否为数字
+ (BOOL)isPureNumber:(NSString*)string{
    return ([FLYBaseUtil isPureInt:string] || [FLYBaseUtil isPureFloat:string]);
}

+ (NSMutableArray *)getDelegateShop{
    NSMutableArray *result;
    FLYAppDelegate *appDelegate = (FLYAppDelegate *) [UIApplication sharedApplication].delegate;
    if(appDelegate.shopArray != nil){
        result = appDelegate.shopArray;
    }else{
        result = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return result;
}

+ (void)setDelegateShop:(NSMutableArray *)shopArray{
    FLYAppDelegate *appDelegate = (FLYAppDelegate *) [UIApplication sharedApplication].delegate;
    appDelegate.shopArray = shopArray;
}



@end
