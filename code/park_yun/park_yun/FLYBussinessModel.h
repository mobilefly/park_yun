//
//  FLYBussinessModel.h
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//bussinessId	string	商圈UID
//bussinessRegionid	string	区域ID
//bussinessName	string	商圈名城
//bussinessLng	string	经度
//bussinessLat	string	纬度
#import "FLYBaseModel.h"

@interface FLYBussinessModel : FLYBaseModel

@property(nonatomic,copy) NSString *bussinessId;
@property(nonatomic,copy) NSString *bussinessRegionid;
@property(nonatomic,copy) NSString *bussinessName;
@property(nonatomic,copy) NSString *bussinessLng;
@property(nonatomic,copy) NSString *bussinessLat;
@property(nonatomic,copy) NSString *bussinessDesc;
@property(nonatomic,copy) NSString *bussinessSort;

@end
