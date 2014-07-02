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

@interface FLYMainViewController ()
@end

@implementation FLYMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tableView = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 80 + 20, ScreenWidth, ScreenHeight - 100) pullingDelegate:self];
    self.tableView.pullingDelegate=self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.self.tableView];
    
    
    [self requestData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadData{
    [self.tableView tableViewDidFinishedLoading];
}

#pragma mark -
- (void)requestData{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"30.520743",@"lat",@"114.407327",@"long",@"200000",@"range", nil];
    
    [FLYDataService requestWithURL:kHttpQueryNearbyList params:params httpMethod:@"POST" completeBolck:^(id result){
        //        NSArray *pois = [result objectForKey:@"pois"];
        //        self.data = pois;
        //        [self _refreshUI];
        [self loadData:result];
        
    }];
}

- (void)loadData:(id)data{
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
            self.datas = parkList;
            
//            [parks count];
            [self.tableView reloadData];
            
            
//            NSArray *statuses = [resultData objectForKey:@"statuses"];
//            NSMutableArray *weiBos = [NSMutableArray arrayWithCapacity:statuses.count];
//            for (NSDictionary *statuesDic in statuses) {
//                WeiboModel *weiBo = [[WeiboModel alloc] initWithDataDic:statuesDic];
//                [weiBos addObject:weiBo];
//            }
//            self.tableView.data = weiBos;
//            self.weibos = weiBos;
//            if (weiBos.count > 0) {
//                WeiboModel *topWeibo = [weiBos objectAtIndex:0];
//                self.topWeiboId = [topWeibo.weiboId stringValue];
//                WeiboModel *lastWeibo = [weiBos lastObject];
//                self.lastWeiboId = [lastWeibo.weiboId stringValue];
//                self.tableView.isMore = YES;
//            }
//            
//            //刷新
//            [self.tableView reloadData];

        }
    }
}


#pragma mark - Action
- (IBAction)userInfoAction:(id)sender{

}


- (IBAction)mapAction:(id)sender {
}

- (IBAction)search:(id)sender {
    [self.searchField resignFirstResponder];
}

#pragma mark - PullingRefreshTableViewDelegate
//下拉开始
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}
//刷新时间
- (NSDate *)pullingTableViewRefreshingFinishedDate{
    NSDateFormatter *df = [[NSDateFormatter alloc] init ];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *date = [df dateFromString:@"2012-05-03 10:10"];
    return date;
}
//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

#pragma mark - request
- (void)queryParkList{
    
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
    return 89;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ParkCell";
    FLYParkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYParkCell" owner:self options:nil] lastObject];
    }

    cell.parkModel = [self.datas objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}




@end
