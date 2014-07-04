//
//  FLYSearchViewController.m
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYSearchViewController.h"
#import "FLYMapViewController.h"
#import "FLYBaseNavigationController.h"

@interface FLYSearchViewController ()

@end

@implementation FLYSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"周边地图查询";
        self.isBackButton = NO;
        self.isCancelButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _firstLocation = YES;
    
    _searchBar.backgroundColor=[UIColor clearColor];
    _searchBar.placeholder=@"搜索";
    _searchBar.delegate = self;
    
    _tableView.hidden = YES;
    _tableView.frame = CGRectMake(10, 10, 300 , ScreenHeight - 20 - 44 - 10);
    
    if (_locationService == nil) {
        //初始化BMKLocationService
        _locationService = [[BMKLocationService alloc]init];
        _locationService.delegate = self;
        //启动LocationService
        [_locationService startUserLocationService];
    }
}

- (void)search:(NSString *)keyword{
    [self showHUD:@"搜索中" isDim:NO];
    //检索
    if (_searcher == nil) {
        _searcher =[[BMKPoiSearch alloc]init];
        _searcher.delegate = self;
    }
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 0;
    option.pageCapacity = 50;
    option.location = _location.coordinate;
    if (keyword == nil || keyword.length <= 0) {
        option.keyword = @"停车场";
    }else{
        option.keyword = keyword;
    }
    option.radius = 2000;
    BOOL flag = [_searcher poiSearchNearBy:option];
    
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        [self hideHUD];
        NSLog(@"周边检索发送失败");
    }
}

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    _location = userLocation.location;
    if(_location != nil){
        if (_firstLocation) {
            [self search:nil];
        }
        [_locationService stopUserLocationService];
        _firstLocation = NO;
    }
}

//BMKPoiInfo 说明
//NSString* _name;			///<POI名称
//NSString* _uid;
//NSString* _address;		///<POI地址
//NSString* _city;			///<POI所在城市
//NSString* _phone;		///<POI电话号码
//NSString* _postcode;		///<POI邮编
//int		  _epoitype;		///<POI类型，0:普通点 1:公交站 2:公交线路 3:地铁站 4:地铁线路
//CLLocationCoordinate2D _pt;	///<POI坐标

#pragma mark - BMKPoiSearchDelegate delegate
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)error{
    
    [self hideHUD];
    //在此处理正常结果
    if (error == BMK_SEARCH_NO_ERROR) {
        //清空
//        self.datas = nil;
        //赋值
        NSArray *searchData = poiResult.poiInfoList;
        NSMutableArray *searchMutableArray = [NSMutableArray arrayWithArray:searchData];
        self.datas = searchMutableArray;
        //刷新数据
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果");
    }
    

}

#pragma mark - UITableViewDataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"poiCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    BMKPoiInfo *poiInfo = [self.datas objectAtIndex:indexPath.row];
    
    BMKMapPoint point1 = BMKMapPointForCoordinate(_location.coordinate);
    BMKMapPoint point2 = BMKMapPointForCoordinate(poiInfo.pt);
    
    NSString *distanceText = @"";
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    if (distance > 1000) {
        distanceText = [NSString stringWithFormat:@"%.1f千米",distance / 1000];
    }else{
        distanceText = [NSString stringWithFormat:@"%.0f米",distance];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"[%@]%@",distanceText,poiInfo.name];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    
    cell.detailTextLabel.text = poiInfo.address;
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BMKPoiInfo *poiInfo = [self.datas objectAtIndex:indexPath.row];
   
    FLYMapViewController *mapController = [[FLYMapViewController alloc] init];
    
    mapController.lat = [NSNumber numberWithDouble:poiInfo.pt.latitude];
    mapController.lon = [NSNumber numberWithDouble:poiInfo.pt.longitude];
    
    FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:mapController];
    [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - UISearchBarDelegate delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self search:searchBar.text];
}

#pragma mark - view other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//不使用时将delegate设置为 nil
-(void)viewWillDisappear:(BOOL)animated
{
    if (_searcher != nil) {
        _searcher.delegate = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if (_searcher != nil) {
        _searcher.delegate = self;
    }
}

@end
