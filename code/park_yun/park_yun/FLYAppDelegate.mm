//
//  FLYAppDelegate.m
//  park_yun
//
//  Created by chen on 14-6-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYAppDelegate.h"

#import "FLYBaseNavigationController.h"

@implementation FLYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FLYBaseUtil clearUserInfo];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"U2NLMulqHTdAa5hnalS2Ps9c"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    _rootController = [[FLYMainViewController alloc] initWithNibName:@"FLYMainViewController" bundle:nil];
    FLYBaseNavigationController *navController = [[FLYBaseNavigationController alloc] initWithRootViewController:_rootController];
    navController.delegate = self;
    self.window.rootViewController = navController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ( viewController ==  self.rootController) {
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
