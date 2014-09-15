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

//mtType	string	交易类型(11预付卡消费,12 畅停卡消费)
//mtPark	string	停车场代码
//mtParkname	string	停车场名称
//mtParkbegin	string	进场时间
//mtParkend	string	离场时间
//mtParktime	int	停车时长(单位为分钟)

@interface FLYMemberTraceModel : FLYBaseModel


@property(nonatomic,copy) NSString *mtId;
@property(nonatomic,strong) NSNumber *mtPrice;
@property(nonatomic,strong) NSNumber *mtBalance;
@property(nonatomic,copy) NSString *mtCode;
@property(nonatomic,copy) NSString *mtMemberid;
@property(nonatomic,copy) NSString *mtPaydate;
@property(nonatomic,copy) NSString *mtType;
@property(nonatomic,copy) NSString *mtPark;
@property(nonatomic,copy) NSString *mtParkname;
@property(nonatomic,copy) NSString *mtParkbegin;
@property(nonatomic,copy) NSString *mtParkend;
@property(nonatomic,copy) NSString *mtParktime;


@property(nonatomic,strong) FLYOrderModel *order;


@end
