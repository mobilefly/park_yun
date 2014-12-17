//
//  FLYShopModel.h
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLYParkCardModel.h"

@interface FLYShopModel : NSObject

@property(nonatomic,strong) FLYParkCardModel *parkCard;
@property(nonatomic,copy) NSString *parkId;
@property(nonatomic,copy) NSString *parkValue;
@property(nonatomic) int buyNum;

@end
