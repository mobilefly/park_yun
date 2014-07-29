//
//  FLYRemarkModel.m
//  park_yun
//
//  Created by chen on 14-7-24.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYRemarkModel.h"

@implementation FLYRemarkModel

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSDictionary *memberDic = [dataDic objectForKey:@"member"];
    if (memberDic != nil) {
        FLYMemberModel *memberModel = [[FLYMemberModel alloc] initWithDataDic:memberDic];
        self.member = memberModel;
    }
}

@end
