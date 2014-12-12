//
//  FLYMessageModel.h
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

//messageTitle	string	消息标题
//messageContent	string	消息内容
//messageMemberid	string	需要发送消息的会员ID
//messageType	string	消息类型
//messageFlag	string	发送状态
//messageAddtime	string	发送时间

#import "FLYBaseModel.h"

@interface FLYMessageModel : FLYBaseModel

@property(nonatomic,copy) NSString *messageTitle;
@property(nonatomic,copy) NSString *messageContent;
@property(nonatomic,copy) NSString *messageMemberid;
@property(nonatomic,copy) NSString *messageType;
@property(nonatomic,copy) NSString *messageFlag;
@property(nonatomic,copy) NSString *messageAddtime;

@end
