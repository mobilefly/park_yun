//
//  FLYParkDetailViewController.m
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkDetailViewController.h"
#import "FLYBaseNavigationController.h"
#import "FLYMapViewController.h"
#import "FLYLoginViewController.h"
#import "FLYRemarkViewController.h"
#import "FLYGateViewController.h"
#import "FLYDataService.h"
#import "FLYDBUtil.h"
#import "RTLabel.h"
#import <MapKit/MapKit.h>



#define BlueColor Color(25, 150, 240 ,1)
#define FontColor [UIColor darkGrayColor]
#define Padding 15
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface FLYParkDetailViewController ()

@end

@implementation FLYParkDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([FLYBaseUtil isOffline]) {
            self.title = @"停车场详情(离线)";
        }else{
            self.title = @"停车场详情";
        }
        self.showLocation = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isClose = NO;
    // 创建语音合成对象,为单例模式
    _iflySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iflySpeechSynthesizer.delegate = self;
    [_iflySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    [_iflySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]];
    [_iflySpeechSynthesizer setParameter:@"xiaoyan" forKey: [IFlySpeechConstant VOICE_NAME]];
    [_iflySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
    [_iflySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    
    self.ctrlDelegate = self;
    
    [self requestData];
}


#pragma mark - 数据请求
- (void)requestData{
    [self showTimeoutView:NO];
    
    //离线请求数据库
    if ([FLYBaseUtil isOffline]) {
        self.park = [FLYDBUtil queryParkDetail:_parkId];
        if (self.park != nil) {
            [self renderDetail];
        }
    }else if ([FLYBaseUtil isEnableInternate]) {
        if ([FLYBaseUtil isNotEmpty:_parkId]) {
            [self showHUD:@"加载中" isDim:NO];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      _parkId,
                      @"parkid",
                      nil];
            
            if ([FLYBaseUtil checkUserLogin]) {
                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                NSString *token = [defaults stringForKey:@"token"];
                NSString *userid = [defaults stringForKey:@"memberId"];
                [params setObject:token forKey:@"token"];
                [params setObject:userid forKey:@"userid"];
            }
            
            //防止循环引用
            __weak FLYParkDetailViewController *ref = self;
            [FLYDataService requestWithURL:kHttpQueryParkDetail params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadData:result];
            } errorBolck:^(){
                [ref loadError];
            }];
        }
    }else{
        [self showToast:@"请打开网络"];
    }
}

- (void)loadData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSDictionary *parkDic = [result objectForKey:@"park"];
            self.park = [[FLYParkModel alloc] initWithDataDic:parkDic];
            
            NSArray *photos = [result objectForKey:@"photos"];
            if (photos != nil && [photos count] > 0) {
                NSMutableArray *photoList = [NSMutableArray arrayWithCapacity:photos.count];
                for (NSDictionary *photoDic in photos) {
                    FLYPhotoModel *photoModel = [[FLYPhotoModel alloc] initWithDataDic:photoDic];
                    [photoList addObject:photoModel];
                }
                self.photos = photoList;
            }
            
            _isCollect = [[parkDic objectForKey:@"collectFlag"] isEqualToString:@"0"] ? true:false;
            [self renderDetail];
        }
    }else{
        [self showNoDataView:YES];
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

- (void)renderDetail{
    int scollHeight = 0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 -44)];
    [self.view addSubview:_scrollView];
    
    if (self.photos != nil && [self.photos count] > 0) {
        //默认图片
        UIImage *placeholderImage = [UIImage imageNamed:@"mfpparking_jiazai_all_1.png"];
        _topic = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 128)];
        
        //代理
        _topic.JCdelegate = self;
        NSMutableArray *photoArray = [[NSMutableArray alloc]init];
        
        for (FLYPhotoModel *photoModel in self.photos) {
            [photoArray addObject:[NSDictionary dictionaryWithObjects:
                                   @[photoModel.photoPath,@"",@NO,placeholderImage]
                                                forKeys:
                                   @[@"pic",@"title",@"isLoc",@"placeholderImage"]]
             ];
        }

        //加入数据
        _topic.pics = photoArray;
        //更新
        [_topic upDate];
        [_scrollView addSubview:_topic];
        
        _page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _topic.height - 10, 0, 0)];
        _page.backgroundColor = [UIColor clearColor];
        _page.numberOfPages = [photoArray count];
        _page.currentPage = 0;
        [_scrollView addSubview:_page];
        
        _page.right = ScreenWidth - 2 * Padding;
        
        scollHeight += _topic.height;
    }
    
    UILabel *parkName = [[UILabel alloc] initWithFrame:CGRectMake(15, _topic.bottom + 15, 230, 0)];
    parkName.text = self.park.parkName;
    parkName.backgroundColor = [UIColor clearColor];
    parkName.font = [UIFont systemFontOfSize:18.0];
    parkName.textColor = FontColor;
    parkName.numberOfLines = 0;//表示label可以多行显示
    parkName.lineBreakMode = NSLineBreakByCharWrapping;//换行模式，与上面的计算保持一致。
    [parkName sizeToFit];
    [_scrollView addSubview:parkName];
    
    //分割线
    UIView *sp = [[UIView alloc] init];
    sp.frame = CGRectMake(0, parkName.bottom + 15, 320, 1);
    sp.backgroundColor =  Color(230, 230, 230, 0.6);
    [_scrollView addSubview:sp];
    scollHeight += parkName.height + 15 + 15 + 1;
    
    //收藏图片
    _collectBtn = [[UIButton alloc] init];
    if (_isCollect) {
        //已搜藏
        [_collectBtn setImage:[UIImage imageNamed:@"mfpparking_star_all_down.png"] forState:UIControlStateNormal];
    }else{
        //未搜藏
        [_collectBtn setImage:[UIImage imageNamed:@"mfpparking_star_all_up.png"] forState:UIControlStateNormal];
    }
    _collectBtn.showsTouchWhenHighlighted = YES;
    _collectBtn.frame = CGRectMake(0, 0, 37, 40);
    _collectBtn.right = ScreenWidth - 2*Padding;
    _collectBtn.top = _topic.bottom + (sp.bottom - _topic.bottom)/2 - _collectBtn.height / 2;
    [_collectBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_collectBtn];
    
    
    //剩余车位数
    UILabel *textParkCapacity = [[UILabel alloc] initWithFrame:CGRectMake(Padding, sp.bottom + 10, 90, 20)];
    textParkCapacity.text = @"当前剩余车位";
    textParkCapacity.font = [UIFont systemFontOfSize:14.0];
    textParkCapacity.textColor = FontColor;
    [parkName sizeToFit];
    textParkCapacity.numberOfLines = 1;
    [_scrollView addSubview:textParkCapacity];
    
    UILabel *parkCapacity = [[UILabel alloc] initWithFrame:CGRectMake(Padding, sp.bottom + 10, 100, 20)];
    //已签约
    if ([self.park.parkStatus isEqualToString:@"0"]) {
        if ([self.park.seatIdle intValue] == -1) {
            parkCapacity.text = @" - ";
        }else{
            parkCapacity.text = [NSString stringWithFormat:@"%@%@",self.park.seatIdle,@"个"];
        }
    }else{
         parkCapacity.text =  @" - ";
    }
    parkCapacity.font = [UIFont systemFontOfSize:18.0];
    parkCapacity.textColor = [UIColor orangeColor];
    parkCapacity.numberOfLines = 1;
    [parkName sizeToFit];
    parkCapacity.left = textParkCapacity.right;
    [_scrollView addSubview:parkCapacity];
    
    //停车场地址
    UILabel *parkAddress = [[UILabel alloc] initWithFrame:CGRectMake(Padding, parkCapacity.bottom + 5, 230, 20)];
    if ([FLYBaseUtil isNotEmpty:self.park.parkAddress]) {
        parkAddress.text = [NSString stringWithFormat:@"%@%@",@"地址 : ",self.park.parkAddress];
    }else{
        parkAddress.text = [NSString stringWithFormat:@"%@",@"地址 : -"];
    }
    parkAddress.font = [UIFont systemFontOfSize:14.0];
    parkAddress.textColor = FontColor;
    parkAddress.numberOfLines = 0;
    [parkAddress sizeToFit];
    [_scrollView addSubview:parkAddress];
    
    //分割线
    UIView *sp2 = [[UIView alloc] init];
    sp2.frame = CGRectMake(0, parkAddress.bottom + 10, 320, 1);
    sp2.backgroundColor =  Color(230, 230, 230, 0.6);
    [_scrollView addSubview:sp2];
    
    scollHeight += parkCapacity.height + parkAddress.height + 10 + 5 + 10 + 1;
    
    UIButton *positionBtn = [UIFactory createButtonWithBackground:@"mfpparking_location_all_up.png" backgroundHightlight:@"mfpparking_location_all_down.png"];
    positionBtn.showsTouchWhenHighlighted = YES;
    positionBtn.frame = CGRectMake(0, 0, 37, 40);
    [positionBtn addTarget:self action:@selector(positionAction) forControlEvents:UIControlEventTouchUpInside];
    positionBtn.right = ScreenWidth - 2*Padding;
    positionBtn.top = sp.bottom + (sp2.bottom - sp.bottom)/2 - positionBtn.height / 2;
    [_scrollView addSubview:positionBtn];
    if (!self.showLocation) {
        positionBtn.hidden = YES;
    }
    
    //停车场收费标准
    UILabel *textParkFeedesc = [[UILabel alloc] initWithFrame:CGRectMake(Padding, sp2.bottom + 10, ScreenWidth - 2 * Padding, 20)];
    textParkFeedesc.text = @"停车场收费标准";
    textParkFeedesc.font = [UIFont systemFontOfSize:14.0];
    textParkFeedesc.textColor = FontColor;
    [textParkFeedesc sizeToFit];
    [_scrollView addSubview:textParkFeedesc];
    
    UILabel *parkFeedesc = [[UILabel alloc] initWithFrame:CGRectMake(Padding, textParkFeedesc.bottom + 5, ScreenWidth - 2 * Padding, 20)];
    
    if ([FLYBaseUtil isNotEmpty:self.park.parkAddress]) {
        parkFeedesc.text = self.park.parkFeedesc;
    }else{
        parkFeedesc.text = @"";
    }
    
    parkFeedesc.font = [UIFont systemFontOfSize:14.0];
    parkFeedesc.textColor = FontColor;
    parkFeedesc.numberOfLines = 0;
    [parkFeedesc sizeToFit];
    [_scrollView addSubview:parkFeedesc];
    
    //分割线
    UIView *sp3 = [[UIView alloc] init];
    sp3.frame = CGRectMake(0, parkFeedesc.bottom + 10, 320, 1);
    sp3.backgroundColor =  Color(230, 230, 230, 0.6);
    [_scrollView addSubview:sp3];
    
    scollHeight += textParkFeedesc.height + parkFeedesc.height + 10 + 5 + 10 + 1;
    
    //评论按钮
    UIButton *discussBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    discussBtn.frame = CGRectMake(20, sp3.bottom + 15, 130, 30);
    discussBtn.layer.cornerRadius = 4.0;
    discussBtn.layer.masksToBounds = YES;
    discussBtn.layer.borderWidth = 1.0;
    discussBtn.layer.borderColor = [BlueColor CGColor];
    discussBtn.showsTouchWhenHighlighted = YES;
    discussBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [discussBtn setTitleColor:BlueColor forState:UIControlStateNormal];
    [discussBtn setTitle:@"查看评论" forState:UIControlStateNormal];
    [discussBtn addTarget:self action:@selector(discussAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:discussBtn];
    
    //入口引导
    UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    enterBtn.frame = CGRectMake(170, sp3.bottom + 15, 130, 30);
    enterBtn.layer.cornerRadius = 4.0;
    enterBtn.layer.masksToBounds = YES;
    enterBtn.layer.borderWidth = 1.0;
    enterBtn.layer.borderColor = [BlueColor CGColor];
    enterBtn.showsTouchWhenHighlighted = YES;
    enterBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [enterBtn setTitleColor:BlueColor forState:UIControlStateNormal];
    [enterBtn setTitle:@"入口引导" forState:UIControlStateNormal];
    [enterBtn addTarget:self action:@selector(enterAction) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:enterBtn];
    
    //语音播报
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.layer.cornerRadius = 4.0;
    voiceBtn.layer.masksToBounds = YES;
    voiceBtn.showsTouchWhenHighlighted = YES;
    voiceBtn.frame = CGRectMake((ScreenWidth - 280) / 2, discussBtn.bottom + 15, 280, 35);
    voiceBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [voiceBtn setBackgroundColor:BlueColor];
    [voiceBtn setTitle:@"语音播报" forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(voiceAction) forControlEvents:UIControlEventTouchUpInside];
    [voiceBtn setImage:[UIImage imageNamed:@"mfpparking_xqlaba_all_up.png"] forState:UIControlStateNormal];
    [voiceBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    [_scrollView addSubview:voiceBtn];
    
    //一键导航
    UIButton *navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navBtn.layer.cornerRadius = 4.0;
    navBtn.layer.masksToBounds = YES;
    navBtn.showsTouchWhenHighlighted = YES;
    navBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    navBtn.frame = CGRectMake((ScreenWidth - 280) / 2, voiceBtn.bottom + 15, 280, 35);
    [navBtn setBackgroundColor:BlueColor];
    [navBtn setTitle:@"一键导航" forState:UIControlStateNormal];
    [navBtn addTarget:self action:@selector(navAction) forControlEvents:UIControlEventTouchUpInside];
    [navBtn setImage:[UIImage imageNamed:@"mfpparking_xqdh_all_up.png"] forState:UIControlStateNormal];
    [navBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -20, 0.0, 0.0)];
    [_scrollView addSubview:navBtn];
    
    //停车场详情
    RTLabel *parkRemark = [[RTLabel alloc] initWithFrame:CGRectMake(Padding, navBtn.bottom + 15, ScreenWidth - 2 * Padding, 0)];
    if ([FLYBaseUtil isNotEmpty:self.park.parkRemark]) {
        parkRemark.text = self.park.parkRemark;
    }else{
        parkRemark.text = @"";
    }
    parkRemark.font = [UIFont systemFontOfSize:13.0];
    parkRemark.textColor = FontColor;
    parkRemark.textAlignment = NSTextAlignmentJustified;
    
    //计算高度
    CGSize optimumSize = [parkRemark optimumSize];
    CGRect frame = [parkRemark frame];
    frame.size.height = (int)optimumSize.height + 5;
    [parkRemark setFrame:frame];
    
    [_scrollView addSubview:parkRemark];
    scollHeight += discussBtn.height + 15 + voiceBtn.height + 15 + navBtn.height + parkRemark.height + 15 + 15 + 20;
    
    [_scrollView setContentSize:CGSizeMake(ScreenWidth, scollHeight)];
}



#pragma mark - JCTopicDelegate delegate
- (void)didClick:(id)data{
    
}


- (void)currentPage:(int)page total:(NSUInteger)total{
    _page.numberOfPages = total;
    _page.currentPage = page;
}


#pragma mark - 控件事件
- (void)positionAction{
    FLYMapViewController *mapController = [[FLYMapViewController alloc] init];
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    
    mapController.lat = [numFormat numberFromString:_park.parkLat];
    mapController.lon = [numFormat numberFromString:_park.parkLng];
    
    mapController.type = kAnnotationTypePark;
    mapController.dataModel = _park;
    [self.navigationController pushViewController:mapController animated:NO];
}

- (void)collectAction:(UIButton *)button{
    if (![FLYBaseUtil checkUserLogin]) {
        FLYLoginViewController *loginController = [[FLYLoginViewController alloc] init];
        FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:loginController];
        [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
    }else{
        [self requestCollect];
    }
}

- (void)requestCollect{
    _collectBtn.enabled = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   self.park.parkId,
                                   @"parkid",
                                   nil];
    __weak FLYParkDetailViewController *ref = self;
    if (_isCollect) {
        [FLYDataService requestWithURL:kHttpParkCollectRemove params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadRemoveData:result];
        } errorBolck:^(){
        }];
    }else{
        [FLYDataService requestWithURL:kHttpParkCollectAdd params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadAddData:result];
        } errorBolck:^(){
        }];
    }
}

- (void)loadError{
    [self showTimeoutView:YES];
    
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (void)loadRemoveData:(id)data{
    _collectBtn.enabled = true;
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        //未搜藏
        [_collectBtn setImage:[UIImage imageNamed:@"mfpparking_star_all_up.png"] forState:UIControlStateNormal];
        _isCollect = false;
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

- (void)loadAddData:(id)data{
    _collectBtn.enabled = true;
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        //已搜藏
        [_collectBtn setImage:[UIImage imageNamed:@"mfpparking_star_all_down.png"] forState:UIControlStateNormal];
        _isCollect = true;
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

- (void)discussAction{
    FLYRemarkViewController *remarkController = [[FLYRemarkViewController alloc] init];
    remarkController.parkId = self.parkId;
    [self.navigationController pushViewController:remarkController animated:NO];
}

- (void)voiceAction{
    NSString *speechText = [FLYUtils getParkSpeech:_park];
    
    if (_iflySpeechSynthesizer != nil && !_isClose) {
        [_iflySpeechSynthesizer startSpeaking:speechText];
    }
}

- (void)navAction{
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocationCoordinate2D startCoor = appDelegate.coordinate;
    CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake([_park.parkLat doubleValue], [_park.parkLng doubleValue]);
    
    [FLYUtils drivingNavigation:_park.parkName start:startCoor end:endCoor];
}

- (void)enterAction{
    FLYGateViewController *gateCtrl = [[FLYGateViewController alloc] init];
    gateCtrl.parkModel = self.park;
    [self.navigationController pushViewController:gateCtrl animated:NO];
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

#pragma mark - Override FLYBaseViewController
- (void)timeoutClickAction:(UITapGestureRecognizer*)gesture{
    [self requestData];
}

#pragma mark - Override UIViewController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    if (_topic != nil) {
        //停止自己滚动的timer
        [_topic releaseTimer];
        _topic.JCdelegate = nil;
        _topic = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
@end
