//
//  FLYRegionModel.h
//  park_yun
//
//  Created by chen on 14-8-6.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYRegionModel : NSObject

@property (nonatomic,copy) NSString *regionId;
@property (nonatomic,copy) NSString *regionCode;
@property (nonatomic,copy) NSString *regionParentid;
@property (nonatomic,copy) NSString *regionName;

@property (nonatomic,copy) NSString *regionSort;
@property (nonatomic,copy) NSString *regionLng;
@property (nonatomic,copy) NSString *regionLat;

@end
