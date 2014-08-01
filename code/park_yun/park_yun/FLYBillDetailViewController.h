//
//  FLYBillDetailViewController.h
//  park_yun
//
//  Created by chen on 14-7-30.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "FLYOrderModel.h"

@interface FLYBillDetailViewController : FLYBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *_datas;
    FLYOrderModel *_orderModel;
    
}

@property (nonatomic,copy) NSString *orderId;

@end
