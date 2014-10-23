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

@implementation FLYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //清空上次登录信息
//   [FLYBaseUtil clearUserInfo];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#pragma mark push
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

#pragma mark callback
//独立客户端回调函数
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
	[self parse:url application:application];
	return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
    //结果处理
    AlixPayResult* result = [self handleOpenURL:url];
    
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
            //交易成功
            NSString* key = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB";
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                [self toPayResult:@"充值成功"];
                NSLog(@"充值成功");
            }
        }
        else
        {
            [self toPayResult:@"充值失败"];
            NSLog(@"充值失败");
        }
    }
    else
    {
        [self toPayResult:@"充值失败"];
        NSLog(@"充值失败");
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

- (void)toPayResult:(NSString *)result{
    FLYPayResultViewController *resultController = [[FLYPayResultViewController alloc]init];
    resultController.result = result;
    [_rootController.navigationController pushViewController:resultController animated:NO];
}



@end
