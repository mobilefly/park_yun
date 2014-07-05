//
//  FLYMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMapViewController.h"
#import "FLYPointAnnotation.h"
#import "FLYDataService.h"

@interface FLYMapViewController ()

@end

@implementation FLYMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isBackButton = NO;
        self.isCancelButton = YES;
        
        _isFollow = NO;
        _isLocation = NO;
        _isLoading = NO;

        
        self.title = @"停车场地图";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapBaseView = [[FLYBaseMap alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44 - 20)];
    _mapBaseView.mapDelegate = self;
    [self.view addSubview:_mapBaseView];
}

- (void) viewDidAppear:(BOOL)animated {
    // 添加一个PointAnnotation
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = [_lat doubleValue];
    coor.longitude = [_lon doubleValue];
    annotation.coordinate = coor;
    [_mapBaseView.mapView addAnnotation:annotation];
    
    [self performSelector:@selector(locationMap) withObject:nil afterDelay:1];

}

- (void)locationMap{
    //定位
    if (_lat != nil && _lon != nil) {
        CLLocationCoordinate2D coordinate = {[_lat doubleValue],[_lon doubleValue]};
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(0.02f,0.02f));
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
//    [self requestLocationData];
    
    //跟随、定位
    if (_isFollow) {
        
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
    }else if(_isLocation){
        
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(userLocation.location.coordinate, BMKCoordinateSpanMake(0.02f,0.02f));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
        _isLocation = NO;
        
    }
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
    
    if (mapView.zoomLevel < 15.5) {
        return;
    }
    
    double curLat = mapView.region.center.latitude;
    double curLon = mapView.region.center.longitude;
    
    if (lastLat == 0.0 || lastLon == 0.0) {
        lastLat = curLat;
        lastLon = curLon;
    }else{
        BMKMapPoint point1 = BMKMapPointForCoordinate(mapView.region.center);
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lastLat,lastLon));
        
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        if (distance < 2500) {
            return;
        }
        lastLat = curLat;
        lastLon = curLon;
    }
    
    
    for (FLYParkModel *park in self.locationDatas) {
        double parkLat = [park.parkLat doubleValue];
        double parkLng = [park.parkLng doubleValue];
        
        BMKMapPoint point1 = BMKMapPointForCoordinate(mapView.region.center);
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(parkLat,parkLng));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        
        if (self.annotationDics == nil) {
            self.annotationDics = [[NSMutableDictionary alloc] initWithCapacity:50];
        }
        
        if (distance < 3000) {
            //未添加过，需要添加
            if ([self.annotationDics objectForKey:park.parkId] == nil) {
                FLYPointAnnotation *annotation = [[FLYPointAnnotation alloc]init];
                CLLocationCoordinate2D coor;
                coor.latitude = parkLat;
                coor.longitude = parkLng;
                annotation.coordinate = coor;
                annotation.parkModel = park;
                [_mapBaseView.mapView addAnnotation:annotation];
                [self.annotationDics setObject:annotation forKey:park.parkId];
            }
        }else{
            //添加过，需要移除
            if ([self.annotationDics objectForKey:park.parkId] != nil) {
                FLYPointAnnotation *annotation = [self.annotationDics objectForKey:park.parkId];
                [_mapBaseView.mapView removeAnnotation:annotation];
                [self.annotationDics removeObjectForKey:park.parkId];
            }
        }
    }
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //移动标记
    if ([annotation isKindOfClass:[FLYPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"flyAnnotation"];
        
        annotationView.pinColor = BMKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;// 设置该标注点动画显示
        annotationView.canShowCallout = false;
        
        FLYParkModel *parkModel =  ((FLYPointAnnotation *)annotation).parkModel;
        UIImage *image = nil;
        //路边
        if ([parkModel.parkType isEqualToString:@"1"]) {
            //签约
            if ([parkModel.parkStatus isEqualToString:@"0"]) {
                if ([parkModel.seatIdle intValue] > 100) {
                    image = [UIImage imageNamed:@"mfpparking_lb2_all_0.png"];
                }else if([parkModel.seatIdle intValue] > 20){
                    image = [UIImage imageNamed:@"mfpparking_lb3_all_0.png"];
                }else{
                    image = [UIImage imageNamed:@"mfpparking_lb1_all_0.png"];
                }
            }else{
                image = [UIImage imageNamed:@"mfpparking_lb4_all_0.png"];
            }
        }else{
            //签约
            if ([parkModel.parkStatus isEqualToString:@"0"]) {
                if ([parkModel.seatIdle intValue] > 100) {
                    image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
                }else if([parkModel.seatIdle intValue] > 20){
                    image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
                }else{
                    image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
                }
            }else{
                image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
            }
        }
        annotationView.image = image;
        return annotationView;
    }
    //默认
    else if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"flyAnnotation"];
        annotationView.pinColor = BMKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;// 设置该标注点动画显示
        return annotationView;
    }
    
    return nil;
}

#pragma mark - FLYMapDelegate delegate
//跟随
- (void)mapFollow:(BOOL)enable{
    _isFollow = enable;
}

//定位
- (void)mapLocation{
    _isLocation = YES;
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
//    _mapBaseView.mapDelegate = nil;
    
    // 不用时，置nil
    if (_locationService != nil) {
        [_locationService stopUserLocationService];
        _locationService.delegate = nil;
        _locationService = nil;
    }
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
@end
