//
//  FLYRemarkViewController.m
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYRemarkViewController.h"
#import "FLYAddRemarkViewController.h"
#import "FLYDataService.h"
#import "FLYRemarkModel.h"
#import "FLYRemarkCell.h"
#import "FLYBaseNavigationController.h"
#import "FLYLoginViewController.h"
#import "FLYAppDelegate.h"


@interface FLYRemarkViewController ()

@end

@implementation FLYRemarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"查看评论";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44) pullingDelegate:self];
    self.tableView.pullingDelegate=self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    UIButton *addButton = [UIFactory createNavigationButton:CGRectMake(0, 0, 45, 30) title:@"评论" target:self action:@selector(addAction)];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestRemarkData];
    }else{
        [self showAlert:@"请打开网络"];
    }
}

#pragma mark - Action
-(void)addAction{
    if ([FLYBaseUtil checkUserLogin]) {
        FLYAddRemarkViewController *addRemarkCtrl = [[FLYAddRemarkViewController alloc] init];
        addRemarkCtrl.parkId = self.parkId;
        [self.navigationController pushViewController:addRemarkCtrl animated:NO];

    }else{
        FLYLoginViewController *loginController = [[FLYLoginViewController alloc] init];
        FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:loginController];
        [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
    }
    
}

#pragma mark - request
-(void)requestRemarkData{
    _isMore = NO;
    self.datas = nil;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.parkId,
                                   @"parkid",
                                   nil];
    //防止循环引用
    __weak FLYRemarkViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryRemarkList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadRemarkData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}

//上拉
-(void)requestMoreRemarkData{
    //FLYMemberTraceModel
    
    if (_isMore) {
        _isMore = NO;
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.parkId,
                                       @"parkid",
                                       _sinceTime,
                                       @"since_time",
                                       nil];
        //防止循环引用
        __weak FLYRemarkViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryRemarkList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadRemarkData:result];
        } errorBolck:^(){
            [ref loadDataError];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:@"加载完成"];
    }
}

//下拉
-(void)requestMaxRemarkData{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.parkId,
                                   @"parkid",
                                   nil];
    if ([FLYBaseUtil isNotEmpty:_maxTime]) {
        [params setObject:_maxTime forKey:@"max_time"];
    }
    
    //防止循环引用
    __weak FLYRemarkViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryRemarkList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadMaxRemarkData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}


-(void)loadDataError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

- (void)loadRemarkData:(id)data{
    [self hideHUD];
    [self.tableView setReachedTheEnd:NO];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *remarks = [result objectForKey:@"remarks"];
            
            if ([remarks count] >= 20) {
                _isMore = YES;
            }
            
            NSMutableArray *remarkList = [NSMutableArray arrayWithCapacity:remarks.count];
            for (NSDictionary *remarkDic in remarks) {
                FLYRemarkModel *remarkModel = [[FLYRemarkModel alloc] initWithDataDic:remarkDic];
                [remarkList addObject:remarkModel];
            }
            if (self.datas == nil) {
                self.datas = remarkList;
            }else{
                [self.datas addObjectsFromArray:remarkList];
            }
            
            if (self.datas != nil && [self.datas count] > 0) {
                self.tableView.hidden = NO;
                [self showNoDataView:NO];
                
                int maxIndex = [self.datas count] - 1;
                _maxTime = ((FLYRemarkModel *)[self.datas objectAtIndex:0]).remarkTime;
                _sinceTime = ((FLYRemarkModel *)[self.datas objectAtIndex:maxIndex]).remarkTime;
                
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


- (void)loadMaxRemarkData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *remarks = [result objectForKey:@"remarks"];
            
            NSMutableArray *remarkList = [NSMutableArray arrayWithCapacity:remarks.count];
            for (NSDictionary *remarkDic in remarks) {
                FLYRemarkModel *remarkModel = [[FLYRemarkModel alloc] initWithDataDic:remarkDic];
                [remarkList addObject:remarkModel];
            }
            
            [remarkList addObjectsFromArray:self.datas];
            self.datas = remarkList;
            
            if (self.datas != nil && [self.datas count] > 0) {
                int maxIndex = [self.datas count] - 1;
                _maxTime = ((FLYRemarkModel *)[self.datas objectAtIndex:0]).remarkTime;
                _sinceTime = ((FLYRemarkModel *)[self.datas objectAtIndex:maxIndex]).remarkTime;
            }
            
            if (remarkList != nil && [remarkList count] > 0) {
                [self.tableView reloadData];
                
                self.tableView.hidden = NO;
                [self showNoDataView:NO];
            }
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
    
    [self.tableView tableViewDidFinishedLoading];
}

#pragma mark - PullingRefreshTableViewDelegate
//下拉开始
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(requestMaxRemarkData) withObject:nil afterDelay:1.f];
}

//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(requestMoreRemarkData) withObject:nil afterDelay:1.f];
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
    int height = 26 + 20 + 25;
    FLYRemarkModel *model = [self.datas objectAtIndex:indexPath.row];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 0)];
    label.textAlignment = NSTextAlignmentJustified;
    label.font = [UIFont systemFontOfSize:13.0];
    label.text = model.remarkContent;
    label.numberOfLines = 0;
    [label sizeToFit];
    
    height = height + label.height;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLYRemarkCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYRemarkCell" owner:self options:nil] lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.remarkModel = [self.datas objectAtIndex:indexPath.row];
    return cell;
}

- (void)viewWillAppear:(BOOL)animated{
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.reloadFlag isEqualToString:@"AddRemark"]) {
        appDelegate.reloadFlag = nil;
        [self.tableView launchRefreshing];
    }
}

#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
