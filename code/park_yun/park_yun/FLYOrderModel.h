//
//  FLYOrderModel.h
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//orderCode	string	订单编号
//orderType	string	订单类型【01充值(自费)02消费(畅停卡)03消费(停车)04充值(优惠劵)】
//orderName	string	商品名称
//orderPayflag	string	支付方式（00余额01支付宝02银联03微信）
//orderFlag	string	订单状态（0正常1取消2未付款）
//orderAddtime	string	下单时间
//orderPaytime	string	付款时间
//orderPrice	int	订单金额

#import "FLYBaseModel.h"

@interface FLYOrderModel : FLYBaseModel

@property(nonatomic,copy) NSString *orderCode;
@property(nonatomic,copy) NSString *orderType;
@property(nonatomic,copy) NSString *orderName;
@property(nonatomic,copy) NSString *orderPayflag;
@property(nonatomic,copy) NSString *orderFlag;
@property(nonatomic,copy) NSString *orderAddtime;
@property(nonatomic,copy) NSString *orderPaytime;
@property(nonatomic,strong) NSNumber *orderPrice;


@end
