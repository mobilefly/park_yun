//
//  FLYMainViewController.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMainViewController.h"
#import "FLYParkCell.h"
#import "FLYDataService.h"
#import "FLYParkDetailViewController.h"
#import "FLYBaseNavigationController.h"
#import "FLYSearchViewController.h"
#import "FLYUserCenterViewController.h"
#import "FLYShakeViewController.h"


@interface FLYMainViewController ()
@end

@implementation FLYMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
    }
    return self;
}

-(void)_init{
    _firstFlag = YES;
    _isMore = YES;
    _isFollow = NO;
    _isLocation = NO;
    _isLoading = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topView.frame = CGRectMake(0, 20, 320, 80);
    self.topView.hidden = NO;
    
    //查询按钮
    _searchField.frame = CGRectMake(75, 25, 170, 30);
    _searchField.layer.cornerRadius = 2.0f;
    _searchField.layer.masksToBounds = YES;
    _searchField.layer.borderColor = [[UIColor whiteColor]CGColor];
    _searchField.layer.borderWidth = 1.0f;
    UIColor *color = Color(255, 255, 255, 1);
    _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"周边查询" attributes:@{NSForegroundColorAttributeName: color}];

    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nearby_list_icon_disable_search.png"]];
    searchImage.backgroundColor = [UIColor whiteColor];
    
    searchImage.frame = CGRectMake(0, 0, 30, 30);
    _searchField.rightViewMode = UITextFieldViewModeAlways;
    _searchField.rightView = searchImage;
    

    ThemeButton *mapButton = [UIFactory createButtonWithBackground:@"mfpparking_ditu_all_up.png" backgroundHightlight:@"mfpparking_ditu_all_down.png"];
    mapButton.showsTouchWhenHighlighted = YES;
    mapButton.frame = CGRectMake(258, 14, 52, 52);
    [mapButton addTarget:self action:@selector(mapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:mapButton];
    
    
    ThemeButton *userInfoButton = [UIFactory createButtonWithBackground:@"mfpparking_user_all_up.png" backgroundHightlight:@"mfpparking_user_all_down.png"];
    userInfoButton.showsTouchWhenHighlighted = YES;
    userInfoButton.frame = CGRectMake(10, 14, 52, 52);
    [userInfoButton addTarget:self action:@selector(userInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:userInfoButton];
    

    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 100, ScreenWidth, ScreenHeight - 100) pullingDelegate:self];
    self.tableView.pullingDelegate=self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    

    _mapBaseView = [[FLYBaseMap alloc]initWithFrame:CGRectMake(0, 100, ScreenWidth, ScreenHeight - 100)];
    _mapBaseView.alpha = 0;
    _mapBaseView.mapDelegate = self;
    [self.view addSubview:_mapBaseView];
    
    _locationService = [[BMKLocationService alloc]init];
    
    [self setNoDataViewFrame:_mapBaseView.frame];
}

#pragma mark - request
//停车场位置
- (void)requestLocationData{
    _isReload = NO;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%f",_mapBaseView.mapView.region.center.latitude] ,
                                   @"lat",
                                   [NSString stringWithFormat:@"%f",_mapBaseView.mapView.region.center.longitude],
                                   @"long",
                                   @"10000",
                                   @"range",
                                   nil];
    
    //防止循环引用
    __weak FLYMainViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryNearbySimplifyList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadLocationData:result];
    } errorBolck:^(){
    
    }];
}

//停车场位置
- (void)requestParkData{
    
    _reloadLoaction = _curCoordinate;
    
    _isMore = NO;
    _dataIndex = 0;
    self.datas = nil;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%f",_reloadLoaction.latitude] ,
                                   @"lat",
                                   [NSString stringWithFormat:@"%f",_reloadLoaction.longitude],
                                   @"long",
                                   @"200000",
                                   @"range",
                                   nil];
    
    //防止循环引用
    __weak FLYMainViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadParkData:result];
    } errorBolck:^(){
        [ref loadParkError];
    }];
}

//加载更多停车场列表
- (void)requestMoreParkData{
    if (_isMore) {
        _isMore = NO;
        
        int start = _dataIndex;
       
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%f",_reloadLoaction.latitude],
                                       @"lat",
                                       [NSString stringWithFormat:@"%f",_reloadLoaction.longitude],
                                       @"long",
                                       @"200000",
                                       @"range",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       nil];
        
        //防止循环引用
        __weak FLYMainViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadParkData:result];
        } errorBolck:^(){
            [ref loadParkError];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:@"加载完成"];
    }
}

- (void)loadParkError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
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


#pragma mark - Action
- (void)userInfoAction:(id)sender{
    FLYUserCenterViewController *userCenterController = [[FLYUserCenterViewController alloc] init];
    
    
    [self.navigationController pushViewController:userCenterController animated:NO];
}

//切换地图
- (void)mapAction:(id)sender {
    if (_mapBaseView.alpha == 0) {
        [UIView animateWithDuration:1 animations:^{
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_tableView cache:YES];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_mapBaseView cache:YES];
            _mapBaseView.alpha = 1;
            _tableView.alpha = 0;
        }];
    }
    
    else if (_tableView.alpha == 0) {
        [UIView animateWithDuration:1 animations:^{
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_tableView cache:YES];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_mapBaseView cache:YES];
            _mapBaseView.alpha = 0;
            _tableView.alpha = 1;
        }];
    }
}

//跳转搜索页
- (IBAction)search:(id)sender {
    FLYSearchViewController *searchController = [[FLYSearchViewController alloc] init];
    searchController.searchText = self.searchField.text;
    
    FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:searchController];
    [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
    
    self.searchField.text = @"";
    [self.searchField resignFirstResponder];
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
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ParkCell";
    FLYParkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYParkCell" owner:self options:nil] lastObject];
    }

    cell.parkModel = [self.datas objectAtIndex:indexPath.row];
    cell.coordinate = _reloadLoaction;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FLYParkModel *park = [self.datas objectAtIndex:indexPath.row];
    FLYParkDetailViewController *detail = [[FLYParkDetailViewController alloc] init];
    detail.parkId = park.parkId;
    [self.navigationController pushViewController:detail animated:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    [self updateUserLocation:userLocation];
    
    if (_firstFlag == YES) {
        _firstFlag = NO;
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(kMapRange,kMapRange));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        
        
        if ([FLYBaseUtil isEnableInternate]) {
            
//            [self.tableView updateRefreshDate];
            [self requestParkData];
            [self requestLocationData];
            [self showHUD:@"加载中" isDim:NO];
        }else{
            [self showAlert:@"请打开网络"];
        }
    }
}

#pragma mark - BMKMapViewDelegate delegate
//屏幕移动
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (_isReload) {
        if (!_isLoading) {
            _isLoading = YES;
            [self requestLocationData];
        }
        return;
    }
    [super regionChange:mapView];
}

#pragma mark - 摇动手势

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion == UIEventSubtypeMotionShake){
        FLYShakeViewController *shakeCtrl = [[FLYShakeViewController alloc] init];
        shakeCtrl.curCoordinate = _curCoordinate;
        [self.navigationController pushViewController:shakeCtrl animated:NO];
    }
}


#pragma mark - view other
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_mapBaseView.mapView viewWillAppear];
    // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapBaseView.mapView.delegate = self;

    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
    
    [self becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [_mapBaseView.mapView viewWillDisappear];
    // 不用时，置nil
    _mapBaseView.mapView.delegate = nil;
    
    [_locationService stopUserLocationService];
    _locationService.delegate = nil;
}

-(void)dealloc{
    if (_mapBaseView.mapView != nil) {
        _mapBaseView.mapView = nil;
    }
    
    if (_mapBaseView != nil) {
        _mapBaseView = nil;
    }
    
    NSLog(@"%s",__FUNCTION__);
}


@end
