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
    UIView *_leftView;
    UIView *_rightView;
    UILabel *_amountLabel;
    UILabel *_limitLabel;
    UILabel *_beginLabel;
    UILabel *_endLabel;
    UILabel *_useLabel;

}

@property(nonatomic,strong)FLYCouponModel *couponModel;
@property(nonatomic)int index;

@end
