//
//  FLYBillViewController.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBillViewController.h"
#import "FLYDataService.h"
#import "FLYMemberTraceModel.h"
#import "FLYBillCell.h"


@interface FLYBillViewController ()

@end

@implementation FLYBillViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的账单";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44) pullingDelegate:self];
    self.tableView.pullingDelegate=self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestBillData];
    }else{
        [self showAlert:@"请打开网络"];
    }
}

#pragma mark - request
-(void)requestBillData{
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
    __weak FLYBillViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryBillList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadBillData:result];
    } errorBolck:^(){
        [ref loadBillError];
    }];
}



-(void)requestMoreBillData{
    //FLYMemberTraceModel
    
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
        __weak FLYBillViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadBillData:result];
        } errorBolck:^(){
            [ref loadBillError];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:@"加载完成"];
    }
}


-(void)loadBillError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

- (void)loadBillData:(id)data{
    _dataIndex = _dataIndex + 20;
    [self hideHUD];
    
    [self.tableView setReachedTheEnd:NO];
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *traces = [result objectForKey:@"traces"];
            
            if ([traces count] >= 20) {
                _isMore = YES;
            }
            
            NSMutableArray *traceList = [NSMutableArray arrayWithCapacity:traces.count];
            for (NSDictionary *traceDic in traces) {
                FLYMemberTraceModel *traceModel = [[FLYMemberTraceModel alloc] initWithDataDic:traceDic];
                [traceList addObject:traceModel];
            }
            if (self.datas == nil) {
                self.datas = traceList;
            }else{
                [self.datas addObjectsFromArray:traceList];
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
    [self performSelector:@selector(requestBillData) withObject:nil afterDelay:1.f];
}

//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(requestMoreBillData) withObject:nil afterDelay:1.f];
}

#pragma mark - Scroll
//滑动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.tableView tableViewDidScroll:scrollView];
}
//结束滑动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView tableViewDidEndDragging:scrollView];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BillCell";
    FLYBillCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYBillCell" owner:self options:nil] lastObject];
    }
    
    cell.showDate = YES;
    FLYMemberTraceModel *traceModel = [self.datas objectAtIndex:indexPath.row];
    cell.traceModel = traceModel;
    
    if (indexPath.row != 0) {
        FLYMemberTraceModel *lastTraceModel = [self.datas objectAtIndex:(indexPath.row - 1)];
        
        if ([FLYBaseUtil isNotEmpty:traceModel.mtPaydate] && [FLYBaseUtil isNotEmpty:lastTraceModel.mtPaydate]) {
            NSString *payDate = [traceModel.mtPaydate substringWithRange:NSMakeRange(0,8)];
            NSString *lastPayDate = [lastTraceModel.mtPaydate substringWithRange:NSMakeRange(0,8)];
            if ([payDate isEqualToString:lastPayDate]) {
                cell.showDate = NO;
            }
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - delegate
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}


@end
