//
//  FLYMessageViewController.m
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMessageViewController.h"
#import "FLYMessageModel.h"
#import "FLYMessageCell.h"
#import "FLYDataService.h"

@interface FLYMessageViewController ()

@end

@implementation FLYMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"消息中心";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44) pullingDelegate:self];
    self.tableView.pullingDelegate=self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestMessageData];
    }else{
        [self showToast:@"请打开网络"];
    }
}

#pragma mark - 数据请求
-(void)requestMessageData{
    _isMore = NO;
    _dataIndex = 0;
    self.datas = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   @"0",
                                   @"readFlag",
                                   nil];
    
    //防止循环引用
    __weak FLYMessageViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryMessageList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadMessageData:result];
    } errorBolck:^(){
        [ref loadDataError:YES];
    }];
}


-(void)requestMoreMessageData{
    if (_isMore) {
        _isMore = NO;
        
        int start = _dataIndex;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults stringForKey:@"token"];
        NSString *userid = [defaults stringForKey:@"memberId"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       token,
                                       @"token",
                                       userid,
                                       @"userid",
                                       [NSString stringWithFormat:@"%d",start],
                                       @"start",
                                       @"0",
                                       @"readFlag",
                                       nil];
        
        //防止循环引用
        __weak FLYMessageViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryMessageList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadMessageData:result];
        } errorBolck:^(){
            [ref loadDataError:NO];
        }];
    }else{
        [self.tableView tableViewDidFinishedLoadingWithMessage:nil];
    }
}

-(void)loadDataError:(BOOL)isFirst{
    if (isFirst) {
        [self showTimeoutView:YES];
    }
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (void)loadMessageData:(id)data{
    _dataIndex = _dataIndex + 20;
    [self hideHUD];
    [self.tableView setReachedTheEnd:NO];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *messages = [result objectForKey:@"messages"];
            
            if ([messages count] >= 20) {
                _isMore = YES;
            }
            
            NSMutableArray *messageList = [NSMutableArray arrayWithCapacity:messages.count];
            for (NSDictionary *messageDic in messages) {
                FLYMessageModel *messageModel = [[FLYMessageModel alloc] initWithDataDic:messageDic];
                [messageList addObject:messageModel];
            }
            if (self.datas == nil) {
                self.datas = messageList;
            }else{
                [self.datas addObjectsFromArray:messageList];
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

#pragma mark - PullingRefreshTableViewDelegate
//下拉开始
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(requestMessageData) withObject:nil afterDelay:1.f];
}

//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(requestMoreMessageData) withObject:nil afterDelay:1.f];
}

//滑动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.tableView tableViewDidScroll:scrollView];
}
//结束滑动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView tableViewDidEndDragging:scrollView];
}

#pragma mark - UITableView
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
    int height = 10 + 20 + 5 + 5 + 20 + 5 + 2;
    FLYMessageModel *model = [self.datas objectAtIndex:indexPath.row];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
    label.textAlignment = NSTextAlignmentJustified;
    label.font = [UIFont systemFontOfSize:13.0];
    label.text = model.messageContent;
    label.numberOfLines = 0;
    [label sizeToFit];
    height = height + label.height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MessageCell";
    FLYMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYMessageCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.messageModel = [self.datas objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
