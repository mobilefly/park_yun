//
//  FLYMessageCell.h
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYMessageModel.h"

@interface FLYMessageCell : UITableViewCell{
    //类型
    UILabel *_typeLabel;
    //状态
    UILabel *_statusLabel;
    //内容
    UILabel *_contentLabel;
    //时间
    UILabel *_timeLabel;
}

@property(nonatomic,strong)FLYMessageModel *messageModel;

@end
