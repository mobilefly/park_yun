//
//  FLYUserCenterViewController.h
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYUserCenterViewController : FLYBaseViewController{
    UIView *_topView;
    
    //默认车牌号
    UILabel *_carNoLabel;
    
    UILabel *_balanceLabel;
    
    UIButton *_carBtn;
    
    UIActivityIndicatorView *_spinner;
}
@property (weak, nonatomic) IBOutlet UIView *middleView;

- (IBAction)billAction:(id)sender;
- (IBAction)memberInfoAction:(id)sender;
- (IBAction)rechargeAction:(id)sender;
- (IBAction)footmarkAction:(id)sender;
- (IBAction)collectAction:(id)sender;
- (IBAction)offlineMapAction:(id)sender;

@end
