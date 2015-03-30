//
//  FLYAppDelegate.m
//  park_yun
//
//  Created by chen on 14-6-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYAppDelegate.h"

#import "FLYBaseNavigationController.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "FLYPayResultViewController.h"
#import "BaiduMobStat.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "SecurityUtil.h"
#import "NSString+MD5HexDigest.h"
#import "NSData+AES.h"
#import "FLYDataService.h"
#import "FLYMemberModel.h"

@implementation FLYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //清空上次登录信息
//    [FLYBaseUtil clearUserInfo];
    
    [self autoLogin];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.version_index = 0;
    
    //注册推送服务
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
    //百度统计
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    // 是否允许截获并发送崩溃信息，请设置YES或者NO
    statTracker.enableExceptionLog = NO;
    //根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略
    statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch;
    //打开调试模式，发布时请去除此行代码或者设置为False即可。
    statTracker.enableDebugOn = NO;
    //是否仅在WIfi情况下发送日志数据
    statTracker.logSendWifiOnly = YES;
    //设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    //statTracker.sessionResumeInterval = 1;
    [statTracker startWithAppId:kBaiduStat];
    
    //初始化讯飞语音
    NSString *initString = [NSString stringWithFormat:@"appid=%@",kXunfeiKey];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    
    //初始化百度地图
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:kBaiduKey generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //向微信注册
    [WXApi registerApp:@"wx58062b2b7eba907f"];
    
    //主页面
    _rootController = [[FLYMainViewController alloc] initWithNibName:@"FLYMainViewController" bundle:nil];
    FLYBaseNavigationController *navController = [[FLYBaseNavigationController alloc] initWithRootViewController:_rootController];
    navController.delegate = self;
    self.window.rootViewController = navController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

//隐藏首页topbar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController ==  self.rootController) {
        [navigationController setNavigationBarHidden:YES animated:animated];
    } else if ( [navigationController isNavigationBarHidden] ) {
        [navigationController setNavigationBarHidden:NO animated:animated];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //设置消息推送数字为0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#pragma mark - 推送
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]; //去掉"<>"
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"regisger success:%@",token);
    [defaults setObject:token forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"收到推送消息:%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Registfail%@",error);
}

#pragma mark - 数据请求
//自动登录
- (void)autoLogin{
   
    if ([FLYBaseUtil isEnableInternate]) {
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *memberPhone = [defaults stringForKey:@"memberPhone"];
        NSString *memberPassword = [defaults stringForKey:@"memberPassword"];
        
        if ([FLYBaseUtil isNotEmpty:memberPhone] && [FLYBaseUtil isNotEmpty:memberPassword]) {
            
            NSString *passMd5 = [memberPassword md5HexDigest];
            
            NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
            NSString *key = [NSString stringWithFormat:@"%@,%@,%@",uuid,ts,passMd5];
            
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            NSString *deviceToken = [defaults stringForKey:@"deviceToken"];
            NSString *deviceId = [SecurityUtil encodeBase64String:deviceToken];
            
            NSData *keyValue = [key dataUsingEncoding:NSUTF8StringEncoding];
            Byte keyByte[] = {0x0f, 0x07, 0x0d, 0x00, 0x07, 0x07, 0x02, 0x0c, 0x06, 0x06, 0x0f, 0x0e, 0x03, 0x02, 0x0a,0x0d, 0x0b, 0x0d, 0x0b, 0x03, 0x02, 0x05, 0x03, 0x0e, 0x0c, 0x00, 0x0d, 0x08, 0x0f, 0x0d, 0x0b, 0x09};
            
            //byte转换为NSData类型，以便下边加密方法的调用
            NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
            
            NSData *cipherTextData =[keyValue AES256EncryptWithKey:keyData];
            key = [SecurityUtil encodeBase64Data:cipherTextData];
            
            
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           memberPhone,
                                           @"username",
                                           uuid,
                                           @"guid",
                                           ts,
                                           @"ts",
                                           key,
                                           @"key",
                                           deviceId,
                                           @"deviceId",
                                           nil];
            
            //防止循环引用
            __weak FLYAppDelegate *ref = self;
            [FLYDataService requestWithURL:kHttpLogin params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadLoginData:result];
            } errorBolck:^(){
            }];
        }
    }
}

- (void)loadLoginData:(id)data{
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSDictionary *memberDic = [result objectForKey:@"member"];
            FLYMemberModel *memberModel = [[FLYMemberModel alloc] initWithDataDic:memberDic];
            NSString *token = [result objectForKey:@"token"];
            
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberId forKey:@"memberId"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberName forKey:@"memberName"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberCarno forKey:@"memberCarno"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberType forKey:@"memberType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else{
        [FLYBaseUtil clearUserInfo];
    }
}

#pragma mark - 支付宝，微信支付回调
//独立客户端回调函数
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if ([url.scheme isEqualToString:kWXAppid]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else if([url.scheme isEqualToString:@"FLyAlipayParkSmart"]){
        [self parse:url application:application];
    }
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - 支付宝
//处理来源回调信息
- (void)parse:(NSURL *)url application:(UIApplication *)application {
    //结果处理
    AlixPayResult* result = [self handleOpenURL:url];
	if (result){
		if (result.statusCode == 9000){
            //交易成功
            NSString* key = kAplipayPublicKey;
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            if ([verifier verifyString:result.resultString withSign:result.signString]){
                [self toPayResult:@"支付成功"];
                NSLog(@"支付成功");
            }
        }
        else{
            [self toPayResult:@"支付失败"];
            NSLog(@"支付失败");
        }
    }
    else{
        [self toPayResult:@"支付失败"];
        NSLog(@"支付失败");
    }
}

- (AlixPayResult *)resultFromURL:(NSURL *)url {
	NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [[AlixPayResult alloc] initWithString:query];
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {
	AlixPayResult * result = nil;
	if (url != nil && [[url host] compare:@"safepay"] == 0) {
		result = [self resultFromURL:url];
	}
	return result;
}

#pragma mark - delegate WXApiDelegate(微信支付)
-(void) onResp:(BaseResp*)resp
{
    NSString *strTitle;
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                [self toPayResult:@"支付成功"];
                break;
                
            default:
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                [self toPayResult:@"支付失败"];
                break;
        }
    }
}

#pragma mark - 支付结果跳转
- (void)toPayResult:(NSString *)result{
    [FLYBaseUtil showMsg:result];
}


@end
