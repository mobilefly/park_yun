//
//  BaseViewController.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "DXAlertView.h"
#import "FLYToast.h"


@interface FLYBaseViewController ()

@end

@implementation FLYBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isBackButton = YES;
        self.isCancelButton = NO;
        _isHudLoad = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *viewController = self.navigationController.viewControllers;
    if(viewController.count > 1 && self.isBackButton){
        UIButton *button = [UIFactory createButton:@"mfpparking_back_all_up.png" hightlight:@"mfpparking_back_all_down.png"];
        button.showsTouchWhenHighlighted = YES;
        button.frame = CGRectMake(0, 0, 24, 24);
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    if (self.isCancelButton) {
        UIButton *cancelButton = [UIFactory createNavigationButton:CGRectMake(0, 0, 45, 30) title:@"关闭" target:self action:@selector(cancelAction)];
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.leftBarButtonItem = cancelButtonItem;
    }
    
    _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44)];
    _noDataView.hidden = YES;
    _noDataView.backgroundColor = [UIColor clearColor];
    
    //背景图片
    UIImageView *noDataImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_wushujul_all_0_03.png"]];
    noDataImage.frame = CGRectMake((_noDataView.width - 82) / 2, (_noDataView.height - 106) / 2, 82, 106);
    noDataImage.tag = 201;
    
    [_noDataView addSubview:noDataImage];
    [self.view addSubview:_noDataView];
    
}

- (void)cancelAction{
    [self dismissViewControllerAnimated:NO completion:NULL];
}


- (void)backAction{
    NSArray *viewController = self.navigationController.viewControllers;
    if(viewController.count > 2){
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:NO];
    }
}

//override
- (void)setTitle:(NSString *)title{
    [super setTitle:title];
    
    UILabel *titleLabel = [UIFactory createLabel:kNavigationBarTitleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}



#pragma mark - 提示
-(void)setNoDataViewFrame:(CGRect)rect{
    _noDataView.frame = rect;
    //背景图片
    UIImageView *noDataImage = (UIImageView *) [_noDataView viewWithTag:201];
    noDataImage.frame = CGRectMake((_noDataView.width - 82) / 2, (_noDataView.height - 106) / 2, 82, 106);
    noDataImage.tag = 201;
}

-(void)showNoDataView:(BOOL)show{
    _noDataView.hidden = !show;
}

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
    self.hud.dimBackground = isDim;
    
    self.hud.mode = MBProgressHUDModeDeterminate;
    
    self.hud.delegate = self;
    //self.hud.labelText = @"加载中";
    
    if (title.length > 0) {
        self.hud.labelText = title;
    }
    _isHudLoad = YES;
    
    [self.hud showWhileExecuting:@selector(hudProgressTask) onTarget:self withObject:nil animated:YES];
}

- (void)hudProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (_isHudLoad) {
        progress += 0.01f;
        self.hud.progress = progress;
        usleep(50000);
        
        if (progress >= 1.0f) {
            progress = 0.0f;
        }
    }
}

- (void)showHUDProgress:(NSString *)title isDim:(BOOL)isDim{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //是否灰色背景
    self.hud.dimBackground = isDim;
    
    self.hud.mode = MBProgressHUDModeDeterminate;
    
    self.hud.delegate = self;
    //self.hud.labelText = @"加载中";
    
    if (title.length > 0) {
        self.hud.labelText = title;
    }
    _isHudLoad = YES;
}

- (void)updateHUDProgress:(float)progress{
    self.hud.progress = progress;
    self.hud.detailsLabelText = [NSString stringWithFormat:@"%.2f",progress * 100];
}

- (void)showHUDComplete:(NSString *)title{
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.hud.delegate = self;
    self.hud.mode = MBProgressHUDModeCustomView;
    if (title.length > 0) {
        self.hud.labelText = title;
    }
    [self.hud hide:YES afterDelay:1];
    _isHudLoad = NO;
}

- (void)hideHUD{
    [self.hud hide:NO];
    _isHudLoad = NO;
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

- (void)showAlert:(NSString *)message{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:message leftButtonTitle:nil rightButtonTitle:@"确认"];
    [alert show];
    alert.rightBlock = ^() {
        
    };
    alert.dismissBlock = ^() {
        
    };
}

- (void)showMessage:(NSString *)msg {
    if (barView == nil) {
        barView = [UIFactory createImageView:@"timeline_new_status_background.png"];
        UIImage *image = [barView.image stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        barView.image = image;
        //切换主题时使用
        barView.leftCapWidth = 5;
        barView.topCapHeight = 5;
        barView.frame = CGRectMake(5, -40, ScreenWidth - 10, 40);
        [self.view addSubview:barView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = 201;
        label.font = [UIFont systemFontOfSize:16.0f];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [barView addSubview:label];
    }
    if (msg != nil) {
        UILabel *label = (UILabel *)[barView viewWithTag:201];
        label.text = [NSString stringWithFormat:@"%@",msg];
        [label sizeToFit];
        label.origin = CGPointMake(((barView.width - label.width)/2), (barView.height - label.height)/2);
        
        [UIView animateWithDuration:0.6 animations:^{
            barView.top = 25;
        } completion:^(BOOL finish){
            if (finish) {
                //延时一秒
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDelay:1];
                [UIView setAnimationDuration:0.6];
                barView.top = -40;
                [UIView commitAnimations];
            }
        }];
        
        //播放声音
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
//        NSURL *url = [NSURL fileURLWithPath:filePath];
//        SystemSoundID soundId;
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &(soundId));
//        AudioServicesPlayAlertSound(soundId);
    }
    
}

- (void)showToast:(NSString *)mag{
    [FLYToast showWithText:mag];
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.hud removeFromSuperview];
	self.hud = nil;
    _isHudLoad = NO;
}

#pragma mark - tableView
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - view other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _isHudLoad = NO;
}

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
