//
//  FLYCouponCell.m
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCouponCell.h"
#import "FLYCouponModel.h"

#define redColor Color(238,82,117,1)
#define orangeColor Color(253,169,21,1)
#define greenColor Color(146,194,40,1)
#define blueColor Color(75,179,222,1)

@implementation FLYCouponCell

- (void)awakeFromNib {
    _leftView = (UIView *)[self viewWithTag:101];
    _rightView = (UIView *)[self viewWithTag:102];
    _amountLabel = (UILabel *)[self viewWithTag:103];
    _limitLabel = (UILabel *)[self viewWithTag:104];
    _beginLabel = (UILabel *)[self viewWithTag:105];
    _endLabel = (UILabel *)[self viewWithTag:106];
    _useLabel = (UILabel *)[self viewWithTag:107];
    
    _limitLabel.textAlignment = NSTextAlignmentCenter;
    _beginLabel.textAlignment = NSTextAlignmentCenter;
    _endLabel.textAlignment = NSTextAlignmentCenter;
    _useLabel.textAlignment = NSTextAlignmentCenter;

}

- (void)layoutSubviews{
    if (self.index % 4 == 0) {
        _leftView.backgroundColor = redColor;
    }else if(self.index % 4 == 1){
        _leftView.backgroundColor = orangeColor;
    }else if(self.index % 4 == 2){
        _leftView.backgroundColor = greenColor;
    }else if(self.index % 4 == 3){
        _leftView.backgroundColor = blueColor;
    }
    
    _amountLabel.text = [NSString stringWithFormat:@"%0.2f",[self.couponModel.cdAmount doubleValue] / 100.0];
    _beginLabel.text = self.couponModel.cdBegindate;
    _endLabel.text = self.couponModel.cdEnddate;
    
    
    if ([self.couponModel.cdFlag isEqualToString:@"1"]) {
        _useLabel.text = @"已使用";
    }else if([self.couponModel.EFlag isEqualToString:@"1"]){
        _useLabel.text = @"已过期";
    }else{
        _useLabel.text = @"立即使用";
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
