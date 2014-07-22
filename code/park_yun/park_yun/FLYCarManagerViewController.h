//
//  FLYCarLManageViewController.h
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYCarManagerViewController : FLYBaseViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    
    NSString *_defaultCarno;
}

//首页列表数据
@property (strong, nonatomic) NSMutableArray *datas;

@end
