//
//  FLYMemberCard.h
//  park_yun
//
//  Created by chen on 14-7-14.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//


//mcId	string	UID
//cardId
//mcRegdate	string	注册日期
//mcMemberid string	会员编号
//mcFlag	string	当前可用（默认为0，当前可用时为1）
//cardCode	string	卡号
//mcCarno	string	车牌号


#import "FLYBaseModel.h"

@interface FLYMemberCard : FLYBaseModel

@property(nonatomic,copy) NSString *mcId;
@property(nonatomic,copy) NSString *cardId;
@property(nonatomic,copy) NSString *mcRegdate;
@property(nonatomic,copy) NSString *mcMemberid;
@property(nonatomic,copy) NSString *mcFlag;
@property(nonatomic,copy) NSString *cardCode;
@property(nonatomic,copy) NSString *mcCarno;

@end
