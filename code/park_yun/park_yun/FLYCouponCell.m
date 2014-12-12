//
//  FLYCouponCell.m
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCouponCell.h"
#import "FLYCouponModel.h"

@implementation FLYCouponCell

- (void)awakeFromNib {
    _iconImage = (UIImageView *)[self viewWithTag:101];
    _amountTitleLabel = (UILabel *)[self viewWithTag:102];
    _amountLabel = (UILabel *)[self viewWithTag:103];
    _unitLabel = (UILabel *)[self viewWithTag:104];
    _statusBtn = (UIButton *)[self viewWithTag:105];
    _couponTitleLabel = (UILabel *)[self viewWithTag:106];
    _couponLabel = (UILabel *)[self viewWithTag:107];
    _dateLabel = (UILabel *)[self viewWithTag:108];
}

- (void)layoutSubviews{
    
    _iconImage.frame = CGRectMake(8, 6, 23, 22);
    
    [_amountTitleLabel sizeToFit];
    _amountTitleLabel.left = _iconImage.right + 5;
    
    _amountLabel.text = [NSString stringWithFormat:@"%0.2f",[self.couponModel.cdAmount doubleValue] / 100.0];
    [_amountLabel sizeToFit];
    _amountLabel.left = _amountTitleLabel.right;
    
    [_unitLabel sizeToFit];
    _unitLabel.left = _amountLabel.right + 5;
    
    
    if([self.couponModel.cdFlag isEqual:@"1"]){
        [_statusBtn setTitle:@"已使用" forState:UIControlStateNormal];
        [_statusBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else if([self.couponModel.EFlag isEqual:@"1"]){
        [_statusBtn setTitle:@"已过期" forState:UIControlStateNormal];
        [_statusBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else{
        [_statusBtn setTitle:@"未使用" forState:UIControlStateNormal];
        [_statusBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    //设置矩形四个圆角半径
    [_statusBtn.layer setMasksToBounds:YES];
    [_statusBtn.layer setCornerRadius:5.0];
    
    [_couponTitleLabel sizeToFit];
    
    _couponLabel.left = _couponTitleLabel.right + 5;
    _couponLabel.text = self.couponModel.cdNo;
    [_couponLabel sizeToFit];
    _dateLabel.text = [NSString stringWithFormat:@"%@-%@",self.couponModel.cdBegindate,self.couponModel.cdEnddate];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
