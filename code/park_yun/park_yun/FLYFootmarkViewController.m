//
//  FLYFootmarkViewController.m
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYFootmarkViewController.h"
#import "FLYDataService.h"
#import "FLYFootmarkCell.h"
#import "FLYMemberTraceModel.h"


@interface FLYFootmarkViewController ()

@end

@implementation FLYFootmarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我的足迹";
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
    
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestFootmarkData];
    }else{
        [self showAlert:@"请打开网络"];
    }
}

#pragma mark - request
-(void)requestFootmarkData{
    _isMore = NO;
    _dataIndex = 0;
    self.datas = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   memberCarno,
                                   @"carno",
                                   nil];
    
    //防止循环引用
    __weak FLYFootmarkViewController *ref = self;
    [FLYDataService requestWithURL:kHttpFootmarkList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadFootmarkData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}



-(void)requestMorFootmarkData{
    //FLYMemberTraceModel
    
    if (_isMore) {
        _isMore = NO;
        
        int start = _dataIndex;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults stringForKey:@"token"];
        NSString *userid = [defaults stringForKey:@"memberId"];
        NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       token,
                                       @"token",
                                       userid,
                                       @"userid",
                                       memberCarno,
                                       @"carno",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       nil];
        
        //防止循环引用
        __weak FLYFootmarkViewController *ref = self;
        [FLYDataService requestWithURL:kHttpFootmarkList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadFootmarkData:result];
        } errorBolck:^(){
            [ref loadDataError];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:@"加载完成"];
    }
}


-(void)loadDataError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

- (void)loadFootmarkData:(id)data{
    _dataIndex = _dataIndex + 20;
    [self hideHUD];
    
    [self.tableView setReachedTheEnd:NO];
    self.tableView.hidden = NO;
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *traces = [result objectForKey:@"traces"];
            
            if ([traces count] >= 20) {
                _isMore = YES;
            }
            
            NSMutableArray *traceList = [NSMutableArray arrayWithCapacity:traces.count];
            for (NSDictionary *traceDic in traces) {
                FLYTraceModel *traceModel = [[FLYTraceModel alloc] initWithDataDic:traceDic];
                [traceList addObject:traceModel];
            }
            if (self.datas == nil) {
                self.datas = traceList;
            }else{
                [self.datas addObjectsFromArray:traceList];
            }
            [self.tableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
    
    
    [self.tableView tableViewDidFinishedLoading];
    
    if (!_isMore) {
        [self.tableView setReachedTheEnd:YES];
        [super showMessage:@"加载完成"];
    }
}

#pragma mark - PullingRefreshTableViewDelegate
//下拉开始
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(requestFootmarkData) withObject:nil afterDelay:1.f];
}
//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(requestMorFootmarkData) withObject:nil afterDelay:1.f];
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
    static NSString *CellIdentifier = @"FootmarkCell";
    FLYFootmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYFootmarkCell" owner:self options:nil] lastObject];
    }
    
    cell.traceModel = [self.datas objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
