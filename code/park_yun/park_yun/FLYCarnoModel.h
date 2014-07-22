//
//  FLYCarnoModel.h
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//"mcId": "FD1sss22355Fwe2AE040007F0100380C",
//"mcRegdate": "20140530",
//"mcMemberid": "FD0B7715F4853B7DE040007F010079B9",
//"mcFlag": "1",
//"mcCarno": "XX8888"

#import "FLYBaseModel.h"

@interface FLYCarnoModel : FLYBaseModel

@property(nonatomic,copy) NSString *mcId;
@property(nonatomic,copy) NSString *mcRegdate;
@property(nonatomic,copy) NSString *mcMemberid;
@property(nonatomic,copy) NSString *mcFlag;
@property(nonatomic,copy) NSString *mcCarno;

@end
