//
//  FLYDataService.m
//
//
//  Created by chen on 14-6-29.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import "FLYDataService.h"

@implementation FLYDataService

+ (ASIHTTPRequest *)requestWithURL:(NSString *)urlstring
                            params:(NSMutableDictionary *)params
                        httpMethod:(NSString *)httpMethod
                     completeBolck:(RequestFinishBlock)block{
    
    //取得认证信息
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    NSString *token = [defaults stringForKey:@"token"];

    //拼接url
//    urlstring = [kHttpDomain stringByAppendingFormat:@"%@?access_token=%@",urlstring,token];
    
    NSComparisonResult comparGet = [httpMethod caseInsensitiveCompare:@"GET"];
    if (comparGet == NSOrderedSame) {
        NSMutableString *paramsString = [NSMutableString string];
        NSArray *allkey = [params allKeys];
        for (int i = 0; i < params.count; i++) {
            NSString *key = [allkey objectAtIndex:i];
            id value = [params objectForKey:key];
            [paramsString appendFormat:@"%@=%@",key,value];
            
            if (i < params.count - 1) {
                [paramsString appendString:@"&"];
            }
        }
        if (paramsString.length > 0) {
            urlstring = [urlstring stringByAppendingFormat:@"&%@",paramsString];
        }
    }
    
    NSLog(@"%@",urlstring);
    NSURL *url = [NSURL URLWithString:urlstring];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //设置超时时间
    [request setTimeOutSeconds:60];
    [request setRequestMethod:httpMethod];
    
    
    NSComparisonResult comparPost = [httpMethod caseInsensitiveCompare:@"POST"];
    //POST
    if (comparPost == NSOrderedSame) {
        NSArray *allkey = [params allKeys];
        for (int i=0; i<params.count; i++) {
            NSString *key = [allkey objectAtIndex:i];
            id value = [params objectForKey:key];
            //判断是否文件上传
            if ([value isKindOfClass:[NSData class]]) {
                [request addData:value forKey:key];
//                [request addFile:value forKey:key];
            }else{
                [request addPostValue:value forKey:key];
            }
        }
    }
    
    __block ASIFormDataRequest *req = request;
    //设置请求完成的BLOCK
    [request setCompletionBlock:^{
        NSData *data = req.responseData;
        float version = FLYOSVersion();
        id result = nil;
        if (version > 5.0) {
            result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
    
        if (block != nil) {
            block(result);
        }
    }];
    
    [request startAsynchronous];

    return request;
}

@end
