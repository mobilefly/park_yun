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
#import "BaiduMobStat.h"

@implementation FLYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //清空上次登录信息
//  [FLYBaseUtil clearUserInfo];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
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

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
