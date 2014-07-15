//
//  FLYParkCardModel.h
//  park_yun
//
//  Created by chen on 14-7-14.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//cpFlag	string	卡状态(0正常1过期)
//cpCardid	string	会员卡ID
//cpExpdate	string	到期日期


#import "FLYBaseModel.h"
#import "FLYParkModel.h"
#import "FLYMemberCard.h"

@interface FLYCardParkModel : FLYBaseModel

@property(nonatomic,copy) NSString *cpFlag;
@property(nonatomic,copy) NSString *cpCardid;
@property(nonatomic,copy) NSString *cpExpdate;
@property(nonatomic,strong) FLYParkModel *park;
@property(nonatomic,strong) FLYMemberCard *memberCarno;

@end
