//
//  FLYMemberTraceModel.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMemberTraceModel.h"


@implementation FLYMemberTraceModel

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSDictionary *orderDic = [dataDic objectForKey:@"order"];
    if (orderDic != nil) {
        FLYOrderModel *orderModel = [[FLYOrderModel alloc] initWithDataDic:orderDic];
        self.order = orderModel;
    }
}

@end
