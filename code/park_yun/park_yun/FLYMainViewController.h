//
//  FLYMainViewController.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullingRefreshTableView.h"
#import "ThemeButton.h"
#import "FLYBaseMapViewController.h"


@interface FLYMainViewController : FLYBaseMapViewController<PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource,BMKMapViewDelegate,BMKLocationServiceDelegate>{
    
    //第一次定位加载数据
    BOOL _firstFlag;
    //最后一次数据加载索引
    int _dataIndex;
    //数据是否全部加载完
    BOOL _isMore;
    

}

//首页列表数据
@property (strong, nonatomic)NSMutableArray *datas;
//首页列表
@property (strong,nonatomic) PullingRefreshTableView *tableView;
//下拉刷新
@property (nonatomic) BOOL refreshing;

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *topView;

- (void)userInfoAction:(id)sender;

- (void)mapAction:(id)sender;

- (IBAction)search:(id)sender;
@end
