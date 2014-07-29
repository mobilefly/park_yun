//
//  FLYGoodsOrderModel.h
//  park_yun
//
//  Created by chen on 14-7-24.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//



//goId	String	商品订单ID
//goName	string	商品名称
//goOrderid	string	订单名称
//goType	string	订单类型（订单类型【01充值(自费)02消费(畅停卡)03消费(停车)04充值(优惠劵)】）
//goTotalprice	int	总金额
//goPrice	int	实际付款金额
//goOffprice	int	折扣金额
//goObjectid	String	外键关联ID
//goAgentid	String	运营商ID
//goParkid	String	停车场ID


#import "FLYBaseModel.h"

@interface FLYGoodsOrderModel : FLYBaseModel

@property(nonatomic,copy) NSString *goId;
@property(nonatomic,copy) NSString *goName;
@property(nonatomic,copy) NSString *goOrderid;
@property(nonatomic,copy) NSString *goType;
@property(nonatomic,strong) NSNumber *goTotalprice;
@property(nonatomic,strong) NSNumber *goPrice;
@property(nonatomic,strong) NSNumber *goOffprice;
@property(nonatomic,copy) NSString *goObjectid;
@property(nonatomic,copy) NSString *goAgentid;
@property(nonatomic,copy) NSString *goParkid;

@end
