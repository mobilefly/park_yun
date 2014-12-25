//
//  FLYCouponViewController.h
//  park_yun
//
//  Created by chen on 14-12-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYCouponViewController : FLYBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    UIView *_curView;
    UIView *_hisView;
    UISegmentedControl *_segment;
    UIImageView *_curNoDataImage;
    UIImageView *_hisNoDataImage;
}

//列表
@property (strong,nonatomic) UITableView *curTableView;
@property (strong,nonatomic) UITableView *hisTableView;

//table数据
@property (strong,nonatomic) NSMutableArray *curDatas;

@property (strong,nonatomic) NSMutableArray *hisDatas;

//下拉刷新
@property (nonatomic) BOOL refreshing;

@end
