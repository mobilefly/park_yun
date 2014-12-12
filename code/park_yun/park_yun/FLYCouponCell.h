//
//  FLYCouponCell.h
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYCouponModel.h"

@interface FLYCouponCell : UITableViewCell{
    UIImageView *_iconImage;
    UILabel *_amountTitleLabel;
    UILabel *_amountLabel;
    UILabel *_unitLabel;
    UIButton *_statusBtn;
    UILabel *_couponTitleLabel;
    UILabel *_couponLabel;
    UILabel *_dateLabel;

}

@property(nonatomic,strong)FLYCouponModel *couponModel;

@end
