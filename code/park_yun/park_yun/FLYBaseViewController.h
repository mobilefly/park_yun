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

@protocol FLYBaseCtrlDelegate <NSObject>
@required
//关闭
- (BOOL)close;
@end


@interface FLYBaseViewController : UIViewController<MBProgressHUDDelegate>{
    UIView *_loadView;
    UIWindow *_tipWindow;
    ThemeImageView *barView;

    UIView *_noDataView;
    BOOL _isHudLoad;
}

@property(nonatomic,assign) BOOL isBackButton;

@property(nonatomic,assign) BOOL isCancelButton;

@property(nonatomic,strong) MBProgressHUD *hud;

@property(assign,nonatomic)id<FLYBaseCtrlDelegate> ctrlDelegate;

-(void)showNoDataView:(BOOL)show;
-(void)setNoDataViewFrame:(CGRect)rect;

//提示
- (void)showLoading:(BOOL)show;
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim;
- (void)hideHUD;
- (void)showHUDComplete:(NSString *)title;
- (void)showHUDProgress:(NSString *)title isDim:(BOOL)isDim;
- (void)updateHUDProgress:(float)progress;


//状态栏提示
- (void)showStatusTip:(BOOL)show tilte:(NSString *)title;

- (void)showAlert:(NSString *)message;
//消息提示
- (void)showMessage:(NSString *)msg;
//提示
- (void)showToast:(NSString *)mag;
//隐藏多余分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView;

- (void)cancel;

- (void)back;

@end
