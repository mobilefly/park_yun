//
//  FLYCollectViewController.m
//  park_yun
//
//  Created by chen on 14-7-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCollectViewController.h"
#import "FLYDataService.h"
#import "FLYCollectModel.h"
#import "FLYCollectCell.h"
#import "FLYParkDetailViewController.h"
#import "FLYAppDelegate.h"


@interface FLYCollectViewController ()

@end

@implementation FLYCollectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的收藏";
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
    [self setExtraCellLineHidden:self.tableView];
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestCollectData];
    }else{
        [self showAlert:@"请打开网络"];
    }
}

#pragma mark - request
-(void)requestCollectData{
    _isMore = NO;
    _dataIndex = 0;
    self.datas = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   [NSString stringWithFormat:@"%f",appDelegate.coordinate.latitude],
                                   @"lat",
                                   [NSString stringWithFormat:@"%f",appDelegate.coordinate.longitude],
                                   @"lon",
                                   nil];
    
    //防止循环引用
    __weak FLYCollectViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryMemberCollectList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadCollectData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}

-(void)requestMoreCollectData{
    //FLYMemberTraceModel
    
    if (_isMore) {
        _isMore = NO;
        
        int start = _dataIndex;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults stringForKey:@"token"];
        NSString *userid = [defaults stringForKey:@"memberId"];

        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       token,
                                       @"token",
                                       userid,
                                       @"userid",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       [NSString stringWithFormat:@"%f",appDelegate.coordinate.latitude],
                                       @"lat",
                                       [NSString stringWithFormat:@"%f",appDelegate.coordinate.longitude],
                                       @"lon",
                                       nil];
        
        //防止循环引用
        __weak FLYCollectViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryMemberCollectList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadCollectData:result];
        } errorBolck:^(){
            [ref loadDataError];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:nil];
    }
}


-(void)loadDataError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

- (void)loadCollectData:(id)data{
    _dataIndex = _dataIndex + 20;
    [self hideHUD];
    [self.tableView setReachedTheEnd:NO];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *traces = [result objectForKey:@"collects"];
            
            if ([traces count] >= 20) {
                _isMore = YES;
            }
            
            NSMutableArray *traceList = [NSMutableArray arrayWithCapacity:traces.count];
            for (NSDictionary *traceDic in traces) {
                FLYCollectModel *traceModel = [[FLYCollectModel alloc] initWithDataDic:traceDic];
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
    [self performSelector:@selector(requestCollectData) withObject:nil afterDelay:1.f];
}
//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(requestMoreCollectData) withObject:nil afterDelay:1.f];
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
    if (self.datas == nil || [self.datas count] == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return [self.datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CollectCell";
    FLYCollectCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYCollectCell" owner:self options:nil] lastObject];
    }
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    
    cell.collectModel = [self.datas objectAtIndex:indexPath.row];
    cell.coordinate = appDelegate.coordinate;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FLYCollectModel *collect = [self.datas objectAtIndex:indexPath.row];
    FLYParkDetailViewController *detail = [[FLYParkDetailViewController alloc] init];
    detail.parkId = collect.park.parkId;
    [self.navigationController pushViewController:detail animated:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
