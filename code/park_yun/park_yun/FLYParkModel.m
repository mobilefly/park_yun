//
//  FLYParkModel.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkModel.h"

@implementation FLYParkModel

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSDictionary *photoDic = [dataDic objectForKey:@"photo"];
    if (photoDic != nil) {
        FLYPhotoModel *photoModel = [[FLYPhotoModel alloc] initWithDataDic:photoDic];
        self.photo = photoModel;
    }
}

@end
