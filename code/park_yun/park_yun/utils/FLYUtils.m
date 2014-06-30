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

+ (NSString *)parseLink:(NSString *)text{
    NSString *regex = @"(@\\w+)|(#\\w+#)|(http(s)?://([A-Za-z0-9._-]+(/)?)*)";
    NSArray *matchArray = [text componentsMatchedByRegex:regex];
    for (NSString *linkString in matchArray) {
        
        NSString *repalce = nil;
        if ([linkString hasPrefix:@"@"]) {
            NSString *name = [linkString substringFromIndex:1];
            repalce = [NSString stringWithFormat:@"<a href='user://%@'>%@</a>",[name URLEncodedString],linkString ];
        }
        else if ([linkString hasPrefix:@"http"]){
            repalce = [NSString stringWithFormat:@"<a href='%@'>%@</a>",linkString,linkString ];
        }
        else if([linkString hasPrefix:@"#"]){
            repalce = [NSString stringWithFormat:@"<a href='topic://%@'>%@</a>",[linkString URLEncodedString],linkString ];
        }
        
        if(linkString != nil){
            text = [text stringByReplacingOccurrencesOfString:linkString withString:repalce];
        }
    }
    return text;
}

@end
