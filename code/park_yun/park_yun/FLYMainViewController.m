//
//  FLYMainViewController.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMainViewController.h"
#import "FLYParkDetailViewController.h"
#import "FLYBaseNavigationController.h"
#import "FLYSearchViewController.h"
#import "FLYUserCenterViewController.h"
#import "FLYShakeViewController.h"
#import "FLYParkCell.h"
#import "FLYRegionParkModel.h"
#import "FLYParseRegionXml.h"
#import "FLYParseBussinessXml.h"
#import "FLYDataService.h"
#import "DXAlertView.h"
#import "FLYDBUtil.h"
#import "UIFactory.h"
#import "FLYAppDelegate.h"



#define kTopHeight 60


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
    _firstLocation = YES;
    _isMore = YES;
    _isMapFollow = NO;
    _isMapLocation = NO;
    _isLoading = NO;
    _isLoadRegion = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //加载区域数据到数据库
    [self parseRegionData];
    //加载商圈数据到数据库
    [self parseBussinessData];
    
    self.topView.frame = CGRectMake(0, 20, 320, kTopHeight);
    self.topView.hidden = NO;
    
    UIButton *mapButton = [[UIButton alloc] initWithFrame:CGRectMake(20, (kTopHeight - 32)/2, 97, 32)];
    [mapButton setImage:[UIImage imageNamed:@"mfpparking_shouyedituxs_all_up.png"] forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(mapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:mapButton];
    
    ThemeButton *navButton = [UIFactory createButton:@"mfpparking_shouyejia_all_up.png" hightlight:@"mfpparking_shouyejia_all_down.png"];
    navButton.showsTouchWhenHighlighted = YES;
    navButton.frame = CGRectMake(ScreenWidth - 10 - 32, (kTopHeight - 32)/2, 32, 32);
    [navButton addTarget:self action:@selector(navAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:navButton];
    
    ThemeButton *searchButton = [UIFactory createButton:@"mfpparking_shouyesearch_all_up.png" hightlight:@"mfpparking_shouyesearch_all_down.png"];
    searchButton.showsTouchWhenHighlighted = YES;
    searchButton.frame = CGRectMake(navButton.left - 10 - 32, (kTopHeight - 32)/2, 32, 32);
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:searchButton];
    
    ThemeButton *userButton = [UIFactory createButton:@"mfpparking_shouyeuser_all_up.png" hightlight:@"mfpparking_shouyeuser_all_down.png"];
    userButton.showsTouchWhenHighlighted = YES;
    userButton.frame = CGRectMake(searchButton.left - 10 - 32, (kTopHeight - 32)/2, 32, 32);
    [userButton addTarget:self action:@selector(userInfoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:userButton];
    
    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 20 + kTopHeight, ScreenWidth, ScreenHeight - 20 - kTopHeight) pullingDelegate:self];
    self.tableView.pullingDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    _mapBaseView = [[FLYBaseMap alloc]initWithFrame:CGRectMake(0, 20 + kTopHeight, ScreenWidth, ScreenHeight - 20 - kTopHeight)];
    _mapBaseView.alpha = 0;
    _mapBaseView.mapDelegate = self;
    [self.view addSubview:_mapBaseView];
    
    //定位
    _locationService = [[BMKLocationService alloc]init];
    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
    
    _codeSearcher = [[BMKGeoCodeSearch alloc]init];
    _codeSearcher.delegate = self;
    
    [self setBackgroupViewFrame:_mapBaseView.frame];
    
}

#pragma mark - request
//停车场位置
- (void)requestParkData{
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    _reloadLoaction = appDelegate.coordinate;

    //离线请求数据库
    if ([FLYBaseUtil isOffline]) {
        NSString *city = [FLYBaseUtil getCity];
        
        NSMutableArray *parkList = [FLYDBUtil queryParkList:_reloadLoaction.latitude lng:_reloadLoaction.longitude city:city];
        
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
        [self hideHUD];

    }
    //请求服务器
    else{
        _isMore = NO;
        _dataIndex = 0;
        self.datas = nil;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%f",_reloadLoaction.latitude] ,
                                       @"lat",
                                       [NSString stringWithFormat:@"%f",_reloadLoaction.longitude],
                                       @"long",
                                       @"20000",
                                       @"range",
                                       nil];
        
        //防止循环引用
        __weak FLYMainViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref showTimeoutView:NO];
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
                                       [NSString stringWithFormat:@"%f",_reloadLoaction.latitude],
                                       @"lat",
                                       [NSString stringWithFormat:@"%f",_reloadLoaction.longitude],
                                       @"long",
                                       @"20000",
                                       @"range",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       nil];
        
        //防止循环引用
        __weak FLYMainViewController *ref = self;
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
    [self hideHUD];
    
    if (firstLoad) {
        [self showTimeoutView:YES];
    }else{
        [FLYBaseUtil alertErrorMsg];
    }
    
}

//停车场列表
- (void)loadParkData:(id)data{
    _dataIndex = _dataIndex + 20;
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


- (void)requestCityData:(NSString *)cityName{
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([FLYBaseUtil isOffline]) {
        NSString *city = [FLYBaseUtil getCity];
        appDelegate.cityDatas = [FLYDBUtil queryCityList:city];
    }else{
        _isLoadRegion = YES;
        if ([FLYBaseUtil isEnableInternate]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           cityName,
                                           @"cityName",
                                           nil];
            
            //防止循环引用
            __weak FLYMainViewController *ref = self;
            [FLYDataService requestWithURL:kHttpQueryParkByCityNameList params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadParkCityData:result];
            } errorBolck:^(){
                [ref loadParkCityError];
            }];
        }
    }
}

- (void)loadParkCityError{
    _isLoadRegion = NO;
}

- (void)loadParkCityData:(id)data{
     _isLoadRegion = NO;
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *regions = [result objectForKey:@"regions"];
            
            NSMutableArray *regionList = [NSMutableArray arrayWithCapacity:regions.count];
            for (NSDictionary *regionsDic in regions) {
                FLYRegionParkModel *regionModel = [[FLYRegionParkModel alloc] initWithDataDic:regionsDic];
                [regionList addObject:regionModel];
            }
            
            FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.cityDatas = regionList;
        }
    }
}

#pragma mark - Action
- (void)userInfoAction{
    FLYUserCenterViewController *userCenterController = [[FLYUserCenterViewController alloc] init];
    [self.navigationController pushViewController:userCenterController animated:NO];
}

//切换地图
- (void)mapAction:(UIButton *)button{
    if (_mapBaseView.alpha == 0) {
        [UIView animateWithDuration:1 animations:^{
            
            [button setImage:[UIImage imageNamed:@"mfpparking_shouyeliebiao_all_up.png"] forState:UIControlStateNormal];
            
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_tableView cache:YES];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_mapBaseView cache:YES];
            _mapBaseView.alpha = 1;
            _tableView.alpha = 0;
        }];
    }
    
    else if (_tableView.alpha == 0) {
        
        [button setImage:[UIImage imageNamed:@"mfpparking_shouyedituxs_all_up.png"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:1 animations:^{
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:_tableView cache:YES];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:_mapBaseView cache:YES];
            _mapBaseView.alpha = 0;
            _tableView.alpha = 1;
        }];
    }
}

//跳转搜索页
- (void)searchAction{
    FLYSearchViewController *searchController = [[FLYSearchViewController alloc] init];
    FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:searchController];
    [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
}

-(void)navAction{
    FLYShakeViewController *shakeCtrl = [[FLYShakeViewController alloc] init];
    [self.navigationController pushViewController:shakeCtrl animated:NO];
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
    static NSString *identifier = @"ParkCell";
    FLYParkCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
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
    //反查城市
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.coordinate = userLocation.location.coordinate;
    
    if (_firstLocation == YES) {
        //反查当前城市
        [self reverseGeo];
        //第一次定位标示
        _firstLocation = NO;
        
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(kMapRange,kMapRange));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        
        [self preRequestParkData];
    }
}

-(void)preRequestParkData{
    //离线
    if ([FLYBaseUtil isOffline]) {
        [self requestParkData];
    }
    //在线
    else{
        if ([FLYBaseUtil isEnableInternate]) {
            [self showHUD:@"加载中" isDim:NO];
            [self requestParkData];
            [self requestLocationData];
        }else{
            //提示离线浏览
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"当前网络未打开\n是否切换离线版本" leftButtonTitle:@"取消" rightButtonTitle:@"确认"];
            [alert show];
            
            alert.rightBlock = ^() {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"YES" forKey:@"offline"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self requestParkData];
            };
            
            alert.dismissBlock = ^(){
                [self showTimeoutView:YES];
            };
        }
    }
}

//更新用户位置
-(void)updateUserLocation:(BMKUserLocation *)userLocation{
    //跟随、定位
    if (_isMapFollow) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(kMapRange,kMapRange));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        
    }else if(_isMapLocation){
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(kMapRange,kMapRange));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        _isMapLocation = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kMapLocationNotification object:userLocation];
    [_mapBaseView.mapView updateLocationData:userLocation];
}

#pragma mark - BMKGeoCodeSearchDelegate delegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSString *city = result.addressDetail.city;
        //缓存当前城市
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.city = city;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:city forKey:@"city"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (!_isLoadRegion && appDelegate.cityDatas == nil) {
            [self requestCityData:city];
        }
    }
    else {
        //[self showAlert:@"抱歉，未找到结果"];
    }
}

- (void)reverseGeo{
    //离线浏览并且没开网络
    if (![FLYBaseUtil isEnableInternate] && [FLYBaseUtil isOffline]) {
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *city = [FLYBaseUtil getCity];
        if (!_isLoadRegion && appDelegate.cityDatas == nil) {
            [self requestCityData:city];
        }
    }else{
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        //发起反向地理编码检索
        BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
        reverseGeoCodeSearchOption.reverseGeoPoint = appDelegate.coordinate;
        BOOL flag = [_codeSearcher reverseGeoCode:reverseGeoCodeSearchOption];
        if(flag)
        {
            NSLog(@"反geo检索发送成功");
        }
        else
        {
            NSLog(@"反geo检索发送失败");
        }
    }
}

#pragma mark - BMKMapViewDelegate delegate
//屏幕移动
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (_isReload) {
        if (!_isLoading) {
            _isLoading = YES;
            
            if ([FLYBaseUtil isOffline]) {
                [self requestLocationData];
            }else{
                if ([FLYBaseUtil isEnableInternate]) {
                    [self requestLocationData];
                }
            }
            
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
        [self navAction];
    }
}

#pragma mark - parseXml
- (void)parseRegionData{
    if (![FLYDBUtil checkRegionTable]) {
        FLYParseRegionXml *regionParse = [[FLYParseRegionXml alloc] init];
        [FLYDBUtil batchSaveRegion:[regionParse parseRegionData]];
    }
}

- (void)parseBussinessData{
    if (![FLYDBUtil checkBussinessTable]) {
        FLYParseBussinessXml *bussinessParse = [[FLYParseBussinessXml alloc] init];
        [FLYDBUtil batchSaveBussiness:[bussinessParse parseBussinessData]];
    }
}

#pragma mark - super
-(void)noDataClickAction:(UITapGestureRecognizer*)gesture{
    [self preRequestParkData];
}

-(void)timeoutClickAction:(UITapGestureRecognizer*)gesture{
    [self preRequestParkData];
}


#pragma mark - view other
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_mapBaseView.mapView viewWillAppear];
    // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapBaseView.mapView.delegate = self;
    
    [self becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [_mapBaseView.mapView viewWillDisappear];
    // 不用时，置nil
    _mapBaseView.mapView.delegate = nil;
    
//    _codeSearcher.delegate = nil;
}

-(void)dealloc{
    if (_mapBaseView.mapView != nil) {
        _mapBaseView.mapView = nil;
    }
    
    if (_mapBaseView != nil) {
        _mapBaseView = nil;
    }
    
    if (_codeSearcher != nil) {
        _codeSearcher = nil;
    }
    
    NSLog(@"%s",__FUNCTION__);
}


@end
