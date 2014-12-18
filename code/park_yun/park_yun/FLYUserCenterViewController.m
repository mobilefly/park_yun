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
#import "FLYParkCardViewController.h"
#import "FLYCollectViewController.h"
#import "FLYCarManagerViewController.h"
#import "FLYCouponViewController.h"
#import "FLYMessageViewController.h"
#import "FLYCardParkViewController.h"
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
    
    self.scroolView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44);

    //设备页面按钮
    UIButton *settingBtn = [UIFactory createButton:@"mfpparking_shezhi_all_up.png" hightlight:@"mfpparking_shezhi_all_down.png"];
    settingBtn.showsTouchWhenHighlighted = YES;
    settingBtn.frame = CGRectMake(0, 0, 30, 30);
    [settingBtn addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItem = settingItem;
    
    //顶部会员，车牌信息，绑定畅停卡功能等
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 55)];
    _topView.hidden = YES;
    [self.scroolView addSubview:_topView];
    
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
    
    // 登陆按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake((ScreenWidth - 260) / 2, 0 , 260, 40);
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    if ([FLYBaseUtil checkUserLogin]) {
        [loginBtn warningStyle];
        [loginBtn setTitle:@"退出登陆" forState:UIControlStateNormal];
    }else{
        [loginBtn primaryStyle];
        [loginBtn setTitle:@"用户登陆" forState:UIControlStateNormal];
    }
    loginBtn.tag = 101;
    [loginBtn addAwesomeIcon:FAIconUser beforeTitle:YES];
    [loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.scroolView addSubview:loginBtn];
    
    //更多选项TableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44 * 3) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.scroolView addSubview:_tableView];
    [self setExtraCellLineHidden:_tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BOOL flag = false;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UIButton *loginBtn = (UIButton *)[self.view viewWithTag:101];
    if (loginBtn != nil) {
        //已登陆
        if ([FLYBaseUtil checkUserLogin]) {
            [loginBtn warningStyle];
            [loginBtn setTitle:@"退出登陆" forState:UIControlStateNormal];
            
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
        _topView.hidden = NO;
        _middleView.top = 56;
        _tableView.top = _middleView.bottom;
        loginBtn.top = _tableView.bottom + 20;
        
        [self requestBalance];
        [self requestMessageUnread];
        [self requestCouponUnuse];
        
        [self.scroolView setContentSize:CGSizeMake(ScreenWidth, _topView.height + _middleView.height + loginBtn.height + _tableView.height + 60)];
        
    }else{
        _topView.hidden = YES;
        _carNoLabel.text = @"";
        _middleView.top = 0;
        _tableView.top = _middleView.bottom;
        loginBtn.top = _tableView.bottom + 20;
        
        [self.scroolView setContentSize:CGSizeMake(ScreenWidth, _middleView.height + _tableView.height + loginBtn.height + 60)];
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

- (void)requestMessageUnread{
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
            [FLYDataService requestWithURL:kHttpQueryMessageUnread params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadMessageUnreadData:result];
            } errorBolck:^(){
                
            }];
        }
    }
}

- (void)loadMessageUnreadData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSNumber *msgNum = [result objectForKey:@"num"];
            NSString *msg;
            if([msgNum integerValue] > 99){
                msg = @"99";
            }else{
                msg = [NSString stringWithFormat:@"%i",[msgNum integerValue]];
            }
            [msgBadgeBtn setTitle:msg forState:UIControlStateNormal];
        }
    }
}

- (void)requestCouponUnuse{
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
            [FLYDataService requestWithURL:kHttpQueryCouponUnuse params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadCouponUnuseData:result];
            } errorBolck:^(){
                
            }];
        }
    }
}

- (void)loadCouponUnuseData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSNumber *msgNum = [result objectForKey:@"count"];
            NSString *msg;
            if([msgNum integerValue] > 99){
                msg = @"99";
            }else{
                msg = [NSString stringWithFormat:@"%i",[msgNum integerValue]];
            }
            [couponBadgeBtn setTitle:msg forState:UIControlStateNormal];
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
    if ([self checkUserLogin]) {
        UIActionSheet *logoutSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登陆" otherButtonTitles:nil, nil];
        [logoutSheet showInView:self.view];
    }
}

-(void)settingAction:(UIButton *)button{
    FLYSettingViewController *settingController = [[FLYSettingViewController alloc]init];
    [self.navigationController pushViewController:settingController animated:NO];
}

//账单
- (IBAction)billAction:(id)sender {
    if ([self checkUserLogin]) {
        FLYBillViewController *billController = [[FLYBillViewController alloc]init];
        [self.navigationController pushViewController:billController animated:NO];
    }
}

//会员卡信息
- (IBAction)memberInfoAction:(id)sender {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *memberType = [defaults stringForKey:@"memberType"];
    
    if ([self checkUserLogin]) {
        if(![memberType isEqualToString:@"3"]){
            [self showAlert:@"未绑定畅停卡,请先购买畅停卡"];
        }else{
            FLYCardParkViewController *cardParkController = [[FLYCardParkViewController alloc]init];
            [self.navigationController pushViewController:cardParkController animated:NO];
        }
    }
    
}

//账户充值
- (IBAction)rechargeAction:(id)sender {
    if ([self checkUserLogin]) {
        FLYRechargeViewController *rechargeController = [[FLYRechargeViewController alloc]init];
        [self.navigationController pushViewController:rechargeController animated:NO];
    }
}

//足迹
- (IBAction)footmarkAction:(id)sender {
    if ([self checkUserLogin]) {
        if(![FLYBaseUtil checkUserBindCar]){
            [self showAlert:@"未绑定任何车牌\n请先去车辆管理绑定车牌"];
        }else{
            FLYFootmarkViewController *footmarkController = [[FLYFootmarkViewController alloc]init];
            [self.navigationController pushViewController:footmarkController animated:NO];
        }
    }
}

//收藏
- (IBAction)collectAction:(id)sender {
    if ([self checkUserLogin]) {
        FLYCollectViewController *collectController = [[FLYCollectViewController alloc]init];
        [self.navigationController pushViewController:collectController animated:NO];
    }
}

//离线地图
- (IBAction)offlineMapAction:(id)sender {
    FLYOfflineMapViewController *mapController = [[FLYOfflineMapViewController alloc]init];
    [self.navigationController pushViewController:mapController animated:NO];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MoreCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
    
//    if(indexPath.row == 0){
//        cell.imageView.image = [UIImage imageNamed:@"icon_member.png"];
//        cell.textLabel.text = @"个人信息";
//    }else
    
    if(indexPath.row == 0){
        cell.imageView.image = [UIImage imageNamed:@"icon_message.png"];
        cell.textLabel.text = @"消息中心";
        
        //未读消息数
        UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(245, 11, 30, 20)];
        msgBadgeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        [msgBadgeBtn setBackgroundImage:[UIImage imageNamed:@"icon_badge.png"] forState:UIControlStateNormal];
        [msgBadgeBtn setTitle:@"0" forState:UIControlStateNormal];
        msgBadgeBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [msgBadgeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [badgeView addSubview:msgBadgeBtn];
        [cell.contentView addSubview:badgeView];
        
        
    }else if(indexPath.row == 1){
        cell.imageView.image = [UIImage imageNamed:@"icon_coupon.png"];
        cell.textLabel.text = @"我的红包";
        
        //未使用红包数
        UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(245, 11, 30, 20)];
        couponBadgeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        [couponBadgeBtn setBackgroundImage:[UIImage imageNamed:@"icon_badge.png"] forState:UIControlStateNormal];
        [couponBadgeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [couponBadgeBtn setTitle:@"0" forState:UIControlStateNormal];
        couponBadgeBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [badgeView addSubview:couponBadgeBtn];
        [cell.contentView addSubview:badgeView];

    }else if(indexPath.row == 2){
        cell.imageView.image = [UIImage imageNamed:@"icon_membercard.png"];
        cell.textLabel.text = @"购买畅停卡";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0) {
//        [self showAlert:@"敬请期待"];
//    }else
    if(indexPath.row == 0){
        if ([self checkUserLogin]) {
            FLYMessageViewController *messageController = [[FLYMessageViewController alloc] init];
            [self.navigationController pushViewController:messageController animated:NO];
        }
    }else if(indexPath.row == 1){
        if ([self checkUserLogin]) {
            FLYCouponViewController *couponController = [[FLYCouponViewController alloc] init];
            [self.navigationController pushViewController:couponController animated:NO];
        }
    }else if(indexPath.row == 2){
        if ([self checkUserLogin]) {
            FLYParkCardViewController *parkCardController = [[FLYParkCardViewController alloc] init];
            [self.navigationController pushViewController:parkCardController animated:NO];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UIActionSheetDelegate delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [self loginOut];
    }
    //取消
    else if (buttonIndex == 1){
        return;
    }
    
}

#pragma mark - util
- (void)toLogin{
    FLYLoginViewController *loginController = [[FLYLoginViewController alloc] init];
    FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:loginController];
    [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
}

- (void)loginOut{
    //注销
    UIButton *loginBtn = (UIButton *)[self.view viewWithTag:101];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *memberId = [defaults stringForKey:@"memberId"];
    
    [FLYBaseUtil clearUserInfo];
    [loginBtn primaryStyle];
    [loginBtn setTitle:@"用户登陆" forState:UIControlStateNormal];
    
    //隐藏车牌
    _topView.hidden = YES;
    _carNoLabel.text = @"";
    _balanceLabel.text = @"";
    _middleView.top = 0;
    _tableView.top = _middleView.bottom;
    loginBtn.top = _tableView.bottom + 20;
    
    [self requestLogout:token memberId:memberId];
    [self.scroolView setContentSize:CGSizeMake(ScreenWidth, _middleView.height + loginBtn.height + _tableView.height + 60)];
}

- (BOOL)checkUserLogin{
    if ([FLYBaseUtil checkUserLogin]) {
        return true;
    }else{
        [self toLogin];
        return false;
    }
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
