//
//  FLYParkCardModel.h
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//pcId	string	收费标准ID
//parkId	string	停车场ID
//pcPrice	int	金额(以分为单位)
//pcMonth	int	购买月份
//pcMonthadd	int	赠送月份数

#import "FLYBaseModel.h"

@interface FLYParkCardModel : FLYBaseModel

@property(nonatomic,copy) NSString *pcId;
@property(nonatomic,copy) NSString *parkId;
@property(nonatomic,strong) NSNumber *pcPrice;
@property(nonatomic,strong) NSNumber *pcMonth;
@property(nonatomic,strong) NSNumber *pcMonthadd;

@end
