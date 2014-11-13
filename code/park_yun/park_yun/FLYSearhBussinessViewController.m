//
//  FLYSearhBussinessViewController.m
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYSearhBussinessViewController.h"
#import "FLYParkDetailViewController.h"
#import "FLYParkCell.h"
#import "FLYParkModel.h"
#import "FLYDataService.h"
#import "FLYDBUtil.h"

@interface FLYSearhBussinessViewController ()

@end

@implementation FLYSearhBussinessViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.title = @"商圈周边查询";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([FLYBaseUtil isOffline]) {
        self.title = [NSString  stringWithFormat:@"%@(离线)",self.titleName];
    }else{
        self.title = self.titleName;
    }
    
    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44) pullingDelegate:self];
    self.tableView.pullingDelegate=self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];

    [self prepareRequestParkData];
}


#pragma mark - 数据请求
- (void)prepareRequestParkData{
    if ([FLYBaseUtil isOffline]) {
        [self requestParkData];
    }else{
        if ([FLYBaseUtil isEnableInternate]) {
            [self showHUD:@"加载中" isDim:NO];
            [self requestParkData];
        }else{
            [self showTimeoutView:YES];
            [self showToast:@"请打开网络"];
        }
    }
}

//停车场位置
- (void)requestParkData{
    [self showTimeoutView:NO];
    
    //离线请求数据库
    if ([FLYBaseUtil isOffline]) {
        NSString *city = [FLYBaseUtil getCity];
        NSMutableArray *parkList = [FLYDBUtil queryParkList:self.coordinate.latitude lng:self.coordinate.longitude city:city rang:2000];
        self.datas = parkList;
        
        if (self.datas != nil && [self.datas count] > 0) {
            self.tableView.hidden = NO;
            [self showNoDataView:NO];
        }else{
            self.tableView.hidden = YES;
            [self showNoDataView:YES];
        }
        
        [self.tableView tableViewDidFinishedLoading];
        [self.tableView setReachedTheEnd:YES];
        [self.tableView reloadData];
    }else{
        _isMore = NO;
        _dataIndex = 0;
        self.datas = nil;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%f",self.coordinate.latitude],
                                       @"lat",
                                       [NSString stringWithFormat:@"%f",self.coordinate.longitude],
                                       @"long",
                                       @"2000",
                                       @"range",
                                       nil];
        
        //防止循环引用
        __weak FLYSearhBussinessViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadParkData:result];
        } errorBolck:^(){
            [ref loadParkError:YES];
        }];
    }
    
}

//加载更多停车场列表
- (void)requestMoreParkData{
    if (_isMore) {
        _isMore = NO;
        int start = _dataIndex;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%f",self.coordinate.latitude],
                                       @"lat",
                                       [NSString stringWithFormat:@"%f",self.coordinate.longitude],
                                       @"long",
                                       @"2000",
                                       @"range",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       nil];
        
        //防止循环引用
        __weak FLYSearhBussinessViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadParkData:result];
        } errorBolck:^(){
            [ref loadParkError:NO];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:nil];
    }
}


- (void)loadParkError:(BOOL)firstLoad{
    if (firstLoad) {
        [self showTimeoutView:YES];
    }
    [self hideHUD];
    [FLYBaseUtil networkError];
}

//停车场列表
- (void)loadParkData:(id)data{
    _dataIndex = _dataIndex + 20;
    //    [super showLoading:NO];
    [self hideHUD];
    
    [self.tableView setReachedTheEnd:NO];
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *parks = [result objectForKey:@"parks"];
            
            if ([parks count] >= 20) {
                _isMore = YES;
            }
            
            NSMutableArray *parkList = [NSMutableArray arrayWithCapacity:parks.count];
            for (NSDictionary *parkDic in parks) {
                FLYParkModel *photoModel = [[FLYParkModel alloc] initWithDataDic:parkDic];
                [parkList addObject:photoModel];
            }
            if (self.datas == nil) {
                self.datas = parkList;
            }else{
                [self.datas addObjectsFromArray:parkList];
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
    [self performSelector:@selector(requestParkData) withObject:nil afterDelay:1.f];
}
//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(requestMoreParkData) withObject:nil afterDelay:1.f];
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
    static NSString *identifier = @"ParkCell";
    FLYParkCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYParkCell" owner:self options:nil] lastObject];
    }
    
    cell.parkModel = [self.datas objectAtIndex:indexPath.row];
    CLLocationCoordinate2D coor = {self.coordinate.latitude,self.coordinate.longitude};
    cell.coordinate = coor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FLYParkModel *park = [self.datas objectAtIndex:indexPath.row];
    FLYParkDetailViewController *detail = [[FLYParkDetailViewController alloc] init];
    detail.parkId = park.parkId;
    [self.navigationController pushViewController:detail animated:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Override FLYBaseViewController
-(void)timeoutClickAction:(UITapGestureRecognizer*)gesture{
    [self prepareRequestParkData];
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
