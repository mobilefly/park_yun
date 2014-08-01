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

@property(nonatomic,copy) NSString *regionCode;
@property(nonatomic,copy) NSString *regionName;
@property(nonatomic,copy) NSString *parkCount;
@property(nonatomic,copy) NSString *maxVersion;


@end
