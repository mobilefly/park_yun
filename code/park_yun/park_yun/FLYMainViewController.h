//
//  FLYMainViewController.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullingRefreshTableView.h"
#import "BMapKit.h"
#import "FLYBaseViewController.h"
#import "ThemeButton.h"
#import "FLYBaseMap.h"


@interface FLYMainViewController : FLYBaseViewController<PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource,BMKMapViewDelegate,BMKLocationServiceDelegate,FLYMapDelegate>{
    
    FLYBaseMap *_mapBaseView;
    BMKLocationService *_locationService;
    
    //当前经纬度
    NSNumber *_lat;
    NSNumber *_lon;
    //
    BOOL _firstFlag;
    int _dataIndex;
    BOOL _isMore;
    
    BOOL _isFollow;
    BOOL _isLocation;
}

@property (strong, nonatomic)NSMutableArray *datas;

@property (strong,nonatomic) PullingRefreshTableView *tableView;
@property (nonatomic) BOOL refreshing;

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *topView;

- (void)userInfoAction:(id)sender;

- (void)mapAction:(id)sender;

- (IBAction)search:(id)sender;
@end
