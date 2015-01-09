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
    _deleteBtn.layer.cornerRadius = 3.0;
    _deleteBtn.layer.borderWidth = 1;
    _deleteBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    _deleteBtn.backgroundColor = [UIColor orangeColor];
    
    _amountLabel.textAlignment = NSTextAlignmentRight;
    _amountLabel.textColor = [UIColor orangeColor];
    
    _shopNumField.textAlignment = NSTextAlignmentCenter;
    _shopNumField.height = 25;
    _shopNumField.top = _shopNumField.top + (30 - 25) / 2;
    
    [_increaseBtn addTarget:self action:@selector(increaseAction:) forControlEvents:UIControlEventTouchDown];
    
    [_reduceBtn addTarget:self action:@selector(reduceAction:) forControlEvents:UIControlEventTouchDown];
    
    [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    float price = [self.shopModel.parkCard.pcPrice floatValue] / 100;
    int buyNum = self.shopModel.buyNum;
    
    _parkNameLabel.text = self.shopModel.parkValue;
    _chargeNameLabel.text = [NSString stringWithFormat:@"%i个月套餐",[self.shopModel.parkCard.pcMonth intValue]];
    _shopNumField.text = [NSString stringWithFormat:@"%i",buyNum];
    _amountLabel.text = [NSString stringWithFormat:@"￥%0.2f",price * buyNum];
    
}

- (void)increaseAction:(UIButton *)btn{
    int buyNum = [_shopNumField.text intValue];
    buyNum = buyNum + 1;
    self.shopModel.buyNum = buyNum;
    _shopNumField.text = [NSString stringWithFormat:@"%i",buyNum];
    float price = [self.shopModel.parkCard.pcPrice floatValue] / 100;
    _amountLabel.text = [NSString stringWithFormat:@"￥%0.2f",price * buyNum];
    
    
    if ([self.shopDelegate respondsToSelector:@selector(increase:)]) {
        [self.shopDelegate increase:self.shopModel];
    }
}

- (void)reduceAction:(UIButton *)btn{
    int buyNum = [_shopNumField.text intValue];
    if (buyNum > 1) {
        buyNum = buyNum - 1;
        self.shopModel.buyNum = buyNum;
        _shopNumField.text = [NSString stringWithFormat:@"%i",buyNum];
        float price = [self.shopModel.parkCard.pcPrice floatValue] / 100;
        _amountLabel.text = [NSString stringWithFormat:@"￥%0.2f",price * buyNum];
        
        
        if ([self.shopDelegate respondsToSelector:@selector(reduce:)]) {
            [self.shopDelegate reduce:self.shopModel];
        }
    }
}

- (void)deleteAction:(UIButton *)btn{
    if ([self.shopDelegate respondsToSelector:@selector(delete:)]) {
        [self.shopDelegate delete:self.shopModel];
    }
}


@end
