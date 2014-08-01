//
//  FLYMemberTraceModel.h
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseModel.h"
#import "FLYOrderModel.h"

//mtId	string	流水UID
//mtCrid	string	订单UID
//mtPrice	int	金额
//mtBalance	int	余额
//mtCode	string	流水编号
//mtMemberid	string	用户UID
//mtPaydate	string	交易时间

@interface FLYMemberTraceModel : FLYBaseModel


@property(nonatomic,copy) NSString *mtId;
@property(nonatomic,strong) NSNumber *mtPrice;
@property(nonatomic,strong) NSNumber *mtBalance;
@property(nonatomic,copy) NSString *mtCode;
@property(nonatomic,copy) NSString *mtMemberid;
@property(nonatomic,copy) NSString *mtPaydate;

@property(nonatomic,strong) FLYOrderModel *order;


@end
