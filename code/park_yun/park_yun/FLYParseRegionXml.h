//
//  FLYParseRegionXml.h
//  park_yun
//
//  Created by chen on 14-8-6.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYParseRegionXml : NSObject<NSXMLParserDelegate>{
    NSMutableArray *_regionList;
    NSString *_tempElement;
}

- (NSMutableArray *)parseRegionData;

@end