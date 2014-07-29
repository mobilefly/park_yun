//
//  FLYDataService.m
//
//
//  Created by chen on 14-6-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYDataService.h"

@implementation FLYDataService

+ (ASIHTTPRequest *)requestWithURL:(NSString *)urlstring
                            params:(NSMutableDictionary *)params
                        httpMethod:(NSString *)httpMethod
                     completeBolck:(RequestFinishBlock)block
                     errorBolck:(RequestErrorBlock)error{
    
    //取得认证信息
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    NSString *token = [defaults stringForKey:@"token"];

    //拼接url
    urlstring = [kHttpDomain stringByAppendingFormat:@"%@",urlstring];
    
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
    [request setTimeOutSeconds:10];
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
                //[request addFile:value forKey:key];
            }else{
                [request addPostValue:value forKey:key];
            }
        }
    }
    
    __block ASIFormDataRequest *req = request;
    //设置请求完成的BLOCK
    [request setCompletionBlock:^{
        NSData *data = req.responseData;
        id result = nil;

        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
        if (block != nil) {
            block(result);
        }
    }];
    
    [request setFailedBlock:^{
        if (error != nil) {
            error();
        }
    }];
    
    [request startAsynchronous];

    return request;
}
+ (ASIHTTPRequest *)requestWithURL:(NSString *)urlstring
                            params:(NSMutableDictionary *)params
                          progress:(id)progress
                     completeBolck:(RequestFinishBlock)block
                        errorBolck:(RequestErrorBlock)error{
    //拼接url
    urlstring = [kHttpDomain stringByAppendingFormat:@"%@",urlstring];
    
    NSLog(@"%@",urlstring);
    NSURL *url = [NSURL URLWithString:urlstring];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //设置超时时间
    [request setTimeOutSeconds:600];
    [request setRequestMethod:@"POST"];
    
    //POST
    NSArray *allkey = [params allKeys];
    for (int i=0; i<params.count; i++) {
        NSString *key = [allkey objectAtIndex:i];
        id value = [params objectForKey:key];
        //判断是否文件上传
        if ([value isKindOfClass:[NSData class]]) {
            [request addData:value forKey:key];
        }else{
            [request addPostValue:value forKey:key];
        }
    }
    [request setUploadProgressDelegate:progress];
    request.showAccurateProgress=YES;

    __block ASIFormDataRequest *req = request;
    //设置请求完成的BLOCK
    [request setCompletionBlock:^{
        NSData *data = req.responseData;
        id result = nil;
        
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if (block != nil) {
            block(result);
        }
    }];
    
    [request setFailedBlock:^{
        if (error != nil) {
            error();
        }
    }];
    
    [request startAsynchronous];
    
    return request;
}

@end
