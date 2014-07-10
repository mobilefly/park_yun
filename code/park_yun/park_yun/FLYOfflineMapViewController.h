//
//  FLYOfflineMapViewController.h
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "BMapKit.h"
#import "FLYCityCell.h"

@interface FLYOfflineMapViewController : FLYBaseViewController<UITableViewDelegate,UITableViewDataSource,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,BMKOfflineMapDelegate,FLYOfflineCellDelegate>{
    UITextField *_searchText;
    UIButton *_searchBtn;
    
    UISegmentedControl *_segment;
    
    UIView *_cityView;
    UIView *_downloadView;
    
    UITableView *_cityTableView;
    UITableView *_downloadTableView;
    
    NSMutableArray *_cityData;
    NSMutableArray *_downloadData;
    
    BMKOfflineMap *_offlineMap;
    BMKGeoCodeSearch *_codeSearcher;
    BMKLocationService *_locationService;
    CLLocation *_location;
    BOOL _firstLocation;
}
- (IBAction)backgroupTap:(id)sender;

@end
