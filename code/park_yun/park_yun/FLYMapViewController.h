//
//  FLYMapViewController.h
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseMapViewController.h"

@interface FLYMapViewController : FLYBaseMapViewController<BMKMapViewDelegate>{

    //第一次进入系统，加载定位图标
    BOOL _isFirstLoad;
}
//屏幕首次位置
@property (nonatomic,strong)NSNumber *lat;
@property (nonatomic,strong)NSNumber *lon;

//传入标记类型
@property (copy, nonatomic)NSString *type;
//传入标记数据
@property (strong, nonatomic)id dataModel;

@end
