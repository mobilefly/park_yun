//
//  FLYBillDetailCell.m
//  park_yun
//
//  Created by chen on 14-7-30.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBillDetailCell.h"

@implementation FLYBillDetailCell

- (void)awakeFromNib
{
    _bgView = (UIView *)[self viewWithTag:100];
    _goodLabel = (UILabel *)[self viewWithTag:101];
    _priceLabel = (UILabel *)[self viewWithTag:102];
}


- (void)layoutSubviews{
    _bgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _bgView.layer.borderWidth = 1;
    _bgView.layer.cornerRadius = 5.0;
    _bgView.layer.masksToBounds = YES;
    
    _goodLabel.text = self.goModel.goName;
    _priceLabel.text = [NSString stringWithFormat:@"金额:%0.2f",[self.goModel.goPrice doubleValue] / 100];
    
    [_priceLabel sizeToFit];
    _priceLabel.right = 290;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
