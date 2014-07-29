//
//  FLYOrderModel.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYOrderModel.h"


@implementation FLYOrderModel


- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSDictionary *goDic = [dataDic objectForKey:@"goodsOrder"];
    if (goDic != nil) {
        FLYGoodsOrderModel *goModel = [[FLYGoodsOrderModel alloc] initWithDataDic:goDic];
        self.goodsOrder = goModel;
    }
}

@end
