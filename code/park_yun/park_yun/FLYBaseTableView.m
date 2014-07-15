//
//  BaseTableView.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseTableView.h"

@implementation FLYBaseTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
    }
    return self;
}

//xib创建初始化
- (void)awakeFromNib{
    [self _initView];
}


- (void)_initView{
    CGRect bounds = self.bounds;
    _tableView = [[PullingRefreshTableView alloc] initWithFrame:bounds style:UITableViewStyleGrouped];
    _tableView.pullingDelegate=self;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)loadData{
    [self.tableView tableViewDidFinishedLoading];
}

#pragma mark - PullingRefreshTableViewDelegate
//下拉开始
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    self.refreshing = YES;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
}

//上拉加载数据
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.f];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 127;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TBCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"TBCell" owner:self options:nil];
        cell = (UITableViewCell *)[nibArray objectAtIndex:0];
    }
    
    // Configure the cell...
    
    return cell;
}

@end
