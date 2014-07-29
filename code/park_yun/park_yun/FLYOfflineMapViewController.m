//
//  FLYOfflineMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYOfflineMapViewController.h"
#import "UIButton+Bootstrap.h"



#import "FLYDownloadCell.h"

@interface FLYOfflineMapViewController ()

@end

@implementation FLYOfflineMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"离线地图";
    }
    return self;
}


#pragma mark - UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstLocation = NO;
    //定位
    _locationService = [[BMKLocationService alloc]init];
    _codeSearcher =[[BMKGeoCodeSearch alloc]init];
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc]init];
    
    _searchText = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 220, 35)];
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.placeholder = @"请输入城市名称";
    [_searchText setFont:[UIFont systemFontOfSize:14.0f]];
    [self.view addSubview:_searchText];
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.frame = CGRectMake(_searchText.right + 10, 20, 60, 35);
    [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    _searchBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_searchBtn primaryStyle];
    [_searchBtn addTarget:self action:@selector(searchCity:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBtn];
    
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"城市列表",@"下载管理",nil];
    
    //初始化UISegmentedControl
    _segment = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segment.frame = CGRectMake(15, _searchBtn.bottom + 20 , 290, 35);
    _segment.selectedSegmentIndex = 0;//设置默认选择项索引
    _segment.tintColor= [UIColor colorWithRed:51/255.0 green:119/255.0 blue:172/255.0 alpha:1];
    
    [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];
    
    int top = 20 + 35 + 20 + 35;
    _cityView = [[UIView alloc] initWithFrame:CGRectMake(0, top, 320, ScreenHeight - top - 20 -44)];
    [self.view addSubview:_cityView];
    
    _downloadView = [[UIView alloc] initWithFrame:CGRectMake(0, top, 320, ScreenHeight - top - 20 -44)];
    [self.view addSubview:_downloadView];
    _downloadView.hidden = YES;
    
    
    _cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, _cityView.width, _cityView.height - 10)];
    _cityTableView.tag = 101;
    _cityTableView.delegate = self;
    _cityTableView.dataSource = self;
    
    [_cityView addSubview:_cityTableView];
    
    _downloadTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, _downloadView.width, _downloadView.height - 10)];
    _downloadTableView.tag = 102;
    _downloadTableView.delegate = self;
    _downloadTableView.dataSource = self;
    [_downloadView addSubview:_downloadTableView];
}

//经纬度反查地址
- (void)reverseGeo{

    if (_location != nil) {
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
}

#pragma mark - UITableViewDataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 101) {
        return [_cityData count];
    }else{
        return [_downloadData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 101) {
        BMKOLSearchRecord *city = [_cityData objectAtIndex:indexPath.row];
        
        static NSString *identifier = @"cityCell";
        FLYCityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYCityCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.data = city;
        cell.cellDelegate = self;
        return cell;
    }else{
        BMKOLUpdateElement *city = [_downloadData objectAtIndex:indexPath.row];
        static NSString *identifier = @"downloadCell";
        FLYDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYDownloadCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.data = city;
        cell.cellDelegate = self;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Actions
-(void)segmentAction:(UISegmentedControl *)segment{
    NSInteger index = segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            _cityView.hidden = NO;
            _downloadView.hidden = YES;
            break;
        case 1:
            _downloadView.hidden = NO;
            _cityView.hidden = YES;
            
            if (_offlineMap != nil) {
                //获取各城市离线地图更新信息
                _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
                [_downloadTableView reloadData];
            }
            
            break;
        default:
            break;
    }
}

-(void)switchAction{
    NSInteger index = _segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            _cityView.hidden = NO;
            _downloadView.hidden = YES;
            break;
        case 1:
            _downloadView.hidden = NO;
            _cityView.hidden = YES;
            
            if (_offlineMap != nil) {
                //获取各城市离线地图更新信息
                _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
                [_downloadTableView reloadData];
            }
            

            break;
        default:
            break;
    }
}

- (IBAction)backgroupTap:(id)sender {
    [_searchText resignFirstResponder];
}

- (void)searchCity:(UIButton *)button{
    
    [_searchText resignFirstResponder];
    
    if ([FLYBaseUtil isNotEmpty:_searchText.text]) {
        if (_offlineMap != nil) {
            NSArray *city = [_offlineMap searchCity:_searchText.text];
            if ([city count] > 0) {
                _cityData = [city mutableCopy];
                _segment.selectedSegmentIndex = 0;
                [_cityTableView reloadData];
                
                [self switchAction];
            }else{
                [FLYBaseUtil alertMsg:@"（%@）未查询到离线数据包"];
            }
        }
    }else{
        [FLYBaseUtil alertMsg:@"请输入城市名称"];
    }

}

#pragma mark - FLYOfflineCellDelegate delegate
//下载
- (void)download:(int)cityID{
    
    BOOL flag = true;
    if (_downloadData != nil) {
        for (int i=0; i<[_downloadData count]; i++) {
            BMKOLUpdateElement *updateDate = _downloadData[i];
            if (updateDate.cityID == cityID && (updateDate.status == 1 || updateDate.status == 4)) {
                flag = false;
                break;
            }
        }
    }
    
    if (flag) {
        _segment.selectedSegmentIndex = 1;
        [_offlineMap start:cityID];
        _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
        [_downloadTableView reloadData];
        
        [self switchAction];
    }else{
        [FLYBaseUtil alertMsg:@"该地图包已下载"];
    }
    
}

//更新
- (void)update:(int)cityID{
    [_offlineMap update:cityID];
    _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    [_downloadTableView reloadData];
}

//删除
- (void)remove:(int)cityID{
    [_offlineMap remove:cityID];
    _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    [_downloadTableView reloadData];
}

//取消
- (void)cancel:(int)cityID{
    [_offlineMap pause:cityID];
    [_offlineMap remove:cityID];
    _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    [_downloadTableView reloadData];
}

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    _location = userLocation.location;
    if(!_firstLocation && _location != nil){
        _firstLocation = YES;
        
        //反查城市
        [self reverseGeo];
        [_locationService stopUserLocationService];
    }
}

#pragma mark - BMKGeoCodeSearchDelegate delegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSString *city = result.addressDetail.city;
        if ([FLYBaseUtil isNotEmpty:city] && result != nil) {
            if (_searchText != nil && ![FLYBaseUtil isNotEmpty:_searchText.text]) {
                _searchText.text = city;
            }
        }
    }
}

#pragma mark - BMKOfflineMapDelegate delegate
- (void)onGetOfflineMapState:(int)type withState:(int)state{
    
    
    if (type == TYPE_OFFLINE_UPDATE) {
        
        if (_downloadData == nil) {
            //获取各城市离线地图更新信息
            _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
            [_downloadTableView reloadData];
        }
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement *updateInfo = [_offlineMap getUpdateInfo:state];
        for (int i=0; i< [_downloadData count]; i++) {
            BMKOLUpdateElement *updateDate = _downloadData[i];
            if (updateDate.cityID == updateInfo.cityID) {
                [_downloadData replaceObjectAtIndex:i withObject:updateInfo];
            }
        }
        [_downloadTableView reloadData];

    }
    if (type == TYPE_OFFLINE_NEWVER) {
        
        if (_downloadData == nil) {
            //获取各城市离线地图更新信息
            _downloadData = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
            [_downloadTableView reloadData];
        }
        
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement *updateInfo = [_offlineMap getUpdateInfo:state];
        for (int i=0; i< [_downloadData count]; i++) {
            BMKOLUpdateElement *updateDate = _downloadData[i];
            if (updateDate.cityID == updateInfo.cityID) {
                [_downloadData replaceObjectAtIndex:i withObject:updateInfo];
            }
        }
        [_downloadTableView reloadData];
    }
}

#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    //停止LocationService
    [_locationService stopUserLocationService];
    _locationService.delegate = nil;
    
    _codeSearcher.delegate = nil;
    _offlineMap.delegate = nil;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
    
    _codeSearcher.delegate = self;
    _offlineMap.delegate = self;
    
    
}

- (void)dealloc{
    
    if (_codeSearcher != nil) {
        _codeSearcher = nil;
    }
    
    if (_offlineMap != nil) {
        _offlineMap = nil;
    }
    
    NSLog(@"%s",__FUNCTION__);
    
}


@end
