//
//  FLYBaseMap.h
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "BMapKit.h"


@protocol FLYMapDelegate <NSObject>
@required
//跟随
- (void)mapFollow:(BOOL)enable;

//定位
- (void)mapLocation;
@end


@interface FLYBaseMap : UIView{
    BOOL _isFollow;
}


@property(strong,nonatomic) UIButton *mapTypeBtn;
@property(strong,nonatomic) UIButton *trafficBtn;

@property(strong,nonatomic) UIButton *zoomInBtn;
@property(strong,nonatomic) UIButton *zoomOutBtn;

@property(strong,nonatomic) UIButton *locationBtn;
@property(strong,nonatomic) UIButton *followBtn;

@property(strong,nonatomic) BMKMapView *mapView;

@property(strong,nonatomic)id<FLYMapDelegate> mapDelegate;

@end


