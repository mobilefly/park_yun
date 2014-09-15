//
//  FLYParseBussinessXml.h
//  park_yun
//
//  Created by chen on 14-8-7.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYParseBussinessXml : NSObject<NSXMLParserDelegate>{
    NSMutableArray *_bussinessList;
    NSString *_tempElement;
}

- (NSMutableArray *)parseBussinessData;

@end
