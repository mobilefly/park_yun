//
//  FLYCollectModel.h
//  park_yun
//
//  Created by chen on 14-7-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//collectId	string	收藏UID
//collectUserid	string	用户UID
//collectAddtime	string	开始时间（yyyyMMddHHmmss）

#import "FLYBaseModel.h"
#import "FLYParkModel.h"

@interface FLYCollectModel : FLYBaseModel

@property(nonatomic,copy) NSString *collectId;
@property(nonatomic,copy) NSString *collectUserid;
@property(nonatomic,copy) NSString *collectAddtime;
@property(nonatomic,copy) NSString *photoUrl;

@property(nonatomic,strong) FLYParkModel *park;

@end
