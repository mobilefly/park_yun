//
//  BaseTableView.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "PullingRefreshTableView.h"

@interface FLYBaseTableView : UITableView<UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate>

@property (retain,nonatomic) PullingRefreshTableView *tableView;
@property (nonatomic) BOOL refreshing;


@end
