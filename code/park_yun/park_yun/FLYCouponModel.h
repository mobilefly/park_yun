//
//  FLYCouponModel.h
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//


//cdId	string	id
//cdCaid	string	活动ID
//cdPhone	string	会员手机号（账号）
//cdNo	string	优惠券编号
//cdBegindate	string	开始日期
//cdEnddate	String	截止日期
//cdAmount	int	红包金额(单位为分)
//cdFlag	String	使用状态(0未使用1已使用)
//EFlag	String	使用状态(0未过期1已过期)
//flag	string	成功标示（0成功1失败）

#import "FLYBaseModel.h"

@interface FLYCouponModel : FLYBaseModel

@property(nonatomic,copy) NSString *cdId;
@property(nonatomic,copy) NSString *cdCaid;
@property(nonatomic,copy) NSString *cdPhone;
@property(nonatomic,copy) NSString *cdNo;
@property(nonatomic,copy) NSString *cdBegindate;
@property(nonatomic,copy) NSString *cdEnddate;
@property(nonatomic,strong) NSNumber *cdAmount;
@property(nonatomic,copy) NSString *cdFlag;
@property(nonatomic,copy) NSString *EFlag;

@end
