//
//  FLYSearhBussinessViewController.h
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "FLYBussinessModel.h"
#import "PullingRefreshTableView.h"
#import "BMapKit.h"


@interface FLYSearhBussinessViewController : FLYBaseViewController<PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    //最后一次数据加载索引
    int _dataIndex;
    //数据是否全部加载完
    BOOL _isMore;
}

//@property(strong,nonatomic) FLYBussinessModel *bussinessModel;


@property(assign,nonatomic) CLLocationCoordinate2D coordinate;

@property(strong,nonatomic) NSString *titleName;
//首页列表数据
@property (strong, nonatomic) NSMutableArray *datas;
//首页列表
@property (strong, nonatomic) PullingRefreshTableView *tableView;
//下拉刷新
@property (nonatomic) BOOL refreshing;

@end
