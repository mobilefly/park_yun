//
//  BaseViewController.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface FLYBaseViewController : UIViewController{
    UIView *_loadView;
    UIWindow *_tipWindow;
}

@property(nonatomic,strong) MBProgressHUD *hud;

//提示
- (void)showLoading:(BOOL)show;
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim;
- (void)hideHUD;
- (void)showHUDComplete:(NSString *)title;
//状态栏提示
- (void)showStatusTip:(BOOL)show tilte:(NSString *)title;

@end
