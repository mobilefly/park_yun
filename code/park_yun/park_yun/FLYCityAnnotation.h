//
//  FLYCityAnnotation.h
//  park_yun
//
//  Created by chen on 14-8-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "BMKPointAnnotation.h"
#import "FLYRegionParkModel.h"

@interface FLYCityAnnotation : BMKPointAnnotation

@property (nonatomic,strong) FLYRegionParkModel *regionModel;

@end
