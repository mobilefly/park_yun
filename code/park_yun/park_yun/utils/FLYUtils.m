//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import "RegexKitLite.h"
#import "NSString+URLEncoding.h"
#import "FLYToast.h"

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
    NSString *formate = @"yyyyMMddHHmmss";
    NSDate *createDate = [FLYUtils dateFromFomate:datestring formate:formate];
    NSString *text = [FLYUtils stringFromFomate:createDate formate:@"MM/dd HH:mm"];
    return text;
}

+ (NSString *)fomateString:(NSString *)datestring formate:(NSString *)formate {
    NSString *sformate = @"yyyyMMddHHmmss";
    NSDate *createDate = [FLYUtils dateFromFomate:datestring formate:sformate];
    NSString *text = [FLYUtils stringFromFomate:createDate formate:formate];
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

+ (NSString *)getDataSizeString:(int) nSize{
    NSString *string = nil;
	if (nSize<1024)
	{
		string = [NSString stringWithFormat:@"%dB", nSize];
	}
	else if (nSize<1048576)
	{
		string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
	}
	else if (nSize<1073741824)
	{
		if ((nSize%1048576)== 0 )
        {
			string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
		else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
	}
	else	// >1G
	{
		string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
	}
	return string;
}

+ (NSString *)getSmallImage:(NSString *)url width:(NSString *)width height:(NSString *)height{
    NSString *result = @"";
    if ([FLYBaseUtil isNotEmpty:url]) {
        NSRange range = [url rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound){
            result = [NSString stringWithFormat:@"%@_small_%@_%@%@",[url substringToIndex:range.location],width,height,[url substringFromIndex:range.location]];
        }
    }
    return result;
}

//行车导航
+ (void)drivingNavigation:(NSString *)name start:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D) end{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
        NSString *urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&mode=driving&src=停哪儿",
                               start.latitude, start.longitude, end.latitude, end.longitude, name];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }else{
        [FLYToast showWithText:@"请先下载安装百度地图"];
    }
}

+ (NSString *)getParkSpeech:(FLYParkModel *)parkModel{
    NSString *parkName = parkModel.parkName;
    NSString *parkDistance = @"";
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    BMKMapPoint point1 = BMKMapPointForCoordinate(appDelegate.coordinate);
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([parkModel.parkLat doubleValue],[parkModel.parkLng doubleValue]));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    if (distance > 1000) {
        parkDistance = [NSString stringWithFormat:@"%.1f千米",distance / 1000];
    }else{
        parkDistance = [NSString stringWithFormat:@"%.0f米",distance];
    }
    
    NSString *seatidea = @"";
    
    if ([parkModel.parkStatus isEqualToString:@"0"]) {
        
        seatidea = [NSString stringWithFormat:@"目前共有空车位%i个",[parkModel.seatIdle integerValue]];
    }else if([parkModel.parkStatus isEqualToString:@"1"]){
        seatidea = @"空车位未知";
    }else{
        seatidea = @"空车位未知";
    }
    
    NSString *result = [NSString stringWithFormat:@"%@距离%@，%@",parkName,parkDistance,seatidea];
    
    NSString *freeTime = @"";
    if (parkModel.parkFreetime == nil || [parkModel.parkFreetime intValue] == 0) {
        freeTime = nil;
        
        if ([FLYBaseUtil isNotEmpty:parkModel.parkFeedesc]) {
            freeTime = [freeTime stringByAppendingFormat:@"，收费标准%@",parkModel.parkFeedesc];
        }
    }else if([parkModel.parkFreetime intValue] == -1){
        freeTime = @"全天免费";
    }else{
        freeTime = [NSString stringWithFormat:@"免费停车时长%@分钟",parkModel.parkFreetime];
        
        if ([FLYBaseUtil isNotEmpty:parkModel.parkFeedesc]) {
            freeTime = [freeTime stringByAppendingFormat:@"，收费标准%@",parkModel.parkFeedesc];
        }
    }
    
    if (freeTime != nil) {
        result = [NSString stringWithFormat:@"%@，%@",result,freeTime];
    }
    
    NSLog(@"%@",result);
    
    return result;
}

@end
