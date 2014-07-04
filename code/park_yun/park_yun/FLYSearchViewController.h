//
//  FLYSearchViewController.h
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "BMapKit.h"

@interface FLYSearchViewController : FLYBaseViewController<BMKPoiSearchDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    BMKPoiSearch  *_searcher;
    BMKLocationService *_locationService;
    CLLocation *_location;
}

@property (strong, nonatomic)NSMutableArray *datas;
@property (assign, nonatomic)BOOL firstLocation;

@property(copy,nonatomic) NSString *searchText;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
