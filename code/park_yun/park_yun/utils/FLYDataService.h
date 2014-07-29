//
//  FLYDataService.h
//
//
//  Created by chen on 14-6-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

typedef void(^RequestFinishBlock)(id result);
typedef void(^RequestErrorBlock)();

@interface FLYDataService : NSObject

+ (ASIHTTPRequest *)requestWithURL:(NSString *)urlstring
                            params:(NSMutableDictionary *)params
                        httpMethod:(NSString *)httpMethod
                     completeBolck:(RequestFinishBlock)block
                     errorBolck:(RequestErrorBlock)error;

+ (ASIHTTPRequest *)requestWithURL:(NSString *)urlstring
                            params:(NSMutableDictionary *)params
                          progress:(id)progress
                     completeBolck:(RequestFinishBlock)block
                        errorBolck:(RequestErrorBlock)error;

@end
