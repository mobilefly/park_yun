//
//  FLYBillCell.h
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYMemberTraceModel.h"

@interface FLYBillCell : UITableViewCell{
    
    //商品名称
    UILabel *_orderNameLabel;
    
    UIImageView *_mtPaydateImage;
    //交易时间
    UILabel *_mtPaydateLabel;
    
    UILabel *_mtPriceTitle;
    //交易金额
    UILabel *_mtPriceLabel;
    
    UIImageView *_orderInfoImage;
    //订单信息
    UILabel *_orderInfoLabel;
    
    UILabel *_mtBalanceTitle;
    //余额
    UILabel *_mtBalanceLabel;
    
    UIView *_dateView;
    UILabel *_dayLabel;
    UILabel *_monthLabel;
}

@property(nonatomic,strong)FLYMemberTraceModel *traceModel;

@end
