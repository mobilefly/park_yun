//
//  FLYOfflineParkViewController.m
//  park_yun
//
//  Created by chen on 14-8-1.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYOfflineParkViewController.h"
#import "FLYDownloadParkCell.h"
#import "FLYOfflineParkModel.h"
#import "FLYDataService.h"
#import "FMDB.h"
#import "UIButton+Bootstrap.h"

@interface FLYOfflineParkViewController ()

@end

@implementation FLYOfflineParkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"离线数据管理";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createDB];
    
    _cursorDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    _downloadData = [[NSMutableArray alloc] initWithCapacity:10];
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *) [UIApplication sharedApplication].delegate;
    _searchText = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 220, 35)];
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.placeholder = @"请输入城市名称";
    if ([FLYBaseUtil isNotEmpty:appDelegate.city]) {
        _searchText.text = appDelegate.city;
    }
    [_searchText setFont:[UIFont systemFontOfSize:14.0f]];
    [self.view addSubview:_searchText];
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.frame = CGRectMake(_searchText.right + 10, 20, 60, 35);
    [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    _searchBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_searchBtn primaryStyle];
    [_searchBtn addTarget:self action:@selector(searchCity) forControlEvents:UIControlEventTouchUpInside];
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
    
    //查询当前城市离线包
    if ([FLYBaseUtil isNotEmpty:_searchText.text]) {
        [self searchCity];
    }
    //查询下载管理列表
    [self queryVersionList];
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
        static NSString *identifier = @"CityParkCell";
        FLYCityParkCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYCityParkCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.data = [_cityData objectAtIndex:indexPath.row];
        cell.parkDelegate = self;
        return cell;
    }else{
        static NSString *identifier = @"DownloadParkCell";
        FLYDownloadParkCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYDownloadParkCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.data = [_downloadData objectAtIndex:indexPath.row];
        cell.parkDelegate = self;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Action
- (void)searchCity{
    [_searchText resignFirstResponder];
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestCityData:_searchText.text];
        
        _segment.selectedSegmentIndex = 0;
        [self switchAction];
    }else{
        [self showToast:@"请打开网络"];
    }
}

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
            break;
        default:
            break;
    }
}

- (IBAction)backgroupTap:(id)sender {
    [_searchText resignFirstResponder];
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
            break;
        default:
            break;
    }
}

#pragma mark - DB
- (void)createDB{
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //创建表（FMDB中只有update和query操作，出了查询其他都是update操作）
    [db executeUpdate:@"create table if not exists PARK (PARK_ID TEXT PRIMARY KEY,PARK_CODE TEXT,PARK_NAME TEXT,PARK_REGIONID TEXT,PARK_CAPACITY INTEGER,PARK_CAPDESC TEXT,PARK_LAT TEXT,PARK_LNG TEXT,PARK_FEEDESC TEXT,PARK_FEELEVEL TEXT,PARK_FREETIME INTEGER,PARK_TYPE TEXY,PARK_STATUS TEXT,PARK_ADDRESS TEXT,PARK_REMARK TEXT,PARK_SCORE TEXT)"];
    
    [db executeUpdate:@"create table if not exists VERSION (REGION_ID TEXT PRIMARY KEY,REGION_CODE TEXT,REGION_NAME TEXT,MAX_VERSION INTEGER)"];
    
    [db close];
}

- (void)savePark:(NSMutableArray *)parks version:(FLYOfflineParkModel *)versionModel{
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //开启事务
    [db beginTransaction];
    @try {
        for (FLYParkModel *parkModel in parks) {
            //插入数据
            //1.PARK_ID 2.PARK_CODE 3.PARK_NAME 4.PARK_REGIONID 5.PARK_CAPACITY
            //6.PARK_CAPDESC 7.PARK_LAT 8.PARK_LNG 9.PARK_FEEDESC 10.PARK_FEELEVEL
            //11.PARK_FREETIME 12.PARK_TYPE 13.PARK_STATUS 14.PARK_ADDRESS 15.PARK_REMARK
            //16.PARK_SCORE
            BOOL insert = [db executeUpdate:@"insert or replace into PARK values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                           parkModel.parkId,
                           parkModel.parkCode,
                           parkModel.parkName,
                           parkModel.parkRegionid,
                           parkModel.parkCapacity,
                           parkModel.parkCapdesc,
                           parkModel.parkLat,
                           parkModel.parkLng,
                           parkModel.parkFeedesc,
                           parkModel.parkFeelevel,
                           parkModel.parkFreetime,
                           parkModel.parkType,
                           parkModel.parkStatus,
                           parkModel.parkAddress,
                           parkModel.parkRemark,
                           parkModel.parkScore];

            if (!insert) {
                NSLog(@"PARK:保存失败");
            }else{
                NSLog(@"PARK:保存成功");
            }
        }
        
        //1.REGION_ID 2.REGION_CODE 3.REGION_NAME 4.MAX_VERSION
        if (versionModel != nil) {
            
            NSNumber *version = versionModel.maxVersion;
            if (versionModel.updateVersion != nil) {
                version = versionModel.updateVersion;
            }
            
            BOOL insert = [db executeUpdate:@"insert or replace into VERSION values (?,?,?,?)",
                           versionModel.regionId,
                           versionModel.regionCode,
                           versionModel.regionName,
                           version
                           ];
            if (!insert) {
               NSLog(@"VERSION:保存失败");
            }else{
               NSLog(@"VERSION:保存成功");
            }
        }
    }@catch (NSException *exception) {
        [db rollback];
    }@finally {
        [db commit];
    }
    [db close];
}

- (void)queryVersionList{
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select * from VERSION"];
    while ([resultSet next]) {
        FLYOfflineParkModel *versionModel = [[FLYOfflineParkModel alloc] init];
        NSString *regionId = [resultSet stringForColumn:@"REGION_ID"];
        NSString *regionCode = [resultSet stringForColumn:@"REGION_CODE"];
        NSString *regionName = [resultSet stringForColumn:@"REGION_NAME"];
        int maxVersion = [resultSet intForColumn:@"MAX_VERSION"];
        
        versionModel.regionId = regionId;
        versionModel.regionCode = regionCode;
        versionModel.regionName = regionName;
        versionModel.maxVersion = [NSNumber numberWithInt:maxVersion];
        versionModel.ratio = 100;
        versionModel.status = 0;
        versionModel.update = NO;
        [_downloadData addObject:versionModel];
    }
    [db close];
    
    [_downloadTableView reloadData];
    
    if ([_downloadData count] > 0) {
        [self requestUpdate];
    }
}

- (BOOL)queryVersionExist:(NSString *)regionId{
    BOOL result = NO;
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return result;
    }
    
    FMResultSet *resultSet = [db executeQuery:@"select * from VERSION where REGION_ID = ?",regionId];
    while ([resultSet next]) {
        result = YES;
    }
    
    [db close];
    return result;
}

- (void)deleteByRegionId:(NSString *)regionId{
    BOOL flag = YES;
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    //获取数据库并打开
    FMDatabase *db  = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //开启事务
    [db beginTransaction];
    @try {
        //NSString *regionLike = [NSString stringWithFormat:@"%@%@",regionId,@"%"];
        flag = [db executeUpdate:@"delete from PARK where PARK_REGIONID in (select REGION_ID from REGION where REGION_PARENTID = ? or REGION_ID = ?) ",regionId,regionId];
        if (!flag) {
            NSLog(@"PARK:删除失败");
        }else{
            flag = [db executeUpdate:@"delete from VERSION where REGION_ID = ?",regionId];
            if (!flag) {
                NSLog(@"VERSION:删除失败");
            }
        }
    }@catch (NSException *exception) {
        flag = NO;
        [db rollback];
    }@finally {
        [db commit];
    }
    [db close];
    
    if (flag) {
        for(int i=0;i<[_downloadData count];i++){
            FLYOfflineParkModel *versionModel = _downloadData[i];
            if ([versionModel.regionId isEqualToString:regionId]) {
                [_downloadData removeObjectAtIndex:i];
                break;
            }
        }
        [_downloadTableView reloadData];
    }
}

#pragma mark - request
- (void)requestUpdate{
    
    NSString *cityCode = @"";
    NSString *cityVersion = @"";
    for (FLYOfflineParkModel *model in _downloadData) {
        cityCode = [cityCode stringByAppendingFormat:@"%@,",model.regionCode];
        cityVersion = [cityVersion stringByAppendingFormat:@"%@,",model.maxVersion];
    }
    
    cityCode = [cityCode substringToIndex:cityCode.length - 1];
    cityVersion = [cityVersion substringToIndex:cityVersion.length - 1];
    
    NSLog(@"cityCode:%@,cityVersion:%@",cityCode,cityVersion);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   cityCode,
                                   @"cityCode",
                                   cityVersion,
                                   @"cityVersion",
                                   nil];
    //防止循环引用
    __weak FLYOfflineParkViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryOfflineUpdate params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadUpdateData:result];
    } errorBolck:^(){
        [ref loadError];
    }];
}

- (void)loadUpdateData:(id)data{
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *offlines = [result objectForKey:@"offlines"];
            
            for (NSDictionary *offlineDic in offlines) {
                FLYOfflineParkModel *offlineModel = [[FLYOfflineParkModel alloc] initWithDataDic:offlineDic];
                
                for (FLYOfflineParkModel *model in _downloadData) {
                    if ([model.regionId isEqualToString:offlineModel.regionId]) {
                        model.update = YES;
                        model.parkCount = offlineModel.parkCount;
                        model.updateVersion = offlineModel.maxVersion;
                        break;
                    }
                }
            }
            
            [_downloadTableView reloadData];
            
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showToast:msg];
    }
}

- (void)requestCityData:(NSString *)cityName{
    [self hideHUD];
    
    _cityData = nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   cityName,
                                   @"cityName",
                                   nil];
    
    //防止循环引用
    __weak FLYOfflineParkViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryOfflineByCityName params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadCityData:result];
    } errorBolck:^(){
        [ref loadError];
    }];
}

- (void)loadError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

- (void)loadCityData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *offlines = [result objectForKey:@"offlines"];
            
            NSMutableArray *offlineList = [NSMutableArray arrayWithCapacity:offlines.count];
            for (NSDictionary *offlineDic in offlines) {
                FLYOfflineParkModel *offlineModel = [[FLYOfflineParkModel alloc] initWithDataDic:offlineDic];
                [offlineList addObject:offlineModel];
            }
            
            _cityData = offlineList;
            [_cityTableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showToast:msg];
    }
}

- (void)requestDownload:(FLYOfflineParkModel *)model version:(NSString *)version{
    NSString *index = (NSString *)[_cursorDic objectForKey:model.regionId];
    if ([FLYBaseUtil isEmpty:index]) {
        index = @"0";
        [_cursorDic setObject:index forKey:model.regionId];
    }
    
    if ([FLYBaseUtil isEmpty:version]) {
        version = @"0";
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   model.regionCode,
                                   @"cityCode",
                                   version,
                                   @"cityVersion",
                                   index,
                                   @"start",
                                   nil];
    
    //防止循环引用
    __weak FLYOfflineParkViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryOfflineData params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadDownloadData:result model:model index:index version:version];
    } errorBolck:^(){
        [ref loadError];
    }];
}

- (void)loadDownloadData:(id)data model:(FLYOfflineParkModel *)versionModel index:(NSString *)index version:(NSString *)version{
    
    int cursor = [index intValue];
    cursor = cursor + 20;
    
    [_cursorDic setObject:[NSString stringWithFormat:@"%i",cursor] forKey:versionModel.regionId];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *parks = [result objectForKey:@"parks"];
            
            NSMutableArray *parkList = [NSMutableArray arrayWithCapacity:parks.count];
            for (NSDictionary *parkDic in parks) {
                FLYParkModel *parkModel = [[FLYParkModel alloc] initWithDataDic:parkDic];
                [parkList addObject:parkModel];
            }

            NSString *isLast = [result objectForKey:@"isLast"];
            NSNumber *total = [result objectForKey:@"total"];
            
            FLYOfflineParkModel *model;
            for (FLYOfflineParkModel *tempModel in _downloadData) {
                if ([tempModel.regionId isEqualToString:versionModel.regionId]) {
                    model = tempModel;
                    break;
                }
            }
            
            if ([isLast isEqualToString:@"Y"]) {
                [self savePark:parkList version:versionModel];
                [_cursorDic removeObjectForKey:versionModel.regionId];
                model.ratio = 100;
                model.status = 0;
            }else{
                [self savePark:parkList version:nil];
                [self requestDownload:versionModel version:version];

                int ratio = cursor * 100 / [total intValue];
                NSLog(@"%i",ratio);
                model.ratio = ratio;
                model.status = 1;
            }
            
            [_downloadTableView reloadData];
        }
    }
}

#pragma mark - FLYOfflineParkDelegate delegate
//下载
- (void)download:(FLYOfflineParkModel *)model{
    NSString *index = [_cursorDic objectForKey:model.regionId];
    if ([FLYBaseUtil isNotEmpty:index]) {
        [self showToast:@"该城市数据正在下载中"];
        return;
    }
    BOOL flag = [self queryVersionExist:model.regionId];
    if (flag) {
        [self showToast:@"该城市数据包已下载"];
        return;
    }

    FLYOfflineParkModel *versionModel = [[FLYOfflineParkModel alloc] init];
    versionModel.regionId = model.regionId;
    versionModel.regionName = model.regionName;
    versionModel.regionCode = model.regionCode;
    versionModel.parkCount = model.parkCount;
    versionModel.maxVersion = model.maxVersion;
    versionModel.status = 1;
    versionModel.update = NO;
    versionModel.ratio = 0;
    
    [_downloadData addObject:versionModel];
    [self requestDownload:model version:@"0"];
    
    _segment.selectedSegmentIndex = 1;
    [self switchAction];
}

//更新
- (void)update:(FLYOfflineParkModel *)model{
    for (FLYOfflineParkModel *versionModel in _downloadData) {
        if ([versionModel.regionId isEqualToString:model.regionId]) {
            versionModel.update = NO;
            versionModel.status = 1;
            versionModel.ratio = 0;
            
            [self requestDownload:model version:[model.maxVersion stringValue]];
            
            break;
        }
    }
}

//删除
- (void)remove:(FLYOfflineParkModel *)model{
    [self deleteByRegionId:model.regionId];
}


#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
