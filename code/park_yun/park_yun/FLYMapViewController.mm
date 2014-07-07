//
//  FLYMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMapViewController.h"
#import "FLYDataService.h"
#import "FLYAnnotationView.h"


#pragma mark - FLYMapViewController
@implementation FLYMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
        self.title = @"停车场地图";
    }
    return self;
}

-(void)_init{
    _isFollow = NO;
    _isLocation = NO;
    _isLoading = NO;
    _isClick = NO;
    _isFirstLoad = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapBaseView = [[FLYBaseMap alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44 - 20)];
    _mapBaseView.mapDelegate = self;
    [self.view addSubview:_mapBaseView];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        if ([_type isEqualToString:kAnnotationTypePark]) {
            if (self.annotationDics == nil) {
                self.annotationDics = [[NSMutableDictionary alloc] initWithCapacity:50];
            }
            FLYParkModel *parkModel = (FLYParkModel *)self.dataModel;
            //未添加过，需要添加
            if ([self.annotationDics objectForKey:parkModel.parkId] == nil) {
                FLYPointAnnotation *annotation = [[FLYPointAnnotation alloc]init];
                CLLocationCoordinate2D coor;
                coor.latitude = [parkModel.parkLat doubleValue];
                coor.longitude = [parkModel.parkLng doubleValue];
                annotation.coordinate = coor;
                annotation.data = parkModel;
                [_mapBaseView.mapView addAnnotation:annotation];
                [self.annotationDics setObject:annotation forKey:parkModel.parkId];
            }
        }else{
            // 添加一个PointAnnotation
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude = [_lat doubleValue];
            coor.longitude = [_lon doubleValue];
            annotation.coordinate = coor;
            [_mapBaseView.mapView addAnnotation:annotation];
        }
        [self performSelector:@selector(locationMap) withObject:nil afterDelay:1];
    }
    
}

- (void)locationMap{
    //定位
    if (_lat != nil && _lon != nil) {
        CLLocationCoordinate2D coordinate = {[_lat doubleValue],[_lon doubleValue]};
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(kMapRange,kMapRange));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
    }
}

#pragma mark - request
//停车场位置
- (void)requestLocationData{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [_lat stringValue] ,
                                   @"lat",
                                   [_lon stringValue],
                                   @"long",
                                   @"200000",
                                   @"range",
                                   nil];
    //防止循环引用
    __unsafe_unretained FLYMapViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryNearbySimplifyList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadLocationData:result];
    }];
}

//停车场位置
- (void)loadLocationData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *parks = [result objectForKey:@"parks"];
            
            NSMutableArray *parkList = [NSMutableArray arrayWithCapacity:parks.count];
            for (NSDictionary *parkDic in parks) {
                FLYParkModel *photoModel = [[FLYParkModel alloc] initWithDataDic:parkDic];
                [parkList addObject:photoModel];
            }
            if (self.locationDatas == nil) {
                self.locationDatas = parkList;
            }else{
                [self.locationDatas addObjectsFromArray:parkList];
            }
            _isLoading = NO;
        }
    }
}

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    [_mapBaseView.mapView updateLocationData:userLocation];
    
    [self updateUserLocation:userLocation];
}

#pragma mark - BMKMapViewDelegate delegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    
    if (self.locationDatas == nil || [self.locationDatas count] == 0) {
        if (!_isLoading) {
            _isLoading = YES;
            [self requestLocationData];
        }
        return;
    }
    [super regionChange:mapView];
}

#pragma mark - view other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapBaseView.mapView viewWillAppear];
    _mapBaseView.mapView.delegate = self;
    
    if (_locationService == nil) {
        //初始化BMKLocationService
        _locationService = [[BMKLocationService alloc]init];
        _locationService.delegate = self;
        //启动LocationService
        [_locationService startUserLocationService];
    }
}


-(void)viewWillDisappear:(BOOL)animated {
    
    [_mapBaseView.mapView viewWillDisappear];
    _mapBaseView.mapView.delegate = nil;
    
    // 不用时，置nil
    if (_locationService != nil) {
        [_locationService stopUserLocationService];
        _locationService.delegate = nil;
        _locationService = nil;
    }
    
    if (_routesearch != nil) {
        _routesearch.delegate = nil;
        _routesearch = nil;
    }
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    _mapBaseView.mapView = nil;
}
@end
