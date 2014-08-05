//
//  FLYOfflineParkModel.h
//  park_yun
//
//  Created by chen on 14-8-1.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//regionCode	string	区域编码
//regionName	string	区域名称
//parkCount	string	停车场个数
//maxVersion	string	最大版本号

#import "FLYBaseModel.h"

@interface FLYOfflineParkModel : FLYBaseModel

@property(nonatomic,copy) NSString *regionId;
@property(nonatomic,copy) NSString *regionCode;
@property(nonatomic,copy) NSString *regionName;
@property(nonatomic,strong) NSNumber *parkCount;
@property(nonatomic,strong) NSNumber *maxVersion;

@property(nonatomic,strong) NSNumber *updateVersion;

//0:正常 1.下载中
@property(nonatomic) int status;
//YES:可更新 NO:不可更新
@property(nonatomic) BOOL update;
//下载比例
@property(nonatomic) int ratio;

@end
