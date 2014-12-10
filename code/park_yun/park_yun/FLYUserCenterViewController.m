//
//  FLYUserCenterViewController.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYUserCenterViewController.h"
#import "FLYLoginViewController.h"
#import "FLYBaseNavigationController.h"
#import "FLYRechargeViewController.h"
#import "FLYSettingViewController.h"
#import "FLYBillViewController.h"
#import "FLYOfflineMapViewController.h"
#import "FLYFootmarkViewController.h"
#import "FLYCardParkViewController.h"
#import "FLYCollectViewController.h"
#import "FLYCarManagerViewController.h"
#import "FLYDataService.h"
#import "UIButton+Bootstrap.h"

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
    
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 55)];
    _topView.hidden = YES;
    [self.view addSubview:_topView];
    
    _carNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, 200, 20)];
    _carNoLabel.font = [UIFont systemFontOfSize:12.0];
    _carNoLabel.textColor = [UIColor grayColor];
    [_topView addSubview:_carNoLabel];
    
    _balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 28, 200, 20)];
    _balanceLabel.font = [UIFont systemFontOfSize:12.0];
    _balanceLabel.textColor = [UIColor grayColor];
    [_topView addSubview:_balanceLabel];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.hidden = YES;
    [_spinner setCenter:CGPointMake(90, 40)];
    [_topView addSubview:_spinner];

    _carBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _carBtn.frame = CGRectMake((ScreenWidth - 100), (_topView.height - 35) / 2, 80, 35);
    [_carBtn primaryStyle];
    _carBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_carBtn setTitle:@"车辆管理" forState:UIControlStateNormal];
    [_carBtn addTarget:self action:@selector(carManagerAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_carBtn];
    
    //分割线
    UIView *sep = [[UIView alloc] init];
    sep.frame = CGRectMake(0, _topView.bottom - 1, 320, 1);
    sep.backgroundColor =  Color(242, 241, 244, 1);
    [_topView addSubview:sep];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BOOL flag = false;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIButton *loginBtn = (UIButton *)[self.view viewWithTag:101];
    if (loginBtn != nil) {
        //已登陆
        if ([FLYBaseUtil checkUserLogin]) {
            NSString *username = [defaults stringForKey:@"memberName"];
            [loginBtn warningStyle];
            
            
            NSString *str = [NSString stringWithFormat:@"注销（%@）",[FLYBaseUtil isEmpty:username] ? @"会员":username];
            [loginBtn setTitle:str forState:UIControlStateNormal];
            
            flag = YES;
        }
        //未登陆
        else{
            [loginBtn primaryStyle];
            [loginBtn setTitle:@"会员登陆" forState:UIControlStateNormal];
        }
    }
    
    if (flag) {
        //如果绑定了车牌
        if ([FLYBaseUtil checkUserBindCar]) {
            NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
            _carNoLabel.text = [NSString  stringWithFormat:@"默认车牌：%@",memberCarno];
        }else{
            _carNoLabel.text = @"默认车牌：未绑定";
        }
        
        _balanceLabel.text = [NSString  stringWithFormat:@"账户余额："];
        _middleView.top = 56;
        _topView.hidden = NO;
        [self requestBalance];
    }else{
        _topView.hidden = YES;
        _carNoLabel.text = @"";
        _middleView.top = 0;
    }
}

#pragma mark - 数据请求
- (void)requestBalance{
    _spinner.hidden = NO;
    [_spinner startAnimating];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *memberId = [defaults stringForKey:@"memberId"];
    NSString *token = [defaults stringForKey:@"token"];

    
    if ([FLYBaseUtil isEnableInternate]) {
        if ([FLYBaseUtil isNotEmpty:memberId]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           memberId,
                                           @"userid",
                                           token,
                                           @"token",
                                           nil];
            
            //防止循环引用
            __weak FLYUserCenterViewController *ref = self;
            [FLYDataService requestWithURL:kHttpQueryBalance params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadBalanceData:result];
            } errorBolck:^(){
                
            }];
        }
    }else{
        [self showToast:@"请打开网络"];
    }
}

- (void)loadBalanceData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSNumber *balance = [result objectForKey:@"balance"];
            _balanceLabel.text = [NSString stringWithFormat:@"账户余额：%.2f元",[balance doubleValue] / 100];
            
            [_spinner stopAnimating];
            _spinner.hidden = YES;
        }
    }
}

//注销
- (void)requestLogout:(NSString *)token memberId:(NSString *)memberId{
    if ([FLYBaseUtil isNotEmpty:token]) {
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:token forKey:@"token" ];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       token,
                                       @"token",
                                       memberId,
                                       @"userId",
                                       nil];
        
        [FLYDataService requestWithURL:kHttpLogout params:params httpMethod:@"POST" completeBolck:^(id result){
        } errorBolck:^(){
            
        }];
    }
}

#pragma mark - 控件事件
- (void)carManagerAction:(UIButton *)button{
    FLYCarManagerViewController *carManagerCtrl = [[FLYCarManagerViewController alloc] init];
    [self.navigationController pushViewController:carManagerCtrl animated:NO];
}

//用户登陆注销
-(void)loginAction:(UIButton *)button{
    //注销用户
    if ([FLYBaseUtil checkUserLogin]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults stringForKey:@"token"];
        NSString *memberId = [defaults stringForKey:@"memberId"];
        
        [FLYBaseUtil clearUserInfo];
        [button primaryStyle];
        [button setTitle:@"会员登陆" forState:UIControlStateNormal];
        
        //隐藏车牌
        _topView.hidden = YES;
        _carNoLabel.text = @"";
        _balanceLabel.text = @"";
        _middleView.top = 0;
        
        [self requestLogout:token memberId:memberId];

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


#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
