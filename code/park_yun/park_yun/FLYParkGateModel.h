//
//  FLYParkGateModel.h
//  park_yun
//
//  Created by chen on 14-7-22.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//gateType	String	出入口类型
//gateDesc	string	出入口描述
//gateDescVoice	string	语音描述

#import "FLYBaseModel.h"
#import "FLYPhotoModel.h"

@interface FLYParkGateModel : FLYBaseModel

@property(nonatomic,copy) NSString *gateDesc;
@property(nonatomic,copy) NSString *gateDescVoice;
@property(nonatomic,copy) NSString *gateType;
@property(nonatomic,strong) FLYPhotoModel *photo;

@end
