//
//  FLYParkGateModel.m
//  park_yun
//
//  Created by chen on 14-7-22.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkGateModel.h"

@implementation FLYParkGateModel

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    NSArray *photoArr = [dataDic objectForKey:@"photo"];
    if (photoArr != nil && [photoArr count] > 0) {
        NSDictionary *photoDic = [photoArr objectAtIndex:0];
        FLYPhotoModel *photoModel = [[FLYPhotoModel alloc] initWithDataDic:photoDic];
        self.photo = photoModel;
    }
}


@end
