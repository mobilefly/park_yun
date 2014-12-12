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
    
    //设置导航栏背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_hongbao_bg_c.png"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"img_hongbao_bg.png"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    
    //返回事件
    self.ctrlDelegate = self;
    
    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 50, ScreenWidth, ScreenHeight - 20 - 44 - 50) pullingDelegate:self];
    self.tableView.pullingDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    [self prepareRequestCouponData];
}

#pragma mark - 数据请求
-(void)prepareRequestCouponData{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestCouponData];
    }else{
        [self showTimeoutView:YES];
        [self showToast:@"请打开网络"];
    }
}

-(void)prepareRequestUserCoupon:(NSIndexPath *)index{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"请求中" isDim:NO];
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
    FLYCouponModel *model = [self.datas objectAtIndex:index.row];
    
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
    [self.tableView setReachedTheEnd:NO];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        
        FLYCouponModel *model = [self.datas objectAtIndex:index.row];
        model.cdFlag = @"1";
        
        FLYCouponCell *cell = (FLYCouponCell *)[self.tableView cellForRowAtIndexPath:index];
        cell.couponModel = model;
        
        //刷新
        NSArray *indexArray = [NSArray arrayWithObject:index];
        [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];

        [self showToast:@"红包使用成功"];
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


-(void)requestCouponData{
    _isMore = NO;
    _dataIndex = 0;
    self.datas = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   nil];
    
    //防止循环引用
    __weak FLYCouponViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryCouponList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadCouponData:result];
    } errorBolck:^(){
        [ref loadDataError:YES];
    }];
}

-(void)requestMoreCouponData{
    if (_isMore) {
        _isMore = NO;
        
        int start = _dataIndex;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults stringForKey:@"token"];
        NSString *userid = [defaults stringForKey:@"memberId"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       token,
                                       @"token",
                                       userid,
                                       @"userid",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       nil];
        
        //防止循环引用
        __weak FLYCouponViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryCouponList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadCouponData:result];
        } errorBolck:^(){
            [ref loadDataError:NO];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:nil];
    }
}

-(void)loadDataError:(BOOL)isFirst{
    if (isFirst) {
        [self showTimeoutView:YES];
    }
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (void)loadCouponData:(id)data{
    _dataIndex = _dataIndex + 20;
    [self hideHUD];
    [self.tableView setReachedTheEnd:NO];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *coupons = [result objectForKey:@"cdList"];
            
            if ([coupons count] >= 20) {
                _isMore = YES;
            }
            
            NSMutableArray *couponList = [NSMutableArray arrayWithCapacity:coupons.count];
            for (NSDictionary *couponDic in coupons) {
                FLYCouponModel *couponModel = [[FLYCouponModel alloc] initWithDataDic:couponDic];
                [couponList addObject:couponModel];
            }
            if (self.datas == nil) {
                self.datas = couponList;
            }else{
                [self.datas addObjectsFromArray:couponList];
            }
            
            if (self.datas != nil && [self.datas count] > 0) {
                self.tableView.hidden = NO;
                [self showNoDataView:NO];
            }else{
                self.tableView.hidden = YES;
                [self showNoDataView:YES];
            }
            [self.tableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
    
    
    [self.tableView tableViewDidFinishedLoading];
    
    if (!_isMore && self.datas != nil && [self.datas count] > 0) {
        [self.tableView setReachedTheEnd:YES];
        [super showMessage:@"加载完成"];
    }
}




#pragma mark - PullingRefreshTableViewDelegate
//下拉开始
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(requestCouponData) withObject:nil afterDelay:1.f];
}
//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(requestMoreCouponData) withObject:nil afterDelay:1.f];
}

//滑动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.tableView tableViewDidScroll:scrollView];
}
//结束滑动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView tableViewDidEndDragging:scrollView];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datas == nil || [self.datas count] == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return [self.datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CouponCell";
    FLYCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYCouponCell" owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.couponModel = [self.datas objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FLYCouponModel *collect = [self.datas objectAtIndex:indexPath.row];
    if([collect.EFlag isEqual:@"0"] && [collect.cdFlag isEqual:@"0"] ){
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"是否使用红包" leftButtonTitle:@"确认" rightButtonTitle:@"取消"];
        [alert show];
        
        alert.leftBlock = ^(){
            [self prepareRequestUserCoupon:indexPath];
        };
        alert.rightBlock = ^() {
            
        };
        alert.dismissBlock = ^() {
            
        };
    }
}

#pragma mark - Override FLYBaseViewController
-(void)timeoutClickAction:(UITapGestureRecognizer*)gesture{
    [self prepareRequestCouponData];
}


#pragma mark  - FLYBaseCtrlDelegate delegate
- (BOOL)close{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_background.png"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    return YES;
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
