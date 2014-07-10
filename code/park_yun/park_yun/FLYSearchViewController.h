//
//  FLYSearchViewController.h
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "BMapKit.h"

@interface FLYSearchViewController : FLYBaseViewController<BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    
    BMKPoiSearch  *_poiSearcher;
    BMKGeoCodeSearch *_codeSearcher;
    BMKLocationService *_locationService;
    CLLocation *_location;
    BOOL _firstLocation;
}

@property (strong, nonatomic)NSMutableArray *bussinessDatas;
@property (strong, nonatomic)NSMutableArray *datas;

@property(copy,nonatomic) NSString *searchText;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;

- (IBAction)backgroupTap:(id)sender;
@end
