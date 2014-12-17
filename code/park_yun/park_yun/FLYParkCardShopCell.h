//
//  FLYParkCardShopCell.h
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYParkCardShopCell : UITableViewCell{
    UILabel *_parkNameLabel;
    UILabel *_chargeNameLabel;
    UIButton *_reduceBtn;
    UIButton *_increaseBtn;
    UITextField *_shopNumField;
    UILabel *_amountLabel;
    UIButton *_deleteBtn;
}

@end
