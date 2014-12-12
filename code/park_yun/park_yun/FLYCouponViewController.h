//
//  FLYCouponViewController.h
//  park_yun
//
//  Created by chen on 14-12-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYCouponViewController : FLYBaseViewController<FLYBaseCtrlDelegate,PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    //最后一次数据加载索引
    int _dataIndex;
    //数据是否全部加载完
    BOOL _isMore;
}

//列表
@property (strong,nonatomic) PullingRefreshTableView *tableView;
//table数据
@property (strong,nonatomic) NSMutableArray *datas;
//下拉刷新
@property (nonatomic) BOOL refreshing;

@end
