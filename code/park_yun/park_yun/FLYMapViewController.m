//
//  FLYMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMapViewController.h"

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

        
        self.title = @"停车场地图";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //初始化BMKLocationService
    _locationService = [[BMKLocationService alloc]init];
    _locationService.delegate = self;
    //启动LocationService
    [_locationService startUserLocationService];
    
    
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

#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    [_mapBaseView.mapView updateLocationData:userLocation];
    

    
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
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
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
    // 此处记得不用的时候需要置nil，否则影响内存的释放
    

}


-(void)viewWillDisappear:(BOOL)animated {
    [_mapBaseView.mapView viewWillDisappear];
    _mapBaseView.mapView.delegate = nil;
    // 不用时，置nil
}

-(void)dealloc{
    [_locationService stopUserLocationService];
    _locationService = nil;
}



@end
