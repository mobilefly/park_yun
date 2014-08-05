//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FLYParkModel.h"

@interface FLYUtils : NSObject
//获取documents下的文件路径
+ (NSString *)getDocumentsPath:(NSString *)fileName;
// date 格式化为 string
+ (NSString*) stringFromFomate:(NSDate *)date formate:(NSString *)formate;
// string 格式化为 date
+ (NSDate *) dateFromFomate:(NSString *)datestring formate:(NSString *)formate;

+ (NSString *)fomateString:(NSString *)datestring;

+ (NSString *)fomateString:(NSString *)datestring formate:(NSString *)formate;

+ (NSString *)betweenDate:(NSDate *)beginDate endDate:(NSDate *)endDate;

+ (NSString *)getDataSizeString:(int) nSize;

+ (NSString *)getSmallImage:(NSString *)url width:(NSString *)width height:(NSString *)height;

//行车导航
+ (void)drivingNavigation:(NSString *)name start:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D) end;

//停车场语音
+ (NSString *)getParkSpeech:(FLYParkModel *)parkModel;

@end
