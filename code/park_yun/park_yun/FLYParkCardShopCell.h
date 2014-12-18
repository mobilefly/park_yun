//
//  FLYParkCardShopCell.h
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYShopModel.h"


@protocol FLYParkCardShopDelegate <NSObject>
@optional
//增加数量
- (void)increase:(FLYShopModel *)model;
//减少数量
- (void)reduce:(FLYShopModel *)model;
//删除
- (void)delete:(FLYShopModel *)model;
@end

@interface FLYParkCardShopCell : UITableViewCell{
    UILabel *_parkNameLabel;
    UILabel *_chargeNameLabel;
    UIButton *_reduceBtn;
    UIButton *_increaseBtn;
    UITextField *_shopNumField;
    UILabel *_amountLabel;
    UIButton *_deleteBtn;
}


@property(nonatomic,strong)FLYShopModel *shopModel;

@property(assign,nonatomic)id<FLYParkCardShopDelegate> shopDelegate;


@end
