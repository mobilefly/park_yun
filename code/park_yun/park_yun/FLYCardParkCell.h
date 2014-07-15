//
//  FLYCardParkCell.h
//  park_yun
//
//  Created by chen on 14-7-14.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYCardParkModel.h"

@interface FLYCardParkCell : UITableViewCell{
    UIView *_bgView;
    UILabel *_parknameLabel;
    UILabel *_mcCarnoLabel;
    UILabel *_cardCodeLabel;
    UILabel *_cpExpdateLabel;
    

}

@property(nonatomic,strong)FLYCardParkModel *cardParkModel;


@end
