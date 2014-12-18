//
//  FLYParkCardShopViewController.h
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "FLYParkCardShopCell.h"

@interface FLYParkCardShopViewController : FLYBaseViewController<UITableViewDataSource,UITableViewDelegate,FLYParkCardShopDelegate>{
    UITableView *_tableView;
    UILabel *_carNoLabel;
    UILabel *_totalPirceLabel;
    UIButton *_buyButton;
}

//首页列表数据
@property (strong, nonatomic) NSMutableArray *datas;

@end
