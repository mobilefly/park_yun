//
//  FLYMapViewController.h
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "BMapKit.h"

@interface FLYMapViewController : FLYBaseViewController<BMKMapViewDelegate,BMKLocationServiceDelegate>{
    BMKMapView *_mapView;
    BMKLocationService *_locationService;
    

}

//当前经纬度
@property (nonatomic,strong)NSNumber *lat;
@property (nonatomic,strong)NSNumber *lon;;


@end
