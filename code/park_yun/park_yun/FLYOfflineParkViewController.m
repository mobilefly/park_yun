//
//  FLYOfflineParkViewController.m
//  park_yun
//
//  Created by chen on 14-8-1.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYOfflineParkViewController.h"
#import "UIButton+Bootstrap.h"
#import "FLYCityParkCell.h"
#import "FLYDownloadParkCell.h"
#import "FLYDataService.h"
#import "FLYOfflineParkModel.h"
#import "FMDB.h"

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
//        cell.cellDelegate = self;
        return cell;
    }else{
        static NSString *identifier = @"downloadCell";
        FLYDownloadParkCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYDownloadCell" owner:self options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
//        cell.data = city;
//        cell.cellDelegate = self;
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
    }else{
        [self showAlert:@"请打开网络"];
    }
}

-(void)requestCityData:(NSString *)cityName{
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

-(void)loadError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

-(void)loadCityData:(id)data{
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

#pragma mark - DB
- (void)savePark{
    //获取Document文件夹下的数据库文件，没有则创建
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docPath stringByAppendingPathComponent:@"park.db"];
    
    //获取数据库并打开
    FMDatabase *database  = [FMDatabase databaseWithPath:dbPath];
    if (![database open]) {
        NSLog(@"Open database failed");
        return;
    }
    
    //创建表（FMDB中只有update和query操作，出了查询其他都是update操作）
    [database executeUpdate:@"create table user (PARK_ID TEXT PRIMARY KEY,PARK_CODE TEXT,PARK_NAME TEXT,PARK_REGIONID TEXT,PARK_CAPACITY INTEGER,PARK_CAPDESC TEXT,PARK_LAT TEXT,PARK_LNG TEXT,PARK_FEEDESC TEXT,PARK_FEELEVEL TEXT,PARK_FREETIME INTEGER,PARK_TYPE TEXY,PARK_STATUS TEXT,PARK_ADDRESS TEXT,PARK_ADDRESS TEXT,PARK_REMARK TEXT,PARK_SCORE TEXT)"];
    
//    //插入数据
//    BOOL insert = [database executeUpdate:@"insert into user values (?,?,?)",nameTextField.text,genderTextField.text,ageTextField.text];
//
//    if (insert) {
//
//    }

    [database close];
}

- (void)queryVersion{
    
}

#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
