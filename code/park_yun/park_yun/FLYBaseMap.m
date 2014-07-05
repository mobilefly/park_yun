//
//  FLYBaseMap.m
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseMap.h"

@implementation FLYBaseMap

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isFollow = false;
        [self _initView];
    }
    return self;
}

- (void)_initView{
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectZero];
    //显示当前位置
    _mapView.showsUserLocation = YES;
    //显示比例次
    _mapView.showMapScaleBar = true;
    
    _mapTypeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _trafficBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _zoomInBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _zoomOutBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _locationBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _followBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    
    [_mapTypeBtn setImage:[UIImage imageNamed:@"mfpparking_2d_all_0.png"] forState:UIControlStateNormal];
    [_trafficBtn setImage:[UIImage imageNamed:@"mfpparking_luk_all_up.png"] forState:UIControlStateNormal];
    [_zoomInBtn setImage:[UIImage imageNamed:@"mfpparking_jia_all_up.png"] forState:UIControlStateNormal];
    [_zoomOutBtn setImage:[UIImage imageNamed:@"mfpparking_jian_all_up.png"] forState:UIControlStateNormal];
    [_locationBtn setImage:[UIImage imageNamed:@"mfpparking_dw_all_up.png"] forState:UIControlStateNormal];
    [_locationBtn setImage:[UIImage imageNamed:@"mfpparking_dw_all_down.png"] forState:UIControlStateHighlighted];
    [_followBtn setImage:[UIImage imageNamed:@"mfpparking_gs1_all_0.png"] forState:UIControlStateNormal];
    
    
    [_mapTypeBtn addTarget:self action:@selector(mapTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_trafficBtn addTarget:self action:@selector(trafficAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_zoomInBtn addTarget:self action:@selector(zoomInAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_zoomOutBtn addTarget:self action:@selector(zoomOutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_followBtn addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_locationBtn addTarget:self action:@selector(locationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:_mapView];
    [self addSubview:_mapTypeBtn];
    [self addSubview:_trafficBtn];
    [self addSubview:_zoomInBtn];
    [self addSubview:_zoomOutBtn];
    [self addSubview:_followBtn];
    [self addSubview:_locationBtn];
}


- (void)layoutSubviews{
    _mapView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _mapTypeBtn.frame = CGRectMake(260, 20, 40, 40);
    _trafficBtn.frame = CGRectMake(260, 80, 40, 40);
    _zoomInBtn.frame = CGRectMake(260, self.height - 100, 40, 40);
    _zoomOutBtn.frame = CGRectMake(260, self.height - 60, 40, 40);
    
    _followBtn.frame = CGRectMake(10, self.height - 110, 40, 40);
    _locationBtn.frame = CGRectMake(10, self.height - 60, 40, 40);
    
    _mapView.mapScaleBarPosition = CGPointMake(60,self.height - 40);
}

#pragma mark - Action
//BMKMapTypeStandard   = 1,               ///< 标准地图
//BMKMapTypeTrafficOn  = 2,               ///< 实时路况
//BMKMapTypeSatellite  = 4,               ///< 卫星地图
//BMKMapTypeTrafficAndSatellite  = 8,     ///< 同时打开实时路况和卫星地图

- (void)mapTypeAction:(UIButton *) button{
    //关闭卫星地图
    if(_mapView.mapType == BMKMapTypeSatellite || _mapView.mapType == BMKMapTypeTrafficAndSatellite){
        
        if (_mapView.mapType == BMKMapTypeSatellite) {
            [_mapView setMapType:BMKMapTypeStandard];
        }else{
            [_mapView setMapType:BMKMapTypeTrafficOn];
        }
        [_mapTypeBtn setImage:[UIImage imageNamed:@"mfpparking_2d_all_0.png"] forState:UIControlStateNormal];
        
    }
    //开启影像图
    else{
        
        if (_mapView.mapType == BMKMapTypeStandard) {
            [_mapView setMapType:BMKMapTypeSatellite];
        }else{
            [_mapView setMapType:BMKMapTypeTrafficAndSatellite];
        }
        
        [_mapTypeBtn setImage:[UIImage imageNamed:@"mfpparking_2wxdw_all_0.png"] forState:UIControlStateNormal];
    }
}

- (void)trafficAction:(UIButton *) button{
    //关闭实时路况
    if(_mapView.mapType == BMKMapTypeTrafficOn || _mapView.mapType == BMKMapTypeTrafficAndSatellite){
        
        if (_mapView.mapType == BMKMapTypeTrafficOn) {
            [_mapView setMapType:BMKMapTypeStandard];
        }else{
            [_mapView setMapType:BMKMapTypeSatellite];
        }
        
        [_trafficBtn setImage:[UIImage imageNamed:@"mfpparking_luk_all_up.png"] forState:UIControlStateNormal];
    }else{
        
        if (_mapView.mapType == BMKMapTypeStandard) {
            [_mapView setMapType:BMKMapTypeTrafficOn];
        }else{
            [_mapView setMapType:BMKMapTypeTrafficAndSatellite];
        }
        
        
        [_trafficBtn setImage:[UIImage imageNamed:@"mfpparking_luk_all_down.png"] forState:UIControlStateNormal];
    }
    
}

//3~19
- (void)zoomInAction:(UIButton *)button{
    if (_mapView.zoomLevel < 19) {
        _mapView.zoomLevel = _mapView.zoomLevel + 1;
    }
}

- (void)zoomOutAction:(UIButton *)button{
    if (_mapView.zoomLevel > 3) {
        _mapView.zoomLevel = _mapView.zoomLevel - 1;
    }
}

- (void)followAction:(UIButton *)button{
    if (_isFollow) {
        _isFollow = false;
        [_followBtn setImage:[UIImage imageNamed:@"mfpparking_gs1_all_0.png"] forState:UIControlStateNormal];
        
        if ([self.mapDelegate respondsToSelector:@selector(mapFollow:)]) {
            [self.mapDelegate mapFollow:NO];
        }
    }else{
        _isFollow = true;
        [_followBtn setImage:[UIImage imageNamed:@"mfpparking_gs2_all_0.png"] forState:UIControlStateNormal];
        
        if ([self.mapDelegate respondsToSelector:@selector(mapFollow:)]) {
            [self.mapDelegate mapFollow:YES];
        }
    }
}

- (void)locationAction:(UIButton *)button{
    if ([self.mapDelegate respondsToSelector:@selector(mapLocation)]) {
        [self.mapDelegate mapLocation];
    }
}




@end
