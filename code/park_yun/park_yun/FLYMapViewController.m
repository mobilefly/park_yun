//
//  FLYMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMapViewController.h"
#import "FLYDataService.h"
#import "FLYPointAnnotation.h"

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
    
    //初始化BMKLocationService
    _locationService = [[BMKLocationService alloc]init];
    
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

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    [self updateUserLocation:userLocation];
}

#pragma mark - request
//停车场位置
- (void)requestLocationData{
    _isReload = NO;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%f",_mapBaseView.mapView.region.center.latitude] ,
                                   @"lat",
                                   [NSString stringWithFormat:@"%f",_mapBaseView.mapView.region.center.longitude],
                                   @"long",
                                   @"10000",
                                   @"range",
                                   nil];
    //防止循环引用
    __weak FLYMapViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryNearbySimplifyList params:params httpMethod:@"POST" completeBolck:^(id result){
        if (ref != nil) {
             [ref loadLocationData:result];
        }
    } errorBolck:^(){

    }];
}

#pragma mark - BMKMapViewDelegate delegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (_isReload) {
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
    [super viewWillAppear:animated];
    
    [_mapBaseView.mapView viewWillAppear];
    _mapBaseView.mapView.delegate = self;

    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
    
    _mapBaseView.mapDelegate = self;

}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_mapBaseView.mapView viewWillDisappear];
    _mapBaseView.mapView.delegate = nil;
    
    // 不用时，置nil
    [_locationService stopUserLocationService];
    _locationService.delegate = nil;
    
    _mapBaseView.mapDelegate = nil;
}

-(void)dealloc{
    
    if (_mapBaseView.mapView != nil) {
        _mapBaseView.mapView = nil;
    }
    
    if (_mapBaseView != nil) {
        _mapBaseView = nil;
    }
    NSLog(@"%s",__FUNCTION__);
}
@end
