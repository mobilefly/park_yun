//
//  FLYDBUtil.h
//  park_yun
//
//  Created by chen on 14-8-5.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYDBUtil : NSObject

//停车场按区域统计
+ (NSMutableArray *)queryCityList:(NSString *)city;

//查询城市下的所有停车场
+ (NSMutableArray *)queryParkList:(NSString *)city;

//查询城市停车场,按距离排序
+ (NSMutableArray *)queryParkList:(float)lat lng:(float)lng city:(NSString *)city;

//查询当前点范围内的停车场,按距离排序
+ (NSMutableArray *)queryParkList:(float)lat lng:(float)lng city:(NSString *)city rang:(double)rang;

//查询商圈
+ (NSMutableArray *)queryBussinessList:(NSString *)city;

//查询商圈（分页）
+ (NSMutableArray *)queryBussinessList:(NSString *)city start:(int)start count:(int)count;

//查询停车场详情
+ (FLYParkModel *)queryParkDetail:(NSString *)parkid;

//检查Region表是否存在数据
+ (BOOL)checkRegionTable;

//Region.xml转数据库
+ (void)batchSaveRegion:(NSMutableArray *)regionList;

//检查Bussiness表是否存在数据
+ (BOOL)checkBussinessTable;

//Bussiness.xml转数据库
+ (void)batchSaveBussiness:(NSMutableArray *)businessList;

@end
