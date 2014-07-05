//
//  BaseViewController.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ThemeImageView.h"
#import "UIFactory.h"

@interface FLYBaseViewController : UIViewController{
    UIView *_loadView;
    UIWindow *_tipWindow;
    ThemeImageView *barView;
}

@property(nonatomic,assign) BOOL isBackButton;

@property(nonatomic,assign) BOOL isCancelButton;

@property(nonatomic,strong) MBProgressHUD *hud;

//提示
- (void)showLoading:(BOOL)show;
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim;
- (void)hideHUD;
- (void)showHUDComplete:(NSString *)title;
//状态栏提示
- (void)showStatusTip:(BOOL)show tilte:(NSString *)title;

- (void)alert:(NSString *)message;
//消息提示
- (void)showMessage:(NSString *)msg;

@end
