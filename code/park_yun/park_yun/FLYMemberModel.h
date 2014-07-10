//
//  FLYMemberModel.h
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//memberId	string	会员UID
//memberRegionid	string	会员区域ID
//memberName	string	姓名
//memberPhone	string	手机号
//memberCarno	string	默认绑定车牌号
//memberNick	string	昵称
//memberGender	string	性别（1女0男）
//memberLevel	string	会员等级
//memberScore	int	会员积分
//memberType	string	会员类型（1普通用户2认证用户3畅停卡用户）
//memberBalance	int	余额
//memberEmail	string	Email地址
//memberPid	string	身份证号
//memberLastlogin	string	最后一次登陆时间（格式：yyyyMMddHHmmss）
//memberAddtime	string	添加时间（格式：yyyyMMddHHmmss）
//memberFlag	string	会员状态（0正常1注销）


#import "FLYBaseModel.h"

@interface FLYMemberModel : FLYBaseModel

@property(nonatomic,copy) NSString *memberId;
@property(nonatomic,copy) NSString *memberRegionid;
@property(nonatomic,copy) NSString *memberName;
@property(nonatomic,copy) NSString *memberPhone;
@property(nonatomic,copy) NSString *memberCarno;
@property(nonatomic,copy) NSString *memberNick;
@property(nonatomic,copy) NSString *memberGender;
@property(nonatomic,copy) NSString *memberLevel;
@property(nonatomic,copy) NSString *memberScore;
@property(nonatomic,copy) NSString *memberType;
@property(nonatomic,copy) NSString *memberBalance;
@property(nonatomic,copy) NSString *memberEmail;
@property(nonatomic,copy) NSString *memberPid;
@property(nonatomic,copy) NSString *memberLastlogin;
@property(nonatomic,copy) NSString *memberAddtime;
@property(nonatomic,copy) NSString *memberFlag;

@end
