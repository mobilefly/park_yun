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
#import "FLYDataService.h"
#import "FLYBussinessModel.h"

@interface FLYSearchViewController ()

@end

@implementation FLYSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"周边查询";
        self.isBackButton = NO;
        self.isCancelButton = YES;
    }
    return self;
}

//xib创建初始化
- (void)awakeFromNib{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _firstLocation = NO;
    
    _searchBar.backgroundColor=[UIColor clearColor];
    _searchBar.placeholder=@"搜索";
    _searchBar.delegate = self;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320 , ScreenHeight - 20 - 44 - 44) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.hidden = YES;
    [self.view addSubview:_tableView];
    
    _poiSearcher =[[BMKPoiSearch alloc]init];
    _locationService = [[BMKLocationService alloc]init];
    _codeSearcher =[[BMKGeoCodeSearch alloc]init];

}

//POI查询
- (void)search:(NSString *)keyword{
    [self showHUD:@"搜索中" isDim:NO];
    
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
    
    if (_poiSearcher != nil) {
        BOOL flag = [_poiSearcher poiSearchNearBy:option];
        if(flag)
        {
            NSLog(@"周边检索发送成功");
        }
        else
        {
            [self hideHUD];
            [self showAlert:@"抱歉，未找到结果"];
        }
    }
   
}

//经纬度反查地址
- (void)reverseGeo{
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = _location.coordinate;
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

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    _location = userLocation.location;
    if(!_firstLocation && _location != nil){
        _firstLocation = YES;
        //根据关键字查询
        [self search:nil];
        //反查城市
        [self reverseGeo];
        [_locationService stopUserLocationService];
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
        //self.datas = nil;
        //赋值
        NSArray *searchData = poiResult.poiInfoList;
        NSMutableArray *searchMutableArray = [NSMutableArray arrayWithArray:searchData];
        self.datas = searchMutableArray;
        //刷新数据
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
       [self showAlert:@"起始点有歧义"];
    } else {
       [self showAlert:@"抱歉，未找到结果"];
    }
}

#pragma mark - BMKGeoCodeSearchDelegate delegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSString *city = result.addressDetail.city;
        [self requestBussines:city];
    }
    else {
        [self showAlert:@"抱歉，未找到结果"];
    }
}

#pragma mark - reuqest
- (void)requestBussines:(NSString *)city{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   city,
                                   @"city",
                                   nil];
    
    //防止循环引用
    __weak FLYSearchViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryBusinessList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}

- (void)loadDataError{
    [FLYBaseUtil alertErrorMsg];
}

- (void)loadData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *businesss = [result objectForKey:@"businesss"];
            NSMutableArray *businessList = [NSMutableArray arrayWithCapacity:businesss.count];
            for (NSDictionary *bussinessDic in businesss) {
                FLYBussinessModel *bussinessModel = [[FLYBussinessModel alloc] initWithDataDic:bussinessDic];
                [businessList addObject:bussinessModel];
            }
            self.bussinessDatas = businessList;

            [self renderBussiness];
        }
    }
}

- (void)renderBussiness{

    if (_bussinessDatas != nil && [_bussinessDatas count] > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenHeight, 60)];
        int i = 0;
        for (FLYBussinessModel *bussinessModel in _bussinessDatas) {
            if (i == 4) {
                break;
            }
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10 + 78 * i, 10, 68, 40)];
            
            button.layer.cornerRadius = 2.0f;
            button.layer.masksToBounds = YES;
            button.layer.borderColor = [[UIColor lightGrayColor]CGColor];
            button.layer.borderWidth = 0.5f;
            button.backgroundColor = [UIColor clearColor];
            button.titleLabel.font = [UIFont systemFontOfSize: 12.0];
            button.showsTouchWhenHighlighted = YES;
            button.tag = 100 + i;
            
            [button setTitle:bussinessModel.bussinessName forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            i++;
        }
        self.tableView.tableHeaderView = view;
    }
    
   
}

- (void)location:(UIButton *)button{
    long tag = button.tag;
    long index = tag - 100;
    FLYBussinessModel *bussinessModel = [_bussinessDatas objectAtIndex:index];
    FLYMapViewController *mapController = [[FLYMapViewController alloc] init];
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    mapController.lat = [numFormat numberFromString:bussinessModel.bussinessLat];
    mapController.lon = [numFormat numberFromString:bussinessModel.bussinessLng];
    [self.navigationController pushViewController:mapController animated:NO];
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
    
    [self.navigationController pushViewController:mapController animated:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - UISearchBarDelegate delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self search:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [self.searchBar resignFirstResponder];
}

#pragma mark - view other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//不使用时将delegate设置为 nil
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.searchBar resignFirstResponder];
    
    [_locationService stopUserLocationService];
    _locationService.delegate = nil;
    
    _poiSearcher.delegate = nil;
    _codeSearcher.delegate = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
    
    _poiSearcher.delegate = self;
    _codeSearcher.delegate = self;
}

- (void)dealloc{
    if (_codeSearcher != nil) {
        _codeSearcher = nil;
    }

    if (_poiSearcher != nil) {
        _poiSearcher = nil;
    }
    
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - Action
- (IBAction)backgroupTap:(id)sender {
    [self.searchBar resignFirstResponder];
}
@end
