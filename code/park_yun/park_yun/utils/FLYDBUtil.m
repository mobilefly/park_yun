//
//  FLYDBUtil.m
//  park_yun
//
//  Created by chen on 14-8-5.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYDBUtil.h"
#import "FLYParkModel.h"
#import "FLYRegionModel.h"
#import "FLYBussinessModel.h"
#import "FLYRegionParkModel.h"
#import "FMDB.h"
#import "BMapKit.h"

@implementation FLYDBUtil

//查询区域省份
+(NSMutableArray *)queryRegionOfProvice{
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:20];
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return list;
    }
    
    FMResultSet *resultSet = nil;
    resultSet = [db executeQuery:@"select t.* from REGION t where t.REGION_PARENTID = '' and length(t.REGION_CODE) = 2 order by t.REGION_SORT ASC,t.REGION_CODE ASC"];
    
    while ([resultSet next]){
        NSString *region_id = [resultSet stringForColumn:@"REGION_ID"];
        NSString *region_name = [resultSet stringForColumn:@"REGION_NAME"];
        NSString *region_parentid = [resultSet stringForColumn:@"REGION_PARENTID"];
        
        FLYRegionModel *model = [[FLYRegionModel alloc] init];
        model.regionId = region_id;
        model.regionName = region_name;
        model.regionParentid = region_parentid;
        [list addObject:model];
    }
    [db close];
    return list;
    
}

//查询区域城市
+(NSMutableArray *)queryRegionOfCity:(NSString *)provice{
    
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:20];
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return list;
    }
    
    FMResultSet *resultSet = nil;
    resultSet = [db executeQuery:@"select t.* from REGION t where t.REGION_PARENTID = ? order by t.REGION_SORT ASC,t.REGION_CODE ASC",provice];
    
    while ([resultSet next]){
        NSString *region_id = [resultSet stringForColumn:@"REGION_ID"];
        NSString *region_name = [resultSet stringForColumn:@"REGION_NAME"];
        NSString *region_parentid = [resultSet stringForColumn:@"REGION_PARENTID"];
        
        FLYRegionModel *model = [[FLYRegionModel alloc] init];
        model.regionId = region_id;
        model.regionName = region_name;
        model.regionParentid = region_parentid;
        [list addObject:model];
    }
    [db close];
    return list;
    
}

//查询区域区
+(NSMutableArray *)queryRegionOfArea:(NSString *)city{
    return [self queryRegionOfCity:city];
}

+ (NSMutableArray *)queryCityList:(NSString *)city{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:20];
    
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return list;
    }
    if ([FLYBaseUtil isEmpty:city]) {
        city = @"武汉市";
    }
    city = [NSString stringWithFormat:@"%@%@%@",@"%",city,@"%"];
    
    //拼装查询sql
    NSString *sql = @"select count(p.PARK_ID) as COUNT,sum(p.PARK_CAPACITY) as CAPACITY,r.REGION_NAME,r.REGION_LNG,r.REGION_LAT ";
    sql = [sql stringByAppendingString:@"from REGION r,PARK p "];
    sql = [sql stringByAppendingString:@"where r.REGION_ID = p.PARK_REGIONID "];
    sql = [sql stringByAppendingString:@"and r.REGION_PARENTID in (select i.REGION_ID from REGION i where i.REGION_NAME like ? ) "];
    sql = [sql stringByAppendingString:@"group by r.REGION_NAME,r.REGION_LNG,r.REGION_LAT"];
    
    FMResultSet *resultSet = [db executeQuery:sql,city];
    if ([resultSet next]){
        FLYRegionParkModel *model = [[FLYRegionParkModel alloc] init];
        int count = [resultSet intForColumn:@"COUNT"];
        int capacity = [resultSet intForColumn:@"CAPACITY"];
        NSString *regionName = [resultSet stringForColumn:@"REGION_NAME"];
        NSString *regionLng = [resultSet stringForColumn:@"REGION_LNG"];
        NSString *regionLat = [resultSet stringForColumn:@"REGION_LAT"];
        
        model.count = [NSNumber numberWithInt:count];
        model.capacity = [NSNumber numberWithInt:capacity];
        model.regionName = regionName;
        model.regionLng = regionLng;
        model.regionLat = regionLat;

        [list addObject:model];

    }
    [db close];
    return list;
}

+ (NSMutableArray *)queryParkList:(NSString *)city{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:20];
    
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return list;
    }
    
    if ([FLYBaseUtil isEmpty:city]) {
        city = @"武汉市";
    }
    FMResultSet *resultSet = nil;
    city = [NSString stringWithFormat:@"%@%@%@",@"%",city,@"%"];
    resultSet = [db executeQuery:@"select t.* from REGION t where t.REGION_NAME like ?",city];
    if ([resultSet next]){
        NSString *region_code = [resultSet stringForColumn:@"REGION_CODE"];
        region_code = [NSString stringWithFormat:@"%@%@",region_code,@"%"];
        resultSet = [db executeQuery:@"select t.* from PARK t,REGION r where t.PARK_REGIONID = r.REGION_ID and r.REGION_CODE like ?",region_code];
        while ([resultSet next]) {
            FLYParkModel *model = [[FLYParkModel alloc] init];
            NSString *parkId = [resultSet stringForColumn:@"PARK_ID"];
            NSString *parkCode = [resultSet stringForColumn:@"PARK_CODE"];
            NSString *parkName = [resultSet stringForColumn:@"PARK_NAME"];
            NSString *parkRegionid = [resultSet stringForColumn:@"PARK_REGIONID"];
            int parkCapacity = [resultSet intForColumn:@"PARK_CAPACITY"];
            NSString *parkCapdesc = [resultSet stringForColumn:@"PARK_CAPDESC"];
            NSString *parkLat = [resultSet stringForColumn:@"PARK_LAT"];
            NSString *parkLng = [resultSet stringForColumn:@"PARK_LNG"];
            NSString *parkFeedesc = [resultSet stringForColumn:@"PARK_FEEDESC"];
            NSString *parkFeelevel = [resultSet stringForColumn:@"PARK_FEELEVEL"];
            int parkFreetime = [resultSet intForColumn:@"PARK_FREETIME"];
            NSString *parkType = [resultSet stringForColumn:@"PARK_TYPE"];
            NSString *parkStatus = [resultSet stringForColumn:@"PARK_STATUS"];
            NSString *parkAddress = [resultSet stringForColumn:@"PARK_ADDRESS"];
            NSString *parkRemark = [resultSet stringForColumn:@"PARK_REMARK"];
            NSString *parkScore = [resultSet stringForColumn:@"PARK_SCORE"];
            
            model.seatIdle = [NSNumber numberWithInt:-1];
            model.parkId = parkId;
            model.parkCode = parkCode;
            model.parkName = parkName;
            model.parkRegionid = parkRegionid;
            model.parkCapacity = [NSNumber numberWithInt:parkCapacity];
            model.parkCapdesc = parkCapdesc;
            model.parkLat = parkLat;
            model.parkLng = parkLng;
            model.parkFeedesc = parkFeedesc;
            model.parkFeelevel = parkFeelevel;
            model.parkFreetime = [NSNumber numberWithInt:parkFreetime];
            model.parkType = parkType;
            model.parkStatus = parkStatus;
            model.parkAddress = parkAddress;
            model.parkRemark = parkRemark;
            model.parkScore = parkScore;
            [list addObject:model];
        }
    }
    [db close];
    
    return list;
}

+ (NSMutableArray *)queryParkList:(float)lat lng:(float)lng city:(NSString *)city{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:20];
    
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return list;
    }
    
    if ([FLYBaseUtil isEmpty:city]) {
        city = @"武汉市";
    }
    FMResultSet *resultSet = nil;
    city = [NSString stringWithFormat:@"%@%@%@",@"%",city,@"%"];
    resultSet = [db executeQuery:@"select t.* from REGION t where t.REGION_NAME like ?",city];
    if ([resultSet next]){
        NSString *region_code = [resultSet stringForColumn:@"REGION_CODE"];
        region_code = [NSString stringWithFormat:@"%@%@",region_code,@"%"];
        resultSet = [db executeQuery:@"select t.* from PARK t,REGION r where t.PARK_REGIONID = r.REGION_ID and r.REGION_CODE like ?",region_code];
        while ([resultSet next]) {
            FLYParkModel *model = [[FLYParkModel alloc] init];
            NSString *parkId = [resultSet stringForColumn:@"PARK_ID"];
            NSString *parkCode = [resultSet stringForColumn:@"PARK_CODE"];
            NSString *parkName = [resultSet stringForColumn:@"PARK_NAME"];
            NSString *parkRegionid = [resultSet stringForColumn:@"PARK_REGIONID"];
            int parkCapacity = [resultSet intForColumn:@"PARK_CAPACITY"];
            NSString *parkCapdesc = [resultSet stringForColumn:@"PARK_CAPDESC"];
            NSString *parkLat = [resultSet stringForColumn:@"PARK_LAT"];
            NSString *parkLng = [resultSet stringForColumn:@"PARK_LNG"];
            NSString *parkFeedesc = [resultSet stringForColumn:@"PARK_FEEDESC"];
            NSString *parkFeelevel = [resultSet stringForColumn:@"PARK_FEELEVEL"];
            int parkFreetime = [resultSet intForColumn:@"PARK_FREETIME"];
            NSString *parkType = [resultSet stringForColumn:@"PARK_TYPE"];
            NSString *parkStatus = [resultSet stringForColumn:@"PARK_STATUS"];
            NSString *parkAddress = [resultSet stringForColumn:@"PARK_ADDRESS"];
            NSString *parkRemark = [resultSet stringForColumn:@"PARK_REMARK"];
            NSString *parkScore = [resultSet stringForColumn:@"PARK_SCORE"];
            
            model.seatIdle = [NSNumber numberWithInt:-1];
            model.parkId = parkId;
            model.parkCode = parkCode;
            model.parkName = parkName;
            model.parkRegionid = parkRegionid;
            model.parkCapacity = [NSNumber numberWithInt:parkCapacity];
            model.parkCapdesc = parkCapdesc;
            model.parkLat = parkLat;
            model.parkLng = parkLng;
            model.parkFeedesc = parkFeedesc;
            model.parkFeelevel = parkFeelevel;
            model.parkFreetime = [NSNumber numberWithInt:parkFreetime];
            model.parkType = parkType;
            model.parkStatus = parkStatus;
            model.parkAddress = parkAddress;
            model.parkRemark = parkRemark;
            model.parkScore = parkScore;
            [list addObject:model];
        }
    }
    [db close];
    
    NSArray *resultList = [list sortedArrayUsingComparator:^(id obj1,id obj2){
         FLYParkModel *model1 = (FLYParkModel *)obj1;
         FLYParkModel *model2 = (FLYParkModel *)obj2;

        
         BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([model1.parkLat doubleValue],[model1.parkLng doubleValue]));
         BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([model2.parkLat doubleValue],[model2.parkLng doubleValue]));
        
         BMKMapPoint location = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lat, lng));
         CLLocationDistance distance1 = BMKMetersBetweenMapPoints(point1,location);
         CLLocationDistance distance2 = BMKMetersBetweenMapPoints(point2,location);
        
        
         if (distance1 < distance2){
             return (NSComparisonResult)NSOrderedAscending;
         }
         else{
             return (NSComparisonResult)NSOrderedDescending;
         }
         return (NSComparisonResult)NSOrderedSame;
    }];
    list = [resultList mutableCopy];

    return list;
}


+ (NSMutableArray *)queryParkList:(float)lat lng:(float)lng city:(NSString *)city rang:(double)rang{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:20];
    
    NSMutableArray *list = [self queryParkList:lat lng:lng city:city];
    for (FLYParkModel *model in list) {
        BMKMapPoint point = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([model.parkLat doubleValue],[model.parkLng doubleValue]));
        BMKMapPoint location = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lat, lng));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point,location);
        if (distance <= rang) {
            [result addObject:model];
        }
    }
    
    
    return result;
}

+ (NSMutableArray *)queryBussinessList:(NSString *)city start:(int)start count:(int)count{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:20];
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return list;
    }
    
    if ([FLYBaseUtil isEmpty:city]) {
        city = @"武汉市";
    }
    FMResultSet *resultSet = nil;
    city = [NSString stringWithFormat:@"%@%@%@",@"%",city,@"%"];
    resultSet = [db executeQuery:@"select t.* from REGION t where t.REGION_NAME like ?",city];
    if ([resultSet next]){
        NSString *region_code = [resultSet stringForColumn:@"REGION_CODE"];
        region_code = [NSString stringWithFormat:@"%@%@",region_code,@"%"];
        
        NSString *sql = @"select t.* from BUSSINESS t,REGION r where t.BUSSINESS_REGIONID = r.REGION_ID and r.REGION_CODE like ? order by t.BUSSINESS_REGIONID ASC,t.BUSSINESS_SORT ASC";
        
//        NSString *sql = @"select t.* from BUSSINESS t order by t.BUSSINESS_REGIONID ASC,t.BUSSINESS_SORT ASC";
        
        if (count > 0) {
            sql = [sql stringByAppendingFormat:@" limit %i,%i",start,count];
        }
        resultSet = [db executeQuery:sql,region_code];
        
        while ([resultSet next]) {
            FLYBussinessModel *model = [[FLYBussinessModel alloc] init];
            NSString *bussinessId = [resultSet stringForColumn:@"BUSSINESS_ID"];
            NSString *bussinessRegionid = [resultSet stringForColumn:@"BUSSINESS_REGIONID"];
            NSString *bussinessName = [resultSet stringForColumn:@"BUSSINESS_NAME"];
            NSString *bussinessLng = [resultSet stringForColumn:@"BUSSINESS_LNG"];
            NSString *bussinessLat = [resultSet stringForColumn:@"BUSSINESS_LAT"];
            NSString *bussinessDesc = [resultSet stringForColumn:@"BUSSINESS_DESC"];
            NSString *bussinessSort = [resultSet stringForColumn:@"BUSSINESS_SORT"];
            
            model.bussinessId = bussinessId;
            model.bussinessRegionid = bussinessRegionid;
            model.bussinessName = bussinessName;
            model.bussinessLng = bussinessLng;
            model.bussinessLat = bussinessLat;
            model.bussinessDesc = bussinessDesc;
            model.bussinessSort = bussinessSort;
            [list addObject:model];
        }
    }
    [db close];
    
    return list;
}

+ (NSMutableArray *)queryBussinessList:(NSString *)city{
    return [FLYDBUtil queryBussinessList:city start:0 count:-1];
}

+ (FLYParkModel *)queryParkDetail:(NSString *)parkid{
    FLYParkModel *model = nil;
    
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return model;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select t.* from PARK t where t.PARK_ID = ?",parkid];
    if ([resultSet next]) {
        model = [[FLYParkModel alloc] init];
        NSString *parkId = [resultSet stringForColumn:@"PARK_ID"];
        NSString *parkCode = [resultSet stringForColumn:@"PARK_CODE"];
        NSString *parkName = [resultSet stringForColumn:@"PARK_NAME"];
        NSString *parkRegionid = [resultSet stringForColumn:@"PARK_REGIONID"];
        int parkCapacity = [resultSet intForColumn:@"PARK_CAPACITY"];
        NSString *parkCapdesc = [resultSet stringForColumn:@"PARK_CAPDESC"];
        NSString *parkLat = [resultSet stringForColumn:@"PARK_LAT"];
        NSString *parkLng = [resultSet stringForColumn:@"PARK_LNG"];
        NSString *parkFeedesc = [resultSet stringForColumn:@"PARK_FEEDESC"];
        NSString *parkFeelevel = [resultSet stringForColumn:@"PARK_FEELEVEL"];
        int parkFreetime = [resultSet intForColumn:@"PARK_FREETIME"];
        NSString *parkType = [resultSet stringForColumn:@"PARK_TYPE"];
        NSString *parkStatus = [resultSet stringForColumn:@"PARK_STATUS"];
        NSString *parkAddress = [resultSet stringForColumn:@"PARK_ADDRESS"];
        NSString *parkRemark = [resultSet stringForColumn:@"PARK_REMARK"];
        NSString *parkScore = [resultSet stringForColumn:@"PARK_SCORE"];
        
        model.seatIdle = [NSNumber numberWithInt:-1];
        model.parkId = parkId;
        model.parkCode = parkCode;
        model.parkName = parkName;
        model.parkRegionid = parkRegionid;
        model.parkCapacity = [NSNumber numberWithInt:parkCapacity];
        model.parkCapdesc = parkCapdesc;
        model.parkLat = parkLat;
        model.parkLng = parkLng;
        model.parkFeedesc = parkFeedesc;
        model.parkFeelevel = parkFeelevel;
        model.parkFreetime = [NSNumber numberWithInt:parkFreetime];
        model.parkType = parkType;
        model.parkStatus = parkStatus;
        model.parkAddress = parkAddress;
        model.parkRemark = parkRemark;
        model.parkScore = parkScore;
    }
    
    [db close];
    return model;
}


//检查区域表是否有数据
+ (BOOL)checkRegionTable{
    BOOL flag = NO;
    
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return flag;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select count(*) as COUNT from REGION"];
    if ([resultSet next]) {
        int count = [resultSet intForColumn:@"COUNT"];
        if (count > 0) {
            flag = YES;
        }
    }
    [db close];
    return flag;
}

//批量保存区域数据
+ (void)batchSaveRegion:(NSMutableArray *)regionList{
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    [db executeUpdate:@"create table if not exists REGION (REGION_ID TEXT PRIMARY KEY,REGION_CODE TEXT,REGION_PARENTID TEXT,REGION_NAME TEXT,REGION_SORT INTEGER,REGION_LNG TEXT,REGION_LAT TEXT)"];
    
    //开启事务
    [db beginTransaction];
    @try {
        [db executeUpdate:@"delete from REGION"];
        
        for (FLYRegionModel *regionModel in regionList) {
            BOOL insert = [db executeUpdate:@"insert or replace into REGION values (?,?,?,?,?,?,?)",
                           regionModel.regionId,
                           regionModel.regionCode,
                           regionModel.regionParentid,
                           regionModel.regionName,
                           regionModel.regionSort,
                           regionModel.regionLng,
                           regionModel.regionLat];
            
            if (!insert) {
                //NSLog(@"REGION:保存失败");
            }else{
                //NSLog(@"REGION:保存成功");
            }
        }
    }@catch (NSException *exception) {
        [db rollback];
    }@finally {
         NSLog(@"REGION:保存成功");
        [db commit];
    }
    [db close];
}

//检查商圈表是否有数据
+ (BOOL)checkBussinessTable{
    BOOL flag = NO;
    
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return flag;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select count(*) as COUNT from BUSSINESS"];
    if ([resultSet next]) {
        int count = [resultSet intForColumn:@"COUNT"];
        if (count > 0) {
            flag = YES;
        }
    }
    [db close];
    return flag;
}

//批量保存商圈数据
+ (void)batchSaveBussiness:(NSMutableArray *)businessList{
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    [db executeUpdate:@"create table if not exists BUSSINESS (BUSSINESS_ID TEXT PRIMARY KEY,BUSSINESS_REGIONID TEXT,BUSSINESS_NAME TEXT,BUSSINESS_LNG TEXT,BUSSINESS_LAT TEXT,BUSSINESS_DESC TEXT,BUSSINESS_SORT INTEGER)"];
    
    //开启事务
    [db beginTransaction];
    @try {
        [db executeUpdate:@"delete from BUSSINESS"];
        
        for (FLYBussinessModel *bussinessModel in businessList) {
            BOOL insert = [db executeUpdate:@"insert or replace into BUSSINESS values (?,?,?,?,?,?,?)",
                           bussinessModel.bussinessId,
                           bussinessModel.bussinessRegionid,
                           bussinessModel.bussinessName,
                           bussinessModel.bussinessLng,
                           bussinessModel.bussinessLat,
                           bussinessModel.bussinessDesc,
                           bussinessModel.bussinessSort];
            
            if (!insert) {
                //NSLog(@"BUSSINESS:保存失败");
            }else{
                //NSLog(@"BUSSINESS:保存成功");
            }
        }
    }@catch (NSException *exception) {
        [db rollback];
    }@finally {
        NSLog(@"BUSSINESS:保存成功");
        [db commit];
    }
    [db close];
}

@end
