//
//  FLYBaseMapViewController.m
//  park_yun
//
//  Created by chen on 14-7-7.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseMapViewController.h"
#import "UIButton+Bootstrap.h"
#import "FLYParkDetailViewController.h"
#import "FLYAnnotationView.h"
#import "FLYPointAnnotation.h"
#import "FLYGateViewController.h"
#import "FLYCityAnnotation.h"
#import "FLYCityAnnotationView.h"
#import "FLYRegionParkModel.h"
#import "FLYDBUtil.h"
#import "FLYDataService.h"


#pragma mark - RouteAnnotation
@implementation RouteAnnotation
@synthesize type = _type;
@synthesize degree = _degree;
@end

#pragma mark - UIImage
@implementation UIImage(InternalMethod)
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees
{
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
	CGSize rotatedSize;
    rotatedSize.width = width;
    rotatedSize.height = height;
    
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end


#pragma mark - FLYBaseMapViewController
@interface FLYBaseMapViewController ()

@end

@implementation FLYBaseMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isParkLevel = NO;
        _isReload = YES;
        _aLevel = @"park";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _routesearch = [[BMKRouteSearch alloc]init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -  UI
//绘制标记面板
- (void)renderParkInfo{
    _parkInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, _mapBaseView.height, 320, kParkInfoHight)];
    _parkInfoView.backgroundColor = [UIColor whiteColor];
    _parkInfoView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _parkInfoView.layer.shadowOffset = CGSizeMake(0, -1);
    _parkInfoView.layer.shadowOpacity = 0.6; //不透明
    
    UILabel *parkNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
    parkNameLabel.backgroundColor = [UIColor clearColor];
    parkNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    parkNameLabel.textColor = [UIColor darkGrayColor];
    parkNameLabel.numberOfLines = 1;
    parkNameLabel.tag = 101;
    [_parkInfoView addSubview:parkNameLabel];
    
    UIImageView *distanceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_location_all_0.png"]];
    distanceImage.frame = CGRectMake(parkNameLabel.right + 10, 10, 13, 16);
    distanceImage.tag = 102;
    [_parkInfoView addSubview:distanceImage];
    
    UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(distanceImage.right + 2, 10, 0, 20)];
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.font = [UIFont systemFontOfSize:18.0];
    distanceLabel.textColor = [UIColor orangeColor];
    distanceLabel.numberOfLines = 1;
    distanceLabel.tag = 103;
    [_parkInfoView addSubview:distanceLabel];
    
    UIImageView *statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_p_all_0.png"]];
    statusImage.frame = CGRectMake(15, parkNameLabel.bottom + 10, 16, 16);
    statusImage.tag = 104;
    [_parkInfoView addSubview:statusImage];
    
    
    UILabel *seatIdleLabel = [[UILabel alloc] initWithFrame:CGRectMake(statusImage.right + 5, parkNameLabel.bottom + 10, 0, 0)];
    seatIdleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    seatIdleLabel.textColor = kBlueColor;
    seatIdleLabel.numberOfLines = 1;
    seatIdleLabel.tag = 105;
    [_parkInfoView addSubview:seatIdleLabel];
    
    UILabel *capacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(seatIdleLabel.right + 2, parkNameLabel.bottom + 10, 0, 0)];
    capacityLabel.font = [UIFont systemFontOfSize:15.0];
    capacityLabel.textColor = [UIColor grayColor];
    capacityLabel.numberOfLines = 1;
    capacityLabel.tag = 106;
    [_parkInfoView addSubview:capacityLabel];
    
    
    UIImageView *freeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_mian_all_0.png"]];
    freeImage.frame = CGRectMake(135, parkNameLabel.bottom + 10, 16, 16);
    freeImage.tag = 107;
    [_parkInfoView addSubview:freeImage];
    
    
    UILabel *freeTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(freeImage.right + 5, parkNameLabel.bottom + 10, 0, 0)];
    freeTimeLabel.font = [UIFont boldSystemFontOfSize:16.0];
    freeTimeLabel.textColor = kBlueColor;
    freeTimeLabel.numberOfLines = 1;
    freeTimeLabel.tag = 108;
    [_parkInfoView addSubview:freeTimeLabel];
    
    UILabel *freeLabel = [[UILabel alloc] initWithFrame:CGRectMake(freeImage.right + 5, parkNameLabel.bottom + 10, 0, 0)];
    freeLabel.font = [UIFont systemFontOfSize:15.0];
    freeLabel.text = @"分钟";
    freeLabel.textColor = [UIColor grayColor];
    freeLabel.numberOfLines = 1;
    freeLabel.tag = 109;
    [freeLabel sizeToFit];
    [_parkInfoView addSubview:freeLabel];
    
    UIImageView *freeLevelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_rmb2_all_0.png"]];
    freeLevelImage.frame = CGRectMake(ScreenWidth - 60 - 15, parkNameLabel.bottom + 5, 60, 24);
    freeLevelImage.tag = 110;
    [_parkInfoView addSubview:freeLevelImage];
    
    //按钮
    UIButton *entranceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    entranceBtn.frame = CGRectMake(15, freeImage.bottom + 15, 90, 35);
    [entranceBtn defaultStyle];
    [entranceBtn setTitle:@"入口引导" forState:UIControlStateNormal];
    entranceBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [entranceBtn addTarget:self action:@selector(gateAction:) forControlEvents:UIControlEventTouchUpInside];
    entranceBtn.tag = 111;
    [_parkInfoView addSubview:entranceBtn];
    
    UIButton *navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navBtn.frame = CGRectMake(entranceBtn.right + 10, freeImage.bottom + 15, 90, 35);
    [navBtn defaultStyle];
    [navBtn setTitle:@"行车路线" forState:UIControlStateNormal];
    navBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navBtn.tag = 112;
    [navBtn addTarget:self action:@selector(navAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [navBtn addAwesomeIcon:FAIconRoad beforeTitle:YES];
    [_parkInfoView addSubview:navBtn];
    
    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    detailBtn.frame = CGRectMake(navBtn.right + 10, freeImage.bottom + 15, 90, 35);
    [detailBtn defaultStyle];
    [detailBtn setTitle:@"详情" forState:UIControlStateNormal];
    detailBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    detailBtn.tag = 113;
    //    [detailBtn addAwesomeIcon:FAIconRoad beforeTitle:YES];
    [detailBtn addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
    [_parkInfoView addSubview:detailBtn];
    
    [_mapBaseView addSubview:_parkInfoView];
}


//获取导航路线图标
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
	BMKAnnotationView *view = nil;
	switch (routeAnnotation.type) {
		case 0:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getBundlePath:@"images/icon_nav_start.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 1:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getBundlePath:@"images/icon_nav_end.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 2:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getBundlePath:@"images/icon_nav_bus.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 3:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getBundlePath:@"images/icon_nav_rail.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 4:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage *image = [UIImage imageWithContentsOfFile:[self getBundlePath:@"images/icon_direction.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
			
		}
			break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage *image = [UIImage imageWithContentsOfFile:[self getBundlePath:@"images/icon_nav_waypoint.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
        }
            break;
		default:
			break;
	}
    return view;
}

#pragma mark - Action
//详情
- (void)detailAction:(UIButton *)button{
    FLYParkDetailViewController *detail = [[FLYParkDetailViewController alloc] init];
    detail.parkId = _curModel.parkId;
    detail.showLocation = NO;
    [self.navigationController pushViewController:detail animated:NO];
}

//导航
- (void)navAction:(UIButton *)button{
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    start.pt = appDelegate.coordinate;
    
	BMKPlanNode *end = [[BMKPlanNode alloc]init];
    CLLocationCoordinate2D coor2D = {[_curModel.parkLat doubleValue],[_curModel.parkLng doubleValue]};
    end.pt = coor2D;
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        [self showToast:@"未检索到导航路线"];
        NSLog(@"car检索发送失败");
    }
}

- (void)gateAction:(UIButton *)button{

    FLYGateViewController *gateCtrl = [[FLYGateViewController alloc] init];
    
    gateCtrl.parkModel = _curModel;
    [self.navigationController pushViewController:gateCtrl animated:NO];
}


#pragma mark - BMKRouteSearchDelegate delegate
//驾车导航
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error{
    
    for (id annotation in self.routeAnnotations) {
        [_mapBaseView.mapView removeAnnotation:annotation];
    }
    self.routeAnnotations = nil;
    
    if (self.routeOverlay != nil) {
        [_mapBaseView.mapView removeOverlay:self.routeOverlay];
        self.routeOverlay = nil;
    }
    
    if (self.routeAnnotations == nil) {
        self.routeAnnotations = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    _mapBaseView.navigationBtn.hidden = NO;
    
	if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine *plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
		NSInteger size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation *item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapBaseView.mapView addAnnotation:item]; // 添加起点标注
                
                [self.routeAnnotations addObject:item];
                
            }else if(i==size-1){
                RouteAnnotation *item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapBaseView.mapView addAnnotation:item]; // 添加起点标注
                
                [self.routeAnnotations addObject:item];
            }
            //添加annotation节点
            RouteAnnotation *item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapBaseView.mapView addAnnotation:item];
            
            [self.routeAnnotations addObject:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode *tempNode in plan.wayPoints) {
                RouteAnnotation *item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapBaseView.mapView addAnnotation:item];
                
                [self.routeAnnotations addObject:item];
            }
        }
        
        //轨迹点
        BMKMapPoint *temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        
        
        // 通过points构建BMKPolyline
		BMKPolyline *polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapBaseView.mapView addOverlay:polyLine]; // 添加路线overlay
        
        self.routeOverlay = polyLine;
        
        delete []temppoints;
        
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        
        //定位当前地点
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(appDelegate.coordinate, BMKCoordinateSpanMake(kMapRange,kMapRange));
        BMKCoordinateRegion adjustedRegion = [_mapBaseView.mapView regionThatFits:viewRegion];
        [_mapBaseView.mapView setRegion:adjustedRegion animated:YES];
    }
}

#pragma mark - BMKMapViewDelegate delegate
//绘制标记
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //移动标记
    if ([annotation isKindOfClass:[FLYPointAnnotation class]]) {
        FLYAnnotationView *annotationView = [[FLYAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"flyAnnotation"];
        annotationView.pinColor = BMKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;// 设置该标注点动画显示
        annotationView.canShowCallout = false;
        
        FLYParkModel *parkModel =  ((FLYPointAnnotation *)annotation).data;
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
                    image = [UIImage imageNamed:@"mfpparking_tcc2_all_0.png"];
                }else if([parkModel.seatIdle intValue] > 20){
                    image = [UIImage imageNamed:@"mfpparking_tcc3_all_0.png"];
                }else{
                    image = [UIImage imageNamed:@"mfpparking_tcc1_all_0.png"];
                }
            }else{
                image = [UIImage imageNamed:@"mfpparking_tcc4_all_0.png"];
            }
        }
        annotationView.data = parkModel;
        annotationView.image = image;
        return annotationView;
    }
    //导航
    else if ([annotation isKindOfClass:[RouteAnnotation class]]) {
		return [self getRouteAnnotationView:mapView viewForAnnotation:(RouteAnnotation*)annotation];
	}
    
    //城市
    else if ([annotation isKindOfClass:[FLYCityAnnotation class]]) {
        FLYCityAnnotationView *annotationView = [[FLYCityAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"cityAnnotation"];
        
        FLYRegionParkModel *regionModel =  ((FLYCityAnnotation *)annotation).regionModel;
        annotationView.regionModel = regionModel;
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


//选中标记
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    if ([view isKindOfClass:[FLYAnnotationView class]]) {
        FLYAnnotationView *annotationView = (FLYAnnotationView *)view;
        FLYParkModel *model = annotationView.data; 
        
        if (_parkInfoView == nil) {
            [self renderParkInfo];
        }
        
        UILabel *parkNameLabel = (UILabel *)[_parkInfoView viewWithTag:101];
        UIImageView *distanceImage = (UIImageView *)[_parkInfoView viewWithTag:102];
        UILabel *distanceLabel = (UILabel *)[_parkInfoView viewWithTag:103];
        UILabel *seatIdleLabel = (UILabel *)[_parkInfoView viewWithTag:105];
        UILabel *capacityLabel = (UILabel *)[_parkInfoView viewWithTag:106];
        UILabel *freeTimeLabel = (UILabel *)[_parkInfoView viewWithTag:108];
        UILabel *freeLabel = (UILabel *)[_parkInfoView viewWithTag:109];
        UIImageView *freeLevelImage = (UIImageView *)[_parkInfoView viewWithTag:110];
        
        //名称
        parkNameLabel.text = model.parkName;
        
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        
        //距离
        BMKMapPoint point1 = BMKMapPointForCoordinate(appDelegate.coordinate);
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([model.parkLat doubleValue],[model.parkLng doubleValue]));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        if (distance > 1000) {
            distanceLabel.text = [NSString stringWithFormat:@"%.1fKM",distance / 1000];
        }else{
            distanceLabel.text = [NSString stringWithFormat:@"%.0fM",distance];
        }
        [distanceLabel sizeToFit];
        distanceLabel.right = ScreenWidth - 15;
        
        distanceImage.left = distanceLabel.left - 15;
        
        //空位数
        if ([model.parkStatus isEqualToString:@"0"]) {
            seatIdleLabel.text = [model.seatIdle stringValue];
        }else if([model.parkStatus isEqualToString:@"1"]){
            seatIdleLabel.text = @"-";
        }else{
            seatIdleLabel.text = @"-";
        }
        [seatIdleLabel sizeToFit];
        //容量
        capacityLabel.text =  [NSString stringWithFormat:@"%@%@",@"/ ",[model.parkCapacity stringValue]];
        [capacityLabel sizeToFit];
        capacityLabel.left = seatIdleLabel.right + 3;
        
        //免费时间
        if ([model.parkFreetime intValue] == -1) {
            freeTimeLabel.text = @"全天免费";
            [freeTimeLabel sizeToFit];
            freeLabel.hidden = YES;
        }else{
            freeTimeLabel.text = [model.parkFreetime stringValue];
            [freeTimeLabel sizeToFit];
            freeLabel.left = freeTimeLabel.right + 2;
            freeLabel.hidden = NO;
        }
        
       
        
        //收费评级
        if ([model.parkFeelevel isEqualToString:@"0"]) {
            freeLevelImage.image = [UIImage imageNamed:@"mfpparking_rmb_all_0.png"];
        }else if([model.parkFeelevel isEqualToString:@"1"]){
            freeLevelImage.image = [UIImage imageNamed:@"mfpparking_rmb2_all_0.png"];
        }else if([model.parkFeelevel isEqualToString:@"2"]){
            freeLevelImage.image = [UIImage imageNamed:@"mfpparking_rmb3_all_0.png"];
        }
        
        _curModel = model;
        
        if (!_isClick) {
            _isClick = YES;
            [UIView animateWithDuration:0.4 animations:^{
                _parkInfoView.transform = CGAffineTransformTranslate(_parkInfoView.transform,0 , -kParkInfoHight);
                _mapBaseView.zoomInBtn.transform = CGAffineTransformMakeTranslation(0 , -kParkInfoHight);
                _mapBaseView.zoomOutBtn.transform = CGAffineTransformMakeTranslation(0 , -kParkInfoHight);
                _mapBaseView.locationBtn.transform = CGAffineTransformMakeTranslation(0 , -kParkInfoHight);
                _mapBaseView.followBtn.transform = CGAffineTransformMakeTranslation(0 , -kParkInfoHight);
                _mapBaseView.navigationBtn.transform = CGAffineTransformMakeTranslation(0, -kParkInfoHight);
            }];
        }
    }
}

/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    if (_isClick) {
        [UIView animateWithDuration:0.4 animations:^{
            _mapBaseView.zoomInBtn.transform = CGAffineTransformIdentity;
            _mapBaseView.zoomOutBtn.transform = CGAffineTransformIdentity;
            _mapBaseView.locationBtn.transform = CGAffineTransformIdentity;
            _mapBaseView.followBtn.transform = CGAffineTransformIdentity;
            _mapBaseView.navigationBtn.transform = CGAffineTransformIdentity;
            
            _parkInfoView.transform = CGAffineTransformIdentity;
            
            _isClick = NO;
        }];
    }
}

//绘制导航线
- (BMKOverlayView *)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
	return nil;
}

#pragma mark - FLYMapDelegate delegate
//跟随
- (void)mapFollow:(BOOL)enable{
    _isMapFollow = enable;
    
    if (enable) {
        _mapBaseView.mapView.showsUserLocation = NO;
        _mapBaseView.mapView.userTrackingMode = BMKUserTrackingModeFollow;
        _mapBaseView.mapView.showsUserLocation = YES;
    }else{
        _mapBaseView.mapView.showsUserLocation = NO;
        _mapBaseView.mapView.userTrackingMode = BMKUserTrackingModeNone;
        _mapBaseView.mapView.showsUserLocation = YES;
    }
}

//定位
- (void)mapLocation{
    _isMapLocation = YES;
}

//取消导航
- (void)mapNavigation{
    for (id annotation in self.routeAnnotations) {
        [_mapBaseView.mapView removeAnnotation:annotation];
    }
    self.routeAnnotations = nil;
    
    if (self.routeOverlay != nil) {
        [_mapBaseView.mapView removeOverlay:self.routeOverlay];
        self.routeOverlay = nil;
    }
    _mapBaseView.navigationBtn.hidden = YES;
}

#pragma mark - util
- (NSString *)getBundlePath:(NSString *)filename
{
	
	NSBundle *libBundle = kBUNDLE;
	if (libBundle && filename){
		NSString *file=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
		return file;
	}
	return nil ;
}


#pragma mark - child
//地图滑动、放大、缩小
- (void)regionChange:(BMKMapView *)mapView{
    NSLog(@"zoomLevel:%f",mapView.zoomLevel);
    if (mapView.zoomLevel < 16) {
        if ([_aLevel isEqualToString:@"park"]) {
            _aLevel = @"city";
            
            if (self.annotationDics != nil) {
                for (NSString *key in self.annotationDics) {
                    FLYPointAnnotation *annotation = [self.annotationDics objectForKey:key];
                    [_mapBaseView.mapView removeAnnotation:annotation];
                }
                self.annotationDics = nil;
            }
            
            
            if (self.regionArray == nil) {
                self.regionArray = [[NSMutableArray alloc] initWithCapacity:20];
            }
            
            FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
            if (appDelegate.cityDatas != nil && [appDelegate.cityDatas count] > 0) {
                for (FLYRegionParkModel *regionModel in appDelegate.cityDatas) {
                    FLYCityAnnotation *annotation = [[FLYCityAnnotation alloc]init];
                    annotation.regionModel = regionModel;
                    annotation.coordinate = {[regionModel.regionLat doubleValue],[regionModel.regionLng doubleValue]};
                    [_mapBaseView.mapView addAnnotation:annotation];
                    
                    [self.regionArray addObject:annotation];
                }
            }
            
        }
        return;
    }else{
        if ([_aLevel isEqualToString:@"city"]) {
            _aLevel = @"park";
            _isParkLevel = YES;
            
            for (FLYCityAnnotation *annotation in self.regionArray) {
                [_mapBaseView.mapView removeAnnotation:annotation];
            }
            self.regionArray = nil;
        }
    }
    
    //屏幕中心点位置
    double curLat = mapView.region.center.latitude;
    double curLon = mapView.region.center.longitude;
    
    if (lastMarkLat == 0.0 || lastMarkLon == 0.0) {
        lastLoadingLat = curLat;
        lastLoadingLon = curLon;
        lastMarkLat = curLat;
        lastMarkLon = curLon;
        
        _isReload = true;
    }else{
        BMKMapPoint point1 = BMKMapPointForCoordinate(mapView.region.center);
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lastMarkLat,lastMarkLon));
        BMKMapPoint point3 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lastLoadingLat,lastLoadingLon));

        //计算距离上次重新绘制距离
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        //计算距离上次重新加载距离
        CLLocationDistance distance2 = BMKMetersBetweenMapPoints(point1,point3);
        NSLog(@"distance:%f",distance);
        
        if(distance2 > 9000 && ![FLYBaseUtil isOffline]){
            lastLoadingLat = curLat;
            lastLoadingLon = curLon;
            _isReload = true;
        }
        
        if (_isReload) {
            return;
        }
        if (distance < 1000) {
            if (_isParkLevel) {
                _isParkLevel = NO;
            }else{
                return;
            }
        }
       
        lastMarkLat = curLat;
        lastMarkLon = curLon;
        
    }
    
    //绘制标记
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
                annotation.data = park;
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


//停车场位置
- (void)loadLocationData:(id)data{
    self.locationDatas = nil;
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
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

#pragma mark - request
//停车场位置
- (void)requestLocationData{
    if ([FLYBaseUtil isOffline]) {
        _isReload = NO;
        NSString *city = [FLYBaseUtil getCity];
        self.locationDatas = [FLYDBUtil queryParkList:city];
        _isLoading = NO;
    }else{
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
        __weak FLYBaseMapViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryNearbySimplifyList params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadLocationData:result];
        } errorBolck:^(){
            
        }];
    }
}


#pragma mark - other

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _routesearch.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    _routesearch.delegate = nil;
}


-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    _mapBaseView.mapView = nil;
}


@end
