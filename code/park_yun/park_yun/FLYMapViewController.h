//
//  FLYMapViewController.h
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "BMapKit.h"
#import "FLYBaseMap.h"

@interface FLYMapViewController : FLYBaseViewController<BMKMapViewDelegate,BMKLocationServiceDelegate,FLYMapDelegate>{
    
    FLYBaseMap *_mapBaseView;
    BMKLocationService *_locationService;
    
    BOOL _isFollow;
    BOOL _isLocation;
    
    BOOL _isLoading;
    
    double lastLat;
    double lastLon;
}

//当前经纬度
@property (nonatomic,strong)NSNumber *lat;
@property (nonatomic,strong)NSNumber *lon;

@property (strong, nonatomic)NSMutableDictionary *annotationDics;
@property (strong, nonatomic)NSMutableArray *locationDatas;


@end
