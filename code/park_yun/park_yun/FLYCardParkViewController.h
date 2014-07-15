//
//  FLYCardParkViewController.h
//  park_yun
//
//  Created by chen on 14-7-14.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "PullingRefreshTableView.h"

@interface FLYCardParkViewController : FLYBaseViewController<PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    //最后一次数据加载索引
    int _dataIndex;
    //数据是否全部加载完
    BOOL _isMore;
    
    int currentMaxDisplayedCell;
    int currentMaxDisplayedSection;
}

//列表
@property (strong,nonatomic) PullingRefreshTableView *tableView;
//table数据
@property (strong,nonatomic) NSMutableArray *datas;
//下拉刷新
@property (nonatomic) BOOL refreshing;


@property (strong, nonatomic) NSNumber* cellZoomXScaleFactor;
@property (strong, nonatomic) NSNumber* cellZoomYScaleFactor;
@property (strong, nonatomic) NSNumber* cellZoomXOffset;
@property (strong, nonatomic) NSNumber* cellZoomYOffset;
@property (strong, nonatomic) NSNumber* cellZoomInitialAlpha;
@property (strong, nonatomic) NSNumber* cellZoomAnimationDuration;
-(void)resetViewedCells;


@end
