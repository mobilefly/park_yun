//
//  FLYRegionParkModel.h
//  park_yun
//
//  Created by chen on 14-8-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//regionName	string	区域名
//count	int	停车场个数
//capacity	int	总停车场总车位数
//regionLat	string	维度
//regionLng	string	经度

#import "FLYBaseModel.h"

@interface FLYRegionParkModel : FLYBaseModel

@property(nonatomic,copy) NSString *regionName;
@property(nonatomic,strong) NSNumber *count;
@property(nonatomic,strong) NSNumber *capacity;
@property(nonatomic,copy) NSString *regionLat;
@property(nonatomic,copy) NSString *regionLng;


@end
