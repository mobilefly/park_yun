//
//  FLYShakeViewController.m
//  park_yun
//
//  Created by chen on 14-7-18.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYShakeViewController.h"
#import "FLYDataService.h"
#import "FLYParkModel.h"
#import "UIFactory.h"
#import "UIButton+Bootstrap.h"
#import <AudioToolbox/AudioToolbox.h>

#define shakeBorderColor Color(210, 210, 210, 1)

@interface FLYShakeViewController ()

@end

@implementation FLYShakeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"自动巡航";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化数据
    _index = 0;
    _datas = [NSMutableArray array];
    
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 275)];
    
    //加载中
    _loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_yaojiazaidaizi_all_0.png"]];
    _loadingView.frame = CGRectMake((_carousel.width - 110) / 2, (_carousel.height - 85) / 2, 110, 85);
    [self.view addSubview:_loadingView];

    
    //速率
    //_carousel.decelerationRate = 0.5;
    _carousel.type = iCarouselTypeLinear;
    _carousel.delegate = self;
    _carousel.dataSource = self;
    _carousel.hidden = YES;
    [self.view addSubview:_carousel];
    
    int freewidth =  ScreenHeight - 20 - 44 - 260;
    int mwidht = (freewidth - 35 - 80 - 30) / 2;
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_yaoxh_all_3.png"]];
    _imageView.frame = CGRectMake((ScreenWidth - 80) / 2, _carousel.bottom + mwidht , 80, 80);
    [self.view addSubview:_imageView];
    
    _autonavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _autonavBtn.tag = 111;
    _autonavBtn.frame = CGRectMake(30, _imageView.bottom + 10 , 260, 35);
    [_autonavBtn warningStyle];
    [_autonavBtn setTitle:@"开启巡航" forState:UIControlStateNormal];
    [_autonavBtn addTarget:self action:@selector(navAction) forControlEvents:UIControlEventTouchUpInside];
    _autonavBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:_autonavBtn];

    _locationService = [[BMKLocationService alloc]init];
    
    [self setNoDataViewFrame:_carousel.frame];
    [self navAction];
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self requestParkData];
    }else{
        [self showAlert:@"请打开网络"];
    }
}

#pragma mark Action
- (void)navAction{
    if ([_autonavBtn.titleLabel.text isEqualToString:@"开启巡航"]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
        _loadTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(requestMoreParkData) userInfo:nil repeats:YES];
        
        [_autonavBtn setTitle:@"巡航中" forState:UIControlStateNormal];
        [_autonavBtn primaryStyle];
    }else{
        [_timer invalidate];
        _timer = nil;
        
        [_loadTimer invalidate];
        _loadTimer = nil;
        
        [_autonavBtn setTitle:@"开启巡航" forState:UIControlStateNormal];
        [_autonavBtn warningStyle];
    }
}

- (void)timeAction:(NSTimer *)timer{

    if (_index == 4) {
        _index = 0;
    }
    
    if (_index == 0) {
        _imageView.image = [UIImage imageNamed:@"mfpparking_yaoxh_all_0.png"];
    }else if(_index == 1){
        _imageView.image = [UIImage imageNamed:@"mfpparking_yaoxh_all_1.png"];
    }else if(_index == 2){
        _imageView.image = [UIImage imageNamed:@"mfpparking_yaoxh_all_2.png"];
    }else if(_index == 3){
        _imageView.image = [UIImage imageNamed:@"mfpparking_yaoxh_all_3.png"];
    }
    _index ++;
    
}

#pragma mark - request
- (void)requestParkData{
    _isLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%f",_curCoordinate.latitude] ,
                                   @"lat",
                                   [NSString stringWithFormat:@"%f",_curCoordinate.longitude],
                                   @"long",
                                   @"200000",
                                   @"range",
                                   nil];
    
    [self showNoDataView:NO];
    _carousel.hidden = YES;
    _loadingView.hidden = NO;
    
    
    //防止循环引用
    __weak FLYShakeViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQuerySelfMotionParkList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadParkData:result];
    } errorBolck:^(){
        [ref loadParkError];
    }];
}

//加载更多
- (void)requestMoreParkData{
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showToast:@"巡航中"];
        
        if (!_isLoading) {
            _isLoading = YES;
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%f",_curCoordinate.latitude] ,
                                           @"lat",
                                           [NSString stringWithFormat:@"%f",_curCoordinate.longitude],
                                           @"long",
                                           @"200000",
                                           @"range",
                                           @"1",
                                           @"count",
                                           nil];
            
            
            //防止循环引用
            __weak FLYShakeViewController *ref = self;
            [FLYDataService requestWithURL:kHttpQuerySelfMotionParkList params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadMoreParkData:result];
            } errorBolck:^(){
                [ref loadParkError];
            }];
        }
        
    }else{
        [self showToast:@"请打开网络"];
    }
    
}


- (void)loadParkError{
    _isLoading = NO;
    [self showToast:@"连接失败"];
//    [FLYBaseUtil alertErrorMsg];
}


//停车场列表
- (void)loadParkData:(id)data{
    _isLoading = NO;
    
    _loadingView.hidden = YES;
    
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
            
            self.datas = parkList;
            
            if (self.datas != nil && [self.datas count] > 0) {
                _carousel.hidden = NO;
                [self showNoDataView:NO];
                [_carousel reloadData];
                [_carousel scrollToItemAtIndex:0 animated:YES];
            }else{
                _carousel.hidden = YES;
                [self showNoDataView:YES];
            }
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showToast:msg];
    }
}

-(void)loadMoreParkData:(id)data{
    _isLoading = NO;
    BOOL isNew = NO;
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *parks = [result objectForKey:@"parks"];
            
            if (parks != nil && [parks count] > 0) {
                FLYParkModel *parkModel = [[FLYParkModel alloc] initWithDataDic:[parks objectAtIndex:0]];
                
                if (_datas != nil && [_datas count] > 0) {
                    //删除之前重复的
                    for (int i=1; i< [_datas count]; i++) {
                        FLYParkModel *model = _datas[i];
                        if ([model.parkId isEqualToString:parkModel.parkId]) {
                            [_datas removeObjectAtIndex:i];
                            break;
                        }
                    }
                    
                    FLYParkModel *model = _datas[0];
                    
                    //添加新的
                    if (![model.parkId isEqualToString:parkModel.parkId]) {
                        isNew = YES;
                        [_datas insertObject:parkModel atIndex:0];
                    }
                    
                }
                //添加新的
                else{
                    isNew = YES;
                    [_datas insertObject:parkModel atIndex:0];
                }
                
                //重新加载
                if (self.datas != nil && [self.datas count] > 0) {
                    _carousel.hidden = NO;
                    [self showNoDataView:NO];
                    [_carousel reloadData];
                    [_carousel scrollToItemAtIndex:0 duration:1.0];
                    //[_carousel scrollToItemAtIndex:0 animated:YES];
                    
                    if (isNew || _carousel.currentItemIndex != 0) {
//                        if (isNew) {
                            //播放声音
                            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
                            NSURL *url = [NSURL fileURLWithPath:filePath];
                            SystemSoundID soundId;
                            AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &(soundId));
                            AudioServicesPlayAlertSound(soundId);
//                        }
                        
                        [self performSelector:@selector(scaleAnimation) withObject:nil afterDelay:1];
                    }
                    
                }
            }
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showToast:msg];
    }
}

//动画
-(void)scaleAnimation{
    UIView *view = [_carousel itemViewAtIndex:0];
    
    CGAffineTransform transform = view.transform;
    view.transform = CGAffineTransformScale(transform, 0.3, 0.3);
    view.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        view.transform = CGAffineTransformScale(transform, 1.1, 1.1);
        view.alpha = 1;
    } completion:^(BOOL finish){
        [UIView animateWithDuration:0.5 animations:^{
            view.transform = CGAffineTransformIdentity;
        }];
        
    }];
}

#pragma mark - iCarouselDataSource delegate
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.datas count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    UILabel *parknameLabel = nil;
    UILabel *addressLabel = nil;
    ThemeButton *enterBtn = nil;
    UIImageView *distanceImage = nil;
    UILabel *distanceLabel = nil;
    UILabel *distanceMLabel = nil;
    UIImageView *countImage = nil;
    UILabel *seatIdleLabel = nil;
    UILabel *capacityLabel = nil;
    UILabel *detailLabel = nil;
    ThemeButton *navBtn = nil;

    FLYParkModel *parkModel = [self.datas objectAtIndex:index];
    
	if (view == nil){
		view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 60, 255)];
        view.layer.borderWidth = 1;
        view.layer.borderColor = [shakeBorderColor CGColor];
        view.layer.cornerRadius = 5.0;
        view.layer.masksToBounds = YES;
        
        parknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, view.width - 10, 20)];
        parknameLabel.numberOfLines = 1;
        parknameLabel.tag = 101;
        parknameLabel.textColor = [UIColor darkGrayColor];
        [view addSubview:parknameLabel];
        
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, parknameLabel.bottom + 5, 160, 35)];
        addressLabel.numberOfLines = 2;
        addressLabel.textAlignment = NSTextAlignmentJustified;
        addressLabel.font = [UIFont systemFontOfSize:13.0];
        addressLabel.textColor = [UIColor grayColor];
        addressLabel.tag = 102;
        [view addSubview:addressLabel];
        
        enterBtn = [UIFactory createButton:@"mfpparking_yaorkzd_all_up.png" hightlight:@"mfpparking_yaorkzd_all_down.png"];
        enterBtn.frame = CGRectMake(addressLabel.right + 15, parknameLabel.bottom + 5, 54, 28);
        enterBtn.tag = 103;
        [view addSubview:enterBtn];
        
        //分割线
        UIView *sep = [[UIView alloc] init];
        sep.frame = CGRectMake(10, enterBtn.bottom + 10, view.width - 20, 1);
        sep.backgroundColor =  shakeBorderColor;
        [view addSubview:sep];
        
        
        distanceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_yaolocation_all_0.png"]];
        distanceImage.frame = CGRectMake(70, sep.bottom + 15, 13, 16);
        distanceImage.tag = 104;
        [view addSubview:distanceImage];
        
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(distanceImage.right + 10, distanceImage.bottom - 22, 0, 40)];
        distanceLabel.textColor = [UIColor orangeColor];
        distanceLabel.font = [UIFont boldSystemFontOfSize:22.0];
        distanceLabel.tag = 105;
        [view addSubview:distanceLabel];
        
        distanceMLabel = [[UILabel alloc] initWithFrame:CGRectMake(distanceLabel.right + 5, distanceImage.bottom - 22, 30, 30)];
        distanceMLabel.text = @"m";
        distanceMLabel.textColor = [UIColor lightGrayColor];
        distanceMLabel.font = [UIFont boldSystemFontOfSize:18.0];
        distanceMLabel.tag = 106;
        [view addSubview:distanceMLabel];
        
        countImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_p_all_0.png"]];
        countImage.frame = CGRectMake(69, distanceImage.bottom + 15, 16, 16);
        countImage.tag = 107;
        [view addSubview:countImage];
        
        seatIdleLabel = [[UILabel alloc] initWithFrame:CGRectMake(countImage.right + 9, countImage.bottom - 22, 0, 40)];
        seatIdleLabel.textColor = [UIColor orangeColor];
        seatIdleLabel.font = [UIFont boldSystemFontOfSize:22.0];
        seatIdleLabel.tag = 108;
        [view addSubview:seatIdleLabel];
        
        capacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(capacityLabel.right + 5, countImage.bottom - 22, 100, 30)];
        capacityLabel.textColor = [UIColor lightGrayColor];
        capacityLabel.font = [UIFont boldSystemFontOfSize:18.0];
        capacityLabel.tag = 109;
        [view addSubview:capacityLabel];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, seatIdleLabel.bottom - 15, view.width - 20, 60)];
        detailLabel.tag = 110;
        detailLabel.font = [UIFont systemFontOfSize:13.0];
        detailLabel.textAlignment = NSTextAlignmentJustified;
        detailLabel.textColor = [UIColor grayColor];
        detailLabel.numberOfLines = 3;
        [view addSubview:detailLabel];

        
        navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        navBtn.tag = 111;
        navBtn.frame = CGRectMake(10, view.bottom - 50, view.width - 20, 35);
        [navBtn primaryStyle];
        [navBtn setTitle:@"开始导航" forState:UIControlStateNormal];
        navBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [view addSubview:navBtn];
    }
    
    if (parkModel != nil) {
        parknameLabel = (UILabel *)[view viewWithTag:101];
        parknameLabel.text = parkModel.parkName;
        
        addressLabel = (UILabel *)[view viewWithTag:102];
        addressLabel.text = parkModel.parkAddress;
        
        distanceImage = (UIImageView *)[view viewWithTag:104];
        
        distanceLabel = (UILabel *)[view viewWithTag:105];
        BMKMapPoint point1 = BMKMapPointForCoordinate(_curCoordinate);
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([parkModel.parkLat doubleValue],[parkModel.parkLng doubleValue]));
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        if (distance > 1000) {
            distanceLabel.text = [NSString stringWithFormat:@"%.2fK",distance / 1000];
        }else{
            distanceLabel.text = [NSString stringWithFormat:@"%.0f",distance];
        }
        [distanceLabel sizeToFit];
        
        distanceMLabel = (UILabel *)[view viewWithTag:106];
        distanceMLabel.left = distanceLabel.right + 5;
        
        countImage = (UIImageView *)[view viewWithTag:107];
        seatIdleLabel = (UILabel *)[view viewWithTag:108];
        //加盟标示
        if ([parkModel.parkStatus isEqualToString:@"0"]) {
            seatIdleLabel.text = [NSString stringWithFormat:@"%i",[parkModel.seatIdle intValue]];
        }else if([parkModel.parkStatus isEqualToString:@"1"]){
            seatIdleLabel.text = @"-";
        }else{
            seatIdleLabel.text = @"-";
        }
        [seatIdleLabel sizeToFit];
        
        capacityLabel = (UILabel *)[view viewWithTag:109];
        capacityLabel.text = [NSString stringWithFormat:@"/ %i",[parkModel.parkCapacity intValue]];
        capacityLabel.left = seatIdleLabel.right + 5;
        
        detailLabel = (UILabel *)[view viewWithTag:110];
        detailLabel.text = parkModel.parkFeedesc;
    }
	return view;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    return 10;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	return 2;
}



#pragma mark - iCarouselDelegate delegate
- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    return YES;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return 280;
}


#pragma mark - BMKLocationServiceDelegate delegate
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation;
{
    self.curCoordinate = userLocation.location.coordinate;
}

#pragma mark - 摇动手势

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion == UIEventSubtypeMotionShake){
        [self requestParkData];
    }
}


#pragma mark - other
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //启动LocationService
    [_locationService startUserLocationService];
    
    [self becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //取消定时器
    [_timer invalidate];
    _timer = nil;
    
    [_loadTimer invalidate];
    _loadTimer = nil;
    
    [_autonavBtn setTitle:@"开启巡航" forState:UIControlStateNormal];
    [_autonavBtn warningStyle];
    
    [_locationService stopUserLocationService];
    _locationService.delegate = nil;
}

- (void)dealloc{
	_carousel.delegate = nil;
	_carousel.dataSource = nil;
    
    
    NSLog(@"%s",__FUNCTION__);
}


@end
