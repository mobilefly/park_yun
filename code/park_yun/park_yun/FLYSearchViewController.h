//
//  FLYSearchViewController.h
//  park_yun
//
//  Created by chen on 14-7-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "BMapKit.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechConstant.h"

@interface FLYSearchViewController : FLYBaseViewController<BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,IFlyRecognizerViewDelegate,IFlySpeechSynthesizerDelegate>{
    
    BMKPoiSearch  *_poiSearcher;
    BMKGeoCodeSearch *_codeSearcher;
    BMKLocationService *_locationService;
    CLLocation *_location;
    BOOL _firstLocation;
    
    IFlyRecognizerView *_iflyRecognizerView;
    IFlySpeechSynthesizer *_iflySpeechSynthesizer;
}

@property (strong, nonatomic)NSMutableArray *bussinessDatas;
@property (strong, nonatomic)NSMutableArray *datas;

@property(copy,nonatomic) NSString *searchText;
@property (strong, nonatomic) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

- (IBAction)cancelAction:(id)sender;

- (IBAction)backgroupTap:(id)sender;
@end
