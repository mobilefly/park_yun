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
#import "FLYSettingViewController.h"
#import "FLYBillViewController.h"
#import "FLYOfflineMapViewController.h"
#import "FLYFootmarkViewController.h"
#import "FLYCardParkViewController.h"
#import "FLYCollectViewController.h"

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
        
        NSString *str = [NSString stringWithFormat:@"注销（%@）",username == nil ? @"会员":username];
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
    UIButton *loginBtn = (UIButton *)[self.view viewWithTag:101];
    if (loginBtn != nil) {
        //已登陆
        if ([FLYBaseUtil checkUserLogin]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *username = [defaults stringForKey:@"memberName"];
            [loginBtn warningStyle];
            
            
            NSString *str = [NSString stringWithFormat:@"注销（%@）",username == nil ? @"会员":username];
            [loginBtn setTitle:str forState:UIControlStateNormal];
        }
        //未登陆
        else{
            [loginBtn primaryStyle];
            [loginBtn setTitle:@"会员登陆" forState:UIControlStateNormal];
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
        [self showAlert:@"请先登陆用户"];
    }
}

//会员信息
- (IBAction)memberInfoAction:(id)sender {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *memberType = [defaults stringForKey:@"memberType"];
    
    if (![FLYBaseUtil checkUserLogin]) {
        [self showAlert:@"请先登陆用户"];
    }else if(![memberType isEqualToString:@"3"]){
        [self showAlert:@"不是畅听卡用户"];
    }else{
        FLYCardParkViewController *cardParkController = [[FLYCardParkViewController alloc]init];
        [self.navigationController pushViewController:cardParkController animated:NO];
    }
    
    
}

//账户充值
- (IBAction)rechargeAction:(id)sender {
    if ([FLYBaseUtil checkUserLogin]) {
        FLYRechargeViewController *rechargeController = [[FLYRechargeViewController alloc]init];
        [self.navigationController pushViewController:rechargeController animated:NO];
    }else{
        [self showAlert:@"请先登陆用户"];
    }
}

//足迹
- (IBAction)footmarkAction:(id)sender {
    if (![FLYBaseUtil checkUserLogin]) {
        [self showAlert:@"请先登陆用户"];
    }else if(![FLYBaseUtil checkUserBindCar]){
        [self showAlert:@"未绑定任何车牌"];
    }else{
        FLYFootmarkViewController *footmarkController = [[FLYFootmarkViewController alloc]init];
        [self.navigationController pushViewController:footmarkController animated:NO];
    }
}

//收藏
- (IBAction)collectAction:(id)sender {
    if ([FLYBaseUtil checkUserLogin]) {
        FLYCollectViewController *collectController = [[FLYCollectViewController alloc]init];
        [self.navigationController pushViewController:collectController animated:NO];
    }else{
        [self showAlert:@"请先登陆用户"];
    }
    
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
