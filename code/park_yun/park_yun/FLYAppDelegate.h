//
//  FLYAppDelegate.h
//  park_yun
//
//  Created by chen on 14-6-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "FLYMainViewController.h"


@interface FLYAppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate>{
    BMKMapManager* _mapManager;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FLYMainViewController *rootController;

@end
