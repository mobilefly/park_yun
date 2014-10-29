//
//  FLYShakeViewController.m
//  park_yun
//
//  Created by chen on 14-7-18.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYShakeViewController.h"
#import "FLYGateViewController.h"
#import "FLYParkModel.h"
#import "FLYDataService.h"
#import "UIFactory.h"
#import "UIButton+Bootstrap.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MapKit/MapKit.h>


#define shakeBgColor Color(55, 67, 84, 1)
#define shakeBorderColor Color(210, 210, 210, 1)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

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
    
    // 创建语音合成对象,为单例模式
    _iflySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iflySpeechSynthesizer.delegate = self;
    [_iflySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    [_iflySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]];
    [_iflySpeechSynthesizer setParameter:@"xiaoyan" forKey: [IFlySpeechConstant VOICE_NAME]];
    [_iflySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
    [_iflySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    
    //初始化数据
    _index = 0;
    _isClose = NO;
    _navType = @"0";
    _datas = [NSMutableArray array];
    
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 300)];
    //速率
    _carousel.decelerationRate = 0.5;
    _carousel.type = iCarouselTypeLinear;
    _carousel.delegate = self;
    _carousel.dataSource = self;
    _carousel.hidden = YES;
    [self.view addSubview:_carousel];
    if (ScreenHeight == 568) {
        _carousel.top = _carousel.top + 50;
    }
    
    //加载中
    _loadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_yaojiazaidaizi_all_0.png"]];
    _loadingView.frame = CGRectMake((_carousel.width - 110) / 2, (_carousel.height - 85) / 2, 110, 85);
    if (ScreenHeight == 568) {
        _loadingView.top = _loadingView.top + 50;
    }
    [self.view addSubview:_loadingView];
    
    //下部蓝色背景
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 100 - 20 - 44, 320, 100)];
    bottomView.backgroundColor = shakeBgColor;
    [self.view addSubview:bottomView];
    UIImageView *btView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_yaosanjiao_all_0_02.png"]];
    btView.bottom = bottomView.top;
    [self.view addSubview:btView];
    
    //点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapNavAction:)];
    [tapGesture setNumberOfTapsRequired:1];

    //自动导航
    _autonavView = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - 100) / 2, 0, 100, 100)];
    _autonavView.userInteractionEnabled = YES;
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [bgImgView setImage:[UIImage imageNamed:@"mfpparking_yaoyiyaoxz_all_0.png"]];
    [_autonavView addSubview:bgImgView];
    [bottomView addSubview:_autonavView];
    //点击事件
    [_autonavView addGestureRecognizer:tapGesture];
    
    //自动巡航文字
    _autonavLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _autonavLabel.text = @"开始巡航";
    _autonavLabel.textColor = [UIColor whiteColor];
    _autonavLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [_autonavLabel sizeToFit];
    _autonavLabel.frame = CGRectMake((ScreenWidth - _autonavLabel.width) / 2, 40, _autonavLabel.width, _autonavLabel.height);
    [bottomView addSubview:_autonavLabel];
    
    //停车类型按钮
    _parkTypeBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, (100 - 47) / 2, 47, 47)];
    _parkTypeBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    [_parkTypeBtn addTarget:self action:@selector(parkTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_parkTypeBtn setBackgroundImage:[UIImage imageNamed:@"mfpparking_yaoyuanjian_all_up.png"] forState:UIControlStateNormal];
    [_parkTypeBtn setBackgroundImage:[UIImage imageNamed:@"mfpparking_yaoyuanjian_all_down.png"]
                            forState:UIControlStateHighlighted];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *navType = [defaults stringForKey:@"navType"];
    if ([FLYBaseUtil isEmpty:navType] || [navType isEqualToString:@"ALL"]) {
        _navType = @"0";
        [_parkTypeBtn setTitle:@"全部" forState:UIControlStateNormal];
    }else if([navType isEqualToString:@"ROAD"]){
        _navType = @"1";
        [_parkTypeBtn setTitle:@"路边" forState:UIControlStateNormal];
    }else if([navType isEqualToString:@"PARK"]){
        _navType = @"2";
        [_parkTypeBtn setTitle:@"路外" forState:UIControlStateNormal];
    }
    
    [bottomView addSubview:_parkTypeBtn];

    //语音按钮
    _voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 30 - 47,(100 - 47) / 2, 47, 47)];
    [_voiceBtn addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
    [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"mfpparking_yaoyuyin_all_down.png"] forState:UIControlStateNormal];
    
    
    NSString *navVoice = [defaults stringForKey:@"navVoice"];

    if ([FLYBaseUtil isNotEmpty:navVoice] && [navVoice isEqualToString:@"NO"]) {
        _isVoice = NO;
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"mfpparking_yaoyuyin_all_down.png"] forState:UIControlStateNormal];
    }else{
        _isVoice = YES;
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"mfpparking_yaoyuyin_all_up.png"] forState:UIControlStateNormal];
    }

    [bottomView addSubview:_voiceBtn];

    
    [self setNoDataViewFrame:_carousel.frame];
    
    _isNaving = YES;
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self requestParkData];
    }else{
        [self showToast:@"请打开网络"];
    }
    
    self.ctrlDelegate = self;
}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * rotations * duration];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark Action
- (void)parkTypeAction:(UIButton *)btn{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([_parkTypeBtn.titleLabel.text isEqualToString:@"全部"]) {
        _navType = @"1";
        [defaults setObject:@"ROAD" forKey:@"navType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_parkTypeBtn setTitle:@"路边" forState:UIControlStateNormal];
    }else if([_parkTypeBtn.titleLabel.text isEqualToString:@"路边"]){
        _navType = @"2";
        [defaults setObject:@"PARK" forKey:@"navType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_parkTypeBtn setTitle:@"路外" forState:UIControlStateNormal];
    }else if([_parkTypeBtn.titleLabel.text isEqualToString:@"路外"]){
        _navType = @"0";
        [defaults setObject:@"ALL" forKey:@"navType"];
        [_parkTypeBtn setTitle:@"全部" forState:UIControlStateNormal];
    }
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self requestParkData];
    }else{
        [self showToast:@"请打开网络"];
    }
}


- (void)voiceAction:(UIButton *)btn{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if (_isVoice) {
        _isVoice = NO;
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"mfpparking_yaoyuyin_all_down.png"] forState:UIControlStateNormal];
        
        [defaults setObject:@"NO" forKey:@"navVoice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (_iflySpeechSynthesizer != nil && _iflySpeechSynthesizer.isSpeaking) {
            [_iflySpeechSynthesizer stopSpeaking];
        }
        
    }else{
        _isVoice = YES;
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"mfpparking_yaoyuyin_all_up.png"] forState:UIControlStateNormal];
        
        [defaults setObject:@"YES" forKey:@"navVoice"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}

- (void)navAction{
    if ([_autonavLabel.text isEqualToString:@"开始巡航"] || [_autonavLabel.text isEqualToString:@"停止巡航"]) {
        _loadTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(requestMoreParkData) userInfo:nil repeats:YES];
        //旋转动画
        [self runSpinAnimationOnView:_autonavView duration:1 rotations:1 repeat:36000];
        _isNaving = YES;
        _autonavLabel.text = @"自动巡航";
        
    }else{
        [_loadTimer invalidate];
        _loadTimer = nil;
        
        _isNaving = NO;
        _autonavLabel.text = @"停止巡航";
        [_autonavView.layer removeAnimationForKey:@"rotationAnimation"];
    }
}

- (void)tapNavAction:(UITapGestureRecognizer *)gesture{
    [self navAction];
}

- (void)gateAction:(UIButton *)button{
    UIView *view = [button superview];
    int index = [_carousel indexOfItemView:view];
    
    FLYParkModel *parkModel = [self.datas objectAtIndex:index];
    FLYGateViewController *gateCtrl = [[FLYGateViewController alloc] init];
    
    gateCtrl.parkModel = parkModel;
    [self.navigationController pushViewController:gateCtrl animated:NO];
}

- (void)autoNavAction:(UIButton *)button{
    UIView *view = [button superview];
    int index = [_carousel indexOfItemView:view];
    
    FLYParkModel *parkModel = [self.datas objectAtIndex:index];
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocationCoordinate2D startCoor = appDelegate.coordinate;
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake([parkModel.parkLat doubleValue], [parkModel.parkLng doubleValue]);
    
    [FLYUtils drivingNavigation:parkModel.parkName start:startCoor end:endCoor];
}

#pragma mark - request
- (void)requestParkData{
    
    _isLoading = YES;
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%f",appDelegate.coordinate.latitude] ,
                                   @"lat",
                                   [NSString stringWithFormat:@"%f",appDelegate.coordinate.longitude],
                                   @"long",
                                   @"200000",
                                   @"range",
                                   _navType,
                                   @"type",
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
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showToast:@"巡航中"];
        
        if (!_isLoading) {
            _isLoading = YES;
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"%f",appDelegate.coordinate.latitude] ,
                                           @"lat",
                                           [NSString stringWithFormat:@"%f",appDelegate.coordinate.longitude],
                                           @"long",
                                           @"200000",
                                           @"range",
                                           _navType,
                                           @"type",
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
                FLYParkModel *parkModel = [self.datas objectAtIndex:0];
                
                [self performSelector:@selector(speakAction:) withObject:parkModel afterDelay:1.0];
                
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
    _loadingView.hidden = YES;
    
    //是否有新的数据
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
                    
                    if (isNew || _carousel.currentItemIndex != 0) {
                        if (isNew) {
                            //播放声音
                            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
                            NSURL *url = [NSURL fileURLWithPath:filePath];
                            SystemSoundID soundId;
                            AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &(soundId));
                            AudioServicesPlayAlertSound(soundId);
                            
                            FLYParkModel *parkModel = [self.datas objectAtIndex:0];
                            [self speakAction:parkModel];
                        }
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

-(void)speakAction:(FLYParkModel *)parkModel{
    
    
    NSString *speechText = [FLYUtils getParkSpeech:parkModel];

    if (_iflySpeechSynthesizer != nil && !_isClose) {
        if (_isVoice) {
            [_iflySpeechSynthesizer startSpeaking:speechText];
        }
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
		view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 60, 260)];
        view.layer.borderWidth = 1;
        view.layer.borderColor = [shakeBorderColor CGColor];
        view.layer.cornerRadius = 5.0;
        view.layer.masksToBounds = YES;
        
        parknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, view.width - 30, 20)];
        parknameLabel.numberOfLines = 1;
        parknameLabel.tag = 101;
        parknameLabel.textColor = [UIColor darkGrayColor];
        parknameLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:parknameLabel];
        
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, parknameLabel.bottom + 5, view.width - 20, 35)];
        addressLabel.numberOfLines = 2;
        addressLabel.textAlignment = NSTextAlignmentCenter;
        addressLabel.font = [UIFont systemFontOfSize:13.0];
        addressLabel.textColor = [UIColor grayColor];
        addressLabel.tag = 102;
        [view addSubview:addressLabel];
        
        //分割线
        UIView *sep = [[UIView alloc] init];
        sep.frame = CGRectMake(10, addressLabel.bottom + 10, view.width - 20, 1);
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
        
        enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        enterBtn.tag = 103;
        enterBtn.frame = CGRectMake(10, view.bottom - 50, 110 , 35);
        [enterBtn primaryStyle];
        [enterBtn setTitle:@"入口引导" forState:UIControlStateNormal];
        enterBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [enterBtn addTarget:self action:@selector(gateAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:enterBtn];

        navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        navBtn.tag = 111;
        navBtn.frame = CGRectMake(enterBtn.right + 20, view.bottom - 50, 110, 35);
        [navBtn primaryStyle];
        [navBtn setTitle:@"开始导航" forState:UIControlStateNormal];
        navBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [navBtn addTarget:self action:@selector(autoNavAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:navBtn];
    }
    
    if (parkModel != nil) {
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        
        parknameLabel = (UILabel *)[view viewWithTag:101];
        parknameLabel.text = parkModel.parkName;
        
        addressLabel = (UILabel *)[view viewWithTag:102];
        addressLabel.text = parkModel.parkAddress;
        
        distanceImage = (UIImageView *)[view viewWithTag:104];
        
        distanceLabel = (UILabel *)[view viewWithTag:105];
        BMKMapPoint point1 = BMKMapPointForCoordinate(appDelegate.coordinate);
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

#pragma mark - 摇动手势
-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion == UIEventSubtypeMotionShake){
        if ([FLYBaseUtil isEnableInternate]) {
            [self requestParkData];
        }else{
            [self showToast:@"请打开网络"];
        }
    }
}

#pragma mark  - FLYBaseCtrlDelegate delegate
- (BOOL)close{
    _isClose = YES;

    if (_iflySpeechSynthesizer != nil && _iflySpeechSynthesizer.isSpeaking) {
        [_iflySpeechSynthesizer stopSpeaking];
        return NO;
    }
    return YES;
}

#pragma mark  - IFlySpeechSynthesizerDelegate delegate
- (void)onCompleted:(IFlySpeechError*) error{
    if (_isClose) {
        [self back];
    }
}

#pragma mark - other
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self becomeFirstResponder];
    
    if (_isNaving) {
        [self navAction];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [_loadTimer invalidate];
    _loadTimer = nil;
    _autonavLabel.text = @"停止巡航";
    [_autonavView.layer removeAnimationForKey:@"rotationAnimation"];
    
    if (_iflySpeechSynthesizer != nil && _iflySpeechSynthesizer.isSpeaking) {
        [_iflySpeechSynthesizer stopSpeaking];
    }
}

- (void)dealloc{
    _iflySpeechSynthesizer = nil;
	_carousel.delegate = nil;
	_carousel.dataSource = nil;
    
    NSLog(@"%s",__FUNCTION__);
}


@end
