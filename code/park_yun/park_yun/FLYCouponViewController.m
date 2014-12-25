//
//  FLYCouponViewController.m
//  park_yun
//
//  Created by chen on 14-12-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCouponViewController.h"
#import "FLYCouponCell.h"
#import "FLYCouponModel.h"
#import "FLYDataService.h"
#import "DXAlertView.h"

#define bgColor Color(239,239,239,244)

@interface FLYCouponViewController ()

@end

@implementation FLYCouponViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的红包";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = bgColor;
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"当前",@"历史",nil];
    
    //初始化UISegmentedControl
    _segment = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segment.frame = CGRectMake(60, 15 , 200, 30);
    _segment.selectedSegmentIndex = 0;//设置默认选择项索引
    _segment.tintColor= [UIColor colorWithRed:51/255.0 green:119/255.0 blue:172/255.0 alpha:1];
    [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];
    
    _curView = [[UIView alloc] initWithFrame:CGRectMake(0, _segment.bottom + 15, ScreenWidth, ScreenHeight - 44 - 80)];
    [self.view addSubview:_curView];
    
    _hisView = [[UIView alloc] initWithFrame:CGRectMake(0, _segment.bottom + 15, ScreenWidth, ScreenHeight - 44 - 80)];
    _hisView.hidden = YES;
    [self.view addSubview:_hisView];
    
    self.curTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, _curView.height)];
    self.curTableView.dataSource = self;
    self.curTableView.delegate = self;
    self.curTableView.backgroundColor = [UIColor clearColor];
    self.curTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.curTableView.tag = 101;
    [_curView addSubview:self.curTableView];
    
    self.hisTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, _curView.height)];
    self.hisTableView.dataSource = self;
    self.hisTableView.delegate = self;
    self.hisTableView.backgroundColor = [UIColor clearColor];
    self.hisTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.hisTableView.tag = 102;
    [_hisView addSubview:self.hisTableView];
    
    [self prepareRequestCouponData];
}

#pragma mark - 数据请求
-(void)prepareUseCouponData:(NSIndexPath *)index{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"使用中" isDim:NO];
        [self requestUseCoupon:index];
    }else{
        [self showTimeoutView:YES];
        [self showToast:@"请打开网络"];
    }
}

-(void)requestUseCoupon:(NSIndexPath *)index{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    FLYCouponModel *model = [self.curDatas objectAtIndex:index.row];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   model.cdId,
                                   @"cdid",
                                   nil];
    
    //防止循环引用
    __weak FLYCouponViewController *ref = self;
    [FLYDataService requestWithURL:kHttpCouponOrder params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadCouponUseData:result index:index];
    } errorBolck:^(){
        [ref loadCouponUseError];
    }];
}

-(void)loadCouponUseError{
    [self showToast:@"连接超时"];
    [self hideHUD];
}

-(void)loadCouponUseData:(id)data index:(NSIndexPath *)index{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        [self showToast:@"红包使用成功"];
        [self prepareRequestCouponData];
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


-(void)prepareRequestCouponData{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestCurCouponData];
        [self requestHisCouponData];
    }else{
        [self showTimeoutView:YES];
        [self showToast:@"请打开网络"];
    }
}

-(void)requestCurCouponData{
    self.curDatas = nil;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   @"0",
                                   @"cdFlag",
                                   @"100",
                                   @"count",
                                   nil];
    
    //防止循环引用
    __weak FLYCouponViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryCouponList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadCurCouponData:result];
    } errorBolck:^(){
        [ref loadDataError:YES];
    }];
}

-(void)requestHisCouponData{
    self.hisDatas = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   @"1",
                                   @"cdFlag",
                                   @"100",
                                   @"count",
                                   nil];
    
    //防止循环引用
    __weak FLYCouponViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryCouponList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadHisCouponData:result];
    } errorBolck:^(){
        
    }];
}

-(void)loadDataError:(BOOL)isFirst{
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (void)loadCurCouponData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *coupons = [result objectForKey:@"cdList"];
            
            
            NSMutableArray *couponList = [NSMutableArray arrayWithCapacity:coupons.count];
            for (NSDictionary *couponDic in coupons) {
                FLYCouponModel *couponModel = [[FLYCouponModel alloc] initWithDataDic:couponDic];
                [couponList addObject:couponModel];
            }

            self.curDatas = couponList;
            [self.curTableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


- (void)loadHisCouponData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *coupons = [result objectForKey:@"cdList"];
            
            NSMutableArray *couponList = [NSMutableArray arrayWithCapacity:coupons.count];
            for (NSDictionary *couponDic in coupons) {
                FLYCouponModel *couponModel = [[FLYCouponModel alloc] initWithDataDic:couponDic];
                [couponList addObject:couponModel];
            }
            self.hisDatas = couponList;
            [self.hisTableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
    
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView.tag == 101) {
        return [self.curDatas count];
    }else{
        return [self.hisDatas count];
    }
   
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 101) {
        static NSString *identifier = @"CouponCell";
        FLYCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYCouponCell" owner:self options:nil] lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.couponModel = [self.curDatas objectAtIndex:indexPath.row];
        cell.index = indexPath.row;
        return cell;
    }else{
        static NSString *identifier = @"CouponCell";
        FLYCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYCouponCell" owner:self options:nil] lastObject];
        }
        //不可选中
        cell.userInteractionEnabled = NO;
        cell.couponModel = [self.hisDatas objectAtIndex:indexPath.row];
        cell.index = indexPath.row;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FLYCouponModel *collect = [self.curDatas objectAtIndex:indexPath.row];
    if (tableView.tag == 101) {
        if([collect.EFlag isEqual:@"0"] && [collect.cdFlag isEqual:@"0"] ){
            [self prepareUseCouponData:indexPath];
        }
    }
    
}

#pragma mark - 控件事件
-(void)segmentAction:(UISegmentedControl *)segment{
    NSInteger index = segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            _curView.hidden = NO;
            _hisView.hidden = YES;
            break;
        case 1:
            _curView.hidden = YES;
            _hisView.hidden = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
