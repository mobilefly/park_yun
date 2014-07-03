//
//  BaseViewController.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYBaseViewController ()

@end

@implementation FLYBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 提示
- (void)showLoading:(BOOL)show{
    if (_loadView == nil) {
        //loading视图
        _loadView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight/2, ScreenWidth, 20)];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        
        //正在加载Label
        UILabel *loadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadLabel.backgroundColor = [UIColor clearColor];
        loadLabel.text = @"正在加载...";
        loadLabel.font = [UIFont systemFontOfSize:14.0];
        loadLabel.textColor = [UIColor blackColor];
        [loadLabel sizeToFit];
        
        loadLabel.left = (320 - loadLabel.width)/2;
        
        activityView.right = loadLabel.left - 10;
        activityView.top = activityView.top - 2;
        
        [_loadView addSubview:loadLabel];
        [_loadView addSubview:activityView];
    }
    if (show) {
        if(![_loadView superview]){
            [self.view addSubview:_loadView];
        }
    }else{
        [_loadView removeFromSuperview];
    }
}

- (void)showHUD:(NSString *)title isDim:(BOOL)isDim{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //是否灰色背景
    self.hud.dimBackground = YES;
    if (title.length > 0) {
        self.hud.labelText = title;
    }
}

- (void)showHUDComplete:(NSString *)title{
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.mode = MBProgressHUDModeCustomView;
    if (title.length > 0) {
        self.hud.labelText = title;
    }
    [self.hud hide:YES afterDelay:1];
}

- (void)hideHUD{
    [self.hud hide:YES];
}

- (void)showStatusTip:(BOOL)show tilte:(NSString *)title{
    if (_tipWindow == nil) {
        _tipWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        _tipWindow.windowLevel = UIWindowLevelStatusBar;
        _tipWindow.backgroundColor = [UIColor blackColor];
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:12.0];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.tag = 2013;
        [_tipWindow addSubview:tipLabel];
        
        UIImageView *progress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"queue_statusbar_progress.png"]];
        
        progress.frame = CGRectMake(0, 20 - 6, 100, 6);
        progress.tag = 2012;
        [_tipWindow addSubview:progress];
    }
    
    UILabel *tipLabel = (UILabel *)[_tipWindow viewWithTag:2013];
    UILabel *progress = (UILabel *)[_tipWindow viewWithTag:2012];
    if (show) {
        tipLabel.text = title;
        //显示主window
        //[_tipWindow makeKeyAndVisible];
        _tipWindow.hidden = NO;
        
        progress.left = 0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        [UIView setAnimationRepeatCount:1000];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        progress.left = ScreenWidth;
        [UIView commitAnimations];
        
    }else{
        //_tipWindow.hidden = NO;
        progress.hidden = YES;
        tipLabel.text = title;
        [self performSelector:@selector(removeTipWindow) withObject:nil afterDelay:1.5];
    }
}


- (void)removeTipWindow{
    _tipWindow.hidden = NO;
    _tipWindow = nil;
}

@end
