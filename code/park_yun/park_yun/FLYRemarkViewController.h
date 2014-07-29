//
//  FLYRemarkViewController.h
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "PullingRefreshTableView.h"

@interface FLYRemarkViewController : FLYBaseViewController<PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    //最后一次数据加载索引
//    int _dataIndex;
    //数据是否全部加载完
    BOOL _isMore;
    
    NSString *_sinceTime;
    NSString *_maxTime;
}

@property (nonatomic,copy) NSString *parkId;
//列表
@property (strong,nonatomic) PullingRefreshTableView *tableView;
//table数据
@property (strong,nonatomic) NSMutableArray *datas;
//下拉刷新
@property (nonatomic) BOOL refreshing;

@end
