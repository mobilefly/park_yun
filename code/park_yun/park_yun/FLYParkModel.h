//
//  FLYParkModel.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseModel.h"
#import "FLYPhotoModel.h"

//parkId	string	停车场UID
//parkCode	string	停车场代码
//parkName	string	停车场名称
//parkStatus	string	数据是否接入（0是 1不是 未签约用户未接入）
//parkRegionid	string	归属区域UID
//parkCapacity	int	停车场容量（车位数量）
//parkLng	string	经度
//parkLat	string	维度
//parkFeedesc	string	收费标准描述
//parkFeelevel	string	收费评分（0便宜1适中2偏贵）
//parkScore	string	停车评分（0 - 5）
//parkFreetime	int	免费时长
//parkAgentid	string	运营商UID
//parkLogon	string	停车场状态（0为下班，1为上班）
//parkType	string	停车场类型（1路内2路外）
//parkSubtype	string	停车场子类型（路内：1收费2党政机关3单位个人4免费 5分时免费
//路外：1商圈2景区3宾馆4酒店5政府）
//parkFlag	string	删除标记（0正常1已删除）
//parkAddress	string	详细地址
//parkRemark	string	停车场描述
//seatIdle	int	空闲车位

@interface FLYParkModel : FLYBaseModel


@property(nonatomic,copy) NSString *parkId;
@property(nonatomic,copy) NSString *parkCode;
@property(nonatomic,copy) NSString *parkName;
@property(nonatomic,copy) NSString *parkStatus;
@property(nonatomic,copy) NSString *parkRegionid;
@property(nonatomic,strong) NSNumber *parkCapacity;
@property(nonatomic,copy) NSString *parkLng;
@property(nonatomic,copy) NSString *parkLat;
@property(nonatomic,copy) NSString *parkFeedesc;
@property(nonatomic,copy) NSString *parkFeelevel;
@property(nonatomic,copy) NSString *parkScore;
@property(nonatomic,strong) NSNumber *parkFreetime;
@property(nonatomic,copy) NSString *parkAgentid;
@property(nonatomic,copy) NSString *parkLogon;
@property(nonatomic,copy) NSString *parkType;
@property(nonatomic,copy) NSString *parkSubtype;
@property(nonatomic,copy) NSString *parkAddress;
@property(nonatomic,copy) NSString *parkRemark;
@property(nonatomic,strong) NSNumber *seatIdle;
@property(nonatomic,strong) FLYPhotoModel *photo;

@end
