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

//页面回调
@property (copy, nonatomic) NSString *reloadFlag;
//当前城市
@property (copy, nonatomic) NSString *city;
//当前位置
@property(nonatomic,assign) CLLocationCoordinate2D coordinate;

//缓存城市停车场数据
@property (strong, nonatomic) NSMutableArray *cityDatas;


@end
