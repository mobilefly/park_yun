//
//  FLYRemarkModel.h
//  park_yun
//
//  Created by chen on 14-7-24.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//remarkContent	string	评论内容
//remarkTotal	int	评论总分
//remarkTime	String	评论时间

#import "FLYBaseModel.h"
#import "FLYMemberModel.h"

@interface FLYRemarkModel : FLYBaseModel

@property(nonatomic,copy) NSString *remarkContent;
@property(nonatomic,copy) NSNumber *remarkTotal;
@property(nonatomic,copy) NSString *remarkTime;

@property(nonatomic,strong) FLYMemberModel *member;

@end
