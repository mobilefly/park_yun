//
//  FLYOfflineMapViewController.h
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYOfflineMapViewController : FLYBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    UITextField *_searchText;
    UIButton *_searchBtn;
    
    UISegmentedControl *_segment;
    
    UIView *_cityView;
    UIView *_downloadView;
    
    UITableView *_cityTableView;
    UITableView *_downloadTableView;
    
    NSMutableArray *_cityData;
    NSMutableArray *_downloadData;
}

@end
