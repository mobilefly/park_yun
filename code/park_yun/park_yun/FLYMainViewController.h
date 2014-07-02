//
//  FLYMainViewController.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullingRefreshTableView.h"

@interface FLYMainViewController : UIViewController<PullingRefreshTableViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic)NSMutableArray *datas;

@property (strong,nonatomic) PullingRefreshTableView *tableView;
@property (nonatomic) BOOL refreshing;

@property (weak, nonatomic) IBOutlet UITextField *searchField;

- (IBAction)userInfoAction:(id)sender;

- (IBAction)mapAction:(id)sender;

- (IBAction)search:(id)sender;
@end
