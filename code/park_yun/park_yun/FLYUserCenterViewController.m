//
//  FLYUserCenterViewController.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYUserCenterViewController.h"
#import "UIButton+Bootstrap.h"
#import "FLYLoginViewController.h"
#import "FLYBaseNavigationController.h"
#import "FLYRechargeViewController.h"
#import "DXAlertView.h"
#import "FLYSettingViewController.h"
#import "FLYBillViewController.h"
#import "FLYOfflineMapViewController.h"

@interface FLYUserCenterViewController ()

@end

@implementation FLYUserCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的停哪儿";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *settingBtn = [UIFactory createButton:@"mfpparking_shezhi_all_up.png" hightlight:@"mfpparking_shezhi_all_down.png"];
    settingBtn.showsTouchWhenHighlighted = YES;
    settingBtn.frame = CGRectMake(0, 0, 30, 30);
    [settingBtn addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItem = settingItem;
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake((ScreenWidth - 220) / 2, ScreenHeight - 150 , 220, 40);
    
    if ([FLYBaseUtil checkUserLogin]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"memberName"];
        [loginBtn warningStyle];
        NSString *str = [NSString stringWithFormat:@"注销（%@）",username];
        [loginBtn setTitle:str forState:UIControlStateNormal];
    }else{
        [loginBtn primaryStyle];
        [loginBtn setTitle:@"会员登陆" forState:UIControlStateNormal];
    }
    loginBtn.tag = 101;
    [loginBtn addAwesomeIcon:FAIconUser beforeTitle:YES];
    [loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
}

- (void)viewWillAppear:(BOOL)animated{
     UIButton *longinBtn = (UIButton *)[self.view viewWithTag:101];
    if (longinBtn != nil) {
        //已登陆
        if ([FLYBaseUtil checkUserLogin]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *username = [defaults stringForKey:@"memberName"];
            [longinBtn warningStyle];
            NSString *str = [NSString stringWithFormat:@"注销（%@）",username];
            [longinBtn setTitle:str forState:UIControlStateNormal];
        }
        //未登陆
        else{
            [longinBtn primaryStyle];
            [longinBtn setTitle:@"会员登陆" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Action
//用户登陆注销
-(void)loginAction:(UIButton *)button{
    //注销用户
    if ([FLYBaseUtil checkUserLogin]) {
        [FLYBaseUtil clearUserInfo];
        [button primaryStyle];
        [button setTitle:@"会员登陆" forState:UIControlStateNormal];
    }else{
        FLYLoginViewController *loginController = [[FLYLoginViewController alloc] init];
        FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:loginController];
        [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
    }
}

-(void)settingAction:(UIButton *)button{
    FLYSettingViewController *settingController = [[FLYSettingViewController alloc]init];
    [self.navigationController pushViewController:settingController animated:NO];
}

//账单
- (IBAction)billAction:(id)sender {
    if ([FLYBaseUtil checkUserLogin]) {
        FLYBillViewController *billController = [[FLYBillViewController alloc]init];
        [self.navigationController pushViewController:billController animated:NO];
    }else{
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"请先登陆用户" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
    }
}

//会员信息
- (IBAction)memberInfoAction:(id)sender {
    
}

//账户充值
- (IBAction)rechargeAction:(id)sender {
    if ([FLYBaseUtil checkUserLogin]) {
        FLYRechargeViewController *rechargeController = [[FLYRechargeViewController alloc]init];
        [self.navigationController pushViewController:rechargeController animated:NO];
    }else{
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"请先登陆用户" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
    }
}

//足迹
- (IBAction)footmarkAction:(id)sender {
}

//收藏
- (IBAction)collectAction:(id)sender {

    
}

//离线地图
- (IBAction)offlineMapAction:(id)sender {
    FLYOfflineMapViewController *mapController = [[FLYOfflineMapViewController alloc]init];
    [self.navigationController pushViewController:mapController animated:NO];
}


#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
