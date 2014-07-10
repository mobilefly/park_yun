//
//  FLYOfflineMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYOfflineMapViewController.h"
#import "UIButton+Bootstrap.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchText = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 210, 35)];
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.placeholder = @"请输入城市名称";
    [_searchText setFont:[UIFont systemFontOfSize:14.0f]];
    [self.view addSubview:_searchText];
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.frame = CGRectMake(_searchText.right + 10, 10, 60, 35);
    [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
//    [_searchBtn setFont:[UIFont systemFontOfSize:14.0f]];
    _searchBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_searchBtn primaryStyle];
    [self.view addSubview:_searchBtn];
    
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"城市列表",@"下载管理",nil];
    
    //初始化UISegmentedControl
    _segment = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    _segment.frame = CGRectMake(15, _searchBtn.bottom + 20 , 290, 35);
    _segment.selectedSegmentIndex = 0;//设置默认选择项索引
//    _segment.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
    [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];
    
    int top = 20 + 44 + 20 + 35 + 20 + 35;
    _cityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, ScreenHeight - top)];
    [self.view addSubview:_cityView];
    
    _downloadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, ScreenHeight - top)];
    [self.view addSubview:_downloadView];
    _downloadView.hidden = YES;
    
    
    _cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _cityView.width, _cityView.height)];
    _cityTableView.tag = 101;
    _cityTableView.delegate = self;
    _cityTableView.dataSource = self;
    
    [_cityView addSubview:_cityTableView];
    
    _downloadTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _downloadView.width, _downloadView.height)];
    _downloadTableView.tag = 102;
    _downloadTableView.delegate = self;
    _downloadTableView.dataSource = self;
    
    [_downloadView addSubview:_downloadTableView];
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
    return nil;
}

//Actions
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
