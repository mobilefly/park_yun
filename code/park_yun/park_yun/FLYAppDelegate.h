//
//  FLYAppDelegate.h
//  park_yun
//
//  Created by chen on 14-6-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYMainViewController.h"
#import "BMapKit.h"

@interface FLYAppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate>{
    BMKMapManager* _mapManager;
   
    
}

@property (strong, nonatomic) NSMutableArray *shopArray;

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

// 0.版本检测中 1.最新版本 2.有新版本下载
@property (nonatomic) int version_index;

@end
