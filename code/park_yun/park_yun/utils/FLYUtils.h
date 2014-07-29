//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@end
