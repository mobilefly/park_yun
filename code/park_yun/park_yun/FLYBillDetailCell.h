//
//  FLYBillDetailCell.h
//  park_yun
//
//  Created by chen on 14-7-30.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYGoodsOrderModel.h"

@interface FLYBillDetailCell : UITableViewCell{
    UIView *_bgView;
    UILabel *_goodLabel;
    UILabel *_priceLabel;
}

@property(nonatomic,strong) FLYGoodsOrderModel *goModel;

@end
