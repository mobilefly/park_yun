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
#import "FLYParkModel.h"
#import "FLYParkDetailViewController.h"
#import "FLYBaseNavigationController.h"
#import "FLYSearchViewController.h"
#import "FLYPointAnnotation.h"

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
    
//    _searchField.text = @"";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //查询按钮
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
    mapButton.frame = CGRectMake(248, 14, 52, 52);
    [mapButton addTarget:self action:@selector(mapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:mapButton];
    
    
    ThemeButton *userInfoButton = [UIFactory createButtonWithBackground:@"mfpparking_user_all_up.png" backgroundHightlight:@"mfpparking_user_all_down.png"];
    userInfoButton.showsTouchWhenHighlighted = YES;
    userInfoButton.frame = CGRectMake(10, 14, 52, 52);
    [userInfoButton addTarget:self action:@selector(userInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:userInfoButton];
    

    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 80 + 20, ScreenWidth, ScreenHeight - 100) pullingDelegate:self];
    self.tableView.pullingDelegate=self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
   
    
    
    _mapBaseView = [[FLYBaseMap alloc]initWithFrame:CGRectMake(0, 80 + 20, ScreenWidth, ScreenHeight - 100)];

    _mapBaseView.alpha = 0;

    _mapBaseView.mapDelegate = self;
    [self.view addSubview:_mapBaseView];

    
}

#pragma mark - request
//停车场位置
- (void)requestLocationData{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [_lat stringValue] ,
                                   @"lat",
                                   [_lon stringValue],
                                   @"long",
                                   @"200000",
                                   @"range",
                                   nil];
    
    //防止循环引用
    __unsafe_unretained FLYMainViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryNearbySimplifyList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadLocationData:result];
    }];
}

//停车场位置
- (void)loadLocationData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *parks = [result objectForKey:@"parks"];
            
            
            NSMutableArray *parkList = [NSMutableArray arrayWithCapacity:parks.count];
            for (NSDictionary *parkDic in parks) {
                FLYParkModel *photoModel = [[FLYParkModel alloc] initWithDataDic:parkDic];
                [parkList addObject:photoModel];
            }
            if (self.locationDatas == nil) {
                self.locationDatas = parkList;
            }else{
                [self.locationDatas addObjectsFromArray:parkList];
            }
        }
    }
}

//停车场位置
- (void)requestParkData{

    _isMore = NO;
    _dataIndex = 0;
    self.datas = nil;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [_lat stringValue] ,
                                   @"lat",
                                   [_lon stringValue],
                                   @"long",
                                   @"200000",
                                   @"range",
                                   nil];
    
    //防止循环引用
    __unsafe_unretained FLYMainViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadParkData:result];
    }];
}

//加载更多停车场列表
- (void)requestMoreParkData{
    if (_isMore) {
        _isMore = NO;
        
        int start = _dataIndex;
       
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [_lat stringValue] ,
                                       @"lat",
                                       [_lon stringValue],
                                       @"long",
                                       @"200000",
                                       @"range",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       nil];
        
        //防止循环引用
        __unsafe_unretained FLYMainViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadParkData:result];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:@"加载完成"];

    }
}

//停车场列表
- (void)loadParkData:(id)data{
    _dataIndex = _dataIndex + 20;
//    [super showLoading:NO];
    [self hideHUD];
    
    [self.tableView setReachedTheEnd:NO];
    self.tableView.hidden = NO;
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
            [self.tableView reloadData];
        }
    }
    [self.tableView tableViewDidFinishedLoading];

    if (!_isMore) {
        [self.tableView setReachedTheEnd:YES];
        [super showMessage:@"加载完成"];
    }
}


#pragma mark - Action
- (void)userInfoAction:(id)sender{

}


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

- (IBAction)search:(id)sender {
    FLYSearchViewController *searchController = [[FLYSearchViewController alloc] init];
    searchController.searchText = self.searchField.text;
    
    FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:searchController];
    [self.view.viewController presentViewController:baseNav animated:YES completion:nil];
    
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
    return [self.datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ParkCell";
    FLYParkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYParkCell" owner:self options:nil] lastObject];
    }

    cell.parkModel = [self.datas objectAtIndex:indexPath.row];
    cell.lat = _lat;
    cell.lon = _lon;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    FLYParkModel *park = [self.datas objectAtIndex:indexPath.row];
    FLYParkDetailViewController *detail = [[FLYParkDetailViewController alloc] init];
    detail.parkModel = park;
//    [self.viewController.navigationController pushViewController:detail animated:YES];
    [self.navigationController pushViewController:detail animated:NO];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    
    _lat = [NSNumber numberWithDouble:userLocation.location.coordinate.latitude];
    _lon = [NSNumber numberWithDouble:userLocation.location.coordinate.longitude];
    if (_firstFlag == YES) {
        [self requestParkData];
        [self requestLocationData];
        
        [self showHUD:@"搜索中" isDim:NO];
        _firstFlag = NO;
        
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        
        
    }
    
    //跟随、定位
    if (_isFollow) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        
    }else if(_isLocation){
        
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        _isLocation = NO;
        
    }

    [_mapBaseView.mapView updateLocationData:userLocation];
}

#pragma mark - BMKMapViewDelegate delegate
//屏幕移动
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (mapView.zoomLevel < 15.5) {
        return;
    }
    
    double curLat = mapView.region.center.latitude;
    double curLon = mapView.region.center.longitude;
    
    if (lastLat == 0.0 || lastLon == 0.0) {
        lastLat = curLat;
        lastLon = curLon;
    }else{
        
        BMKMapPoint point1 = BMKMapPointForCoordinate(mapView.region.center);
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lastLat,lastLon));
        
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        if (distance < 2500) {
            return;
        }
        lastLat = curLat;
        lastLon = curLon;
    }
    
    
    for (FLYParkModel *park in self.locationDatas) {
        double parkLat = [park.parkLat doubleValue];
        double parkLng = [park.parkLng doubleValue];
        
        BMKMapPoint point1 = BMKMapPointForCoordinate(mapView.region.center);
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(parkLat,parkLng));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        
        if (self.annotationDics == nil) {
            self.annotationDics = [[NSMutableDictionary alloc] initWithCapacity:50];
        }
        
        if (distance < 3000) {
            //未添加过，需要添加
            if ([self.annotationDics objectForKey:park.parkId] == nil) {
                FLYPointAnnotation *annotation = [[FLYPointAnnotation alloc]init];
                CLLocationCoordinate2D coor;
                coor.latitude = parkLat;
                coor.longitude = parkLng;
                annotation.coordinate = coor;
                annotation.parkModel = park;
                [_mapBaseView.mapView addAnnotation:annotation];
                [self.annotationDics setObject:annotation forKey:park.parkId];
            }
        }else{
            //添加过，需要移除
            if ([self.annotationDics objectForKey:park.parkId] != nil) {
                FLYPointAnnotation *annotation = [self.annotationDics objectForKey:park.parkId];
                [_mapBaseView.mapView removeAnnotation:annotation];
                [self.annotationDics removeObjectForKey:park.parkId];
            }
        }
    }
}

//添加标记
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[FLYPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"flyAnnotation"];

        annotationView.pinColor = BMKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;// 设置该标注点动画显示
        annotationView.canShowCallout = false;
        
        FLYParkModel *parkModel =  ((FLYPointAnnotation *)annotation).parkModel;
        UIImage *image = nil;
        //路边
        if ([parkModel.parkType isEqualToString:@"1"]) {
            //签约
            if ([parkModel.parkStatus isEqualToString:@"0"]) {
                if ([parkModel.seatIdle intValue] > 100) {
                    image = [UIImage imageNamed:@"mfpparking_lb2_all_0.png"];
                }else if([parkModel.seatIdle intValue] > 20){
                    image = [UIImage imageNamed:@"mfpparking_lb3_all_0.png"];
                }else{
                    image = [UIImage imageNamed:@"mfpparking_lb1_all_0.png"];
                }
            }else{
                image = [UIImage imageNamed:@"mfpparking_lb4_all_0.png"];
            }
        }else{
            //签约
            if ([parkModel.parkStatus isEqualToString:@"0"]) {
                if ([parkModel.seatIdle intValue] > 100) {
                    image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
                }else if([parkModel.seatIdle intValue] > 20){
                    image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
                }else{
                    image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
                }
            }else{
                image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
            }
        }
        annotationView.image = image;
        return annotationView;
    }
    return nil;
}

#pragma mark - FLYMapDelegate delegate
//跟随
- (void)mapFollow:(BOOL)enable{
    _isFollow = enable;
}

//定位
- (void)mapLocation{
    _isLocation = YES;
}

#pragma mark - view other
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_mapBaseView.mapView viewWillAppear];
    // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapBaseView.mapView.delegate = self;
    
    //初始化BMKLocationService
    _locationService = [[BMKLocationService alloc]init];
    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [_mapBaseView.mapView viewWillDisappear];
    // 不用时，置nil
    _mapBaseView.mapView.delegate = nil;
    
    [_locationService stopUserLocationService];
    _locationService = nil;
    
}


@end
