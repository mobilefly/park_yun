//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import "FLYUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import "RegexKitLite.h"
#import "NSString+URLEncoding.h"

@implementation FLYUtils

+ (NSString *)getDocumentsPath:(NSString *)fileName {
    
    //两种获取document路径的方式
	//    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documents = [paths objectAtIndex:0];
    NSString *path = [documents stringByAppendingPathComponent:fileName];
    
    return path;
}

+ (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:formate];
	NSString *str = [formatter stringFromDate:date];
	return str;
}

+ (NSDate *) dateFromFomate:(NSString *)datestring formate:(NSString*)formate {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formate];
    NSDate *date = [formatter dateFromString:datestring];
    return date;
}

//Sat Jan 12 11:50:16 +0800 2013
+ (NSString *)fomateString:(NSString *)datestring {
    NSString *formate = @"E MMM d HH:mm:ss Z yyyy";
    NSDate *createDate = [FLYUtils dateFromFomate:datestring formate:formate];
    NSString *text = [FLYUtils stringFromFomate:createDate formate:@"MM-dd HH:mm"];
    return text;
}

+ (NSString *)betweenDate:(NSDate *)beginDate endDate:(NSDate *)endDate{
    NSString *timeString = @"";
    
    NSTimeInterval end = [endDate timeIntervalSince1970] * 1;
    NSTimeInterval start = [beginDate timeIntervalSince1970] * 1;
    NSTimeInterval cha = end - start;
    int ts = cha / 1;
    
    if (ts > 86400) {
        timeString = [NSString stringWithFormat:@"%@%d天", timeString , ts / 86400];
        ts = ts % 86400;
    }
    if (cha > 3600) {
        timeString = [NSString stringWithFormat:@"%@%d时", timeString , ts / 3600];
        ts = ts % 3600;
    }
    if (cha > 60) {
        timeString = [NSString stringWithFormat:@"%@%d分", timeString , ts / 60];
        ts = ts % 60;
    }
    return timeString;
}



@end
