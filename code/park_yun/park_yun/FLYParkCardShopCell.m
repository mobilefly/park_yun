//
//  FLYParkCardShopCell.m
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkCardShopCell.h"

@implementation FLYParkCardShopCell

- (void)awakeFromNib {
    _parkNameLabel =  (UILabel *)[self viewWithTag:101];
    _chargeNameLabel =  (UILabel *)[self viewWithTag:102];
    _reduceBtn =  (UIButton *)[self viewWithTag:103];
    _shopNumField = (UITextField *)[self viewWithTag:104];
    _increaseBtn =  (UIButton *)[self viewWithTag:105];
    _amountLabel = (UILabel *)[self viewWithTag:106];
    _deleteBtn = (UIButton *)[self viewWithTag:107];
    
    _shopNumField.userInteractionEnabled = NO;
    
    _deleteBtn.layer.masksToBounds = YES;
    _deleteBtn.layer.cornerRadius = 2.0;
    _deleteBtn.layer.borderWidth = 0.1;
    _deleteBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
