//
//  FLYRemarkCell.h
//  park_yun
//
//  Created by chen on 14-7-24.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYRemarkModel.h"

@interface FLYRemarkCell : UITableViewCell{
    //手机号
    UILabel *_phoneLabel;
    
    UIView *_ratingview;
    //内容
    UILabel *_contentLabel;
    //时间
    UILabel *_timeLabel;
}

@property(nonatomic,strong)FLYRemarkModel *remarkModel;

@end
