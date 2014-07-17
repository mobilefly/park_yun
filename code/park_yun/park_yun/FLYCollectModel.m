//
//  FLYCollectModel.m
//  park_yun
//
//  Created by chen on 14-7-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCollectModel.h"

@implementation FLYCollectModel

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSDictionary *parkDic = [dataDic objectForKey:@"park"];
    if (parkDic != nil) {
        FLYParkModel *parkModel = [[FLYParkModel alloc] initWithDataDic:parkDic];
        self.park = parkModel;
    }
}

@end
