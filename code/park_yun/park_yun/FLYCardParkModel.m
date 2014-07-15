//
//  FLYParkCardModel.m
//  park_yun
//
//  Created by chen on 14-7-14.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCardParkModel.h"

@implementation FLYCardParkModel

- (void)setAttributes:(NSDictionary *)dataDic {
    //将字典数据根据映射关系填充到当前对象的属性上。
    [super setAttributes:dataDic];
    
    
    NSDictionary *parkDic = [dataDic objectForKey:@"park"];
    if (parkDic != nil) {
        FLYParkModel *parkModel = [[FLYParkModel alloc] initWithDataDic:parkDic];
        self.park = parkModel;
    }
    
    NSDictionary *memberCarnoDic = [dataDic objectForKey:@"memberCarno"];
    if (memberCarnoDic != nil) {
        FLYMemberCard *memberCarnoModel = [[FLYMemberCard alloc] initWithDataDic:memberCarnoDic];
        self.memberCarno = memberCarnoModel;
    }
}

@end
