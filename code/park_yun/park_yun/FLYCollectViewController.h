//
//  FLYCollectViewController.h
//  park_yun
//
//  Created by chen on 14-7-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "PullingRefreshTableView.h"
#import "BMapKit.h"

@interface FLYCollectViewController : FLYBaseViewController<PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource,BMKLocationServiceDelegate>{
    //最后一次数据加载索引
    int _dataIndex;
    //数据是否全部加载完
    BOOL _isMore;
    
    BMKLocationService *_locationService;
    BOOL _firstLocation;
    CLLocation *_location;
}

//列表
@property (strong,nonatomic) PullingRefreshTableView *tableView;
//table数据
@property (strong,nonatomic) NSMutableArray *datas;
//下拉刷新
@property (nonatomic) BOOL refreshing;

@end
