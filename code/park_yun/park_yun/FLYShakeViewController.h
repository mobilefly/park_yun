//
//  FLYShakeViewController.h
//  park_yun
//
//  Created by chen on 14-7-18.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "iCarousel.h"
#import "BMapKit.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechConstant.h"

@interface FLYShakeViewController : FLYBaseViewController<iCarouselDataSource, iCarouselDelegate, BMKLocationServiceDelegate,IFlySpeechSynthesizerDelegate,FLYBaseCtrlDelegate>{
    iCarousel *_carousel;
    UIImageView *_loadingView;
    
    //位置服务
    BMKLocationService *_locationService;
    UIImageView *_imageView;
    UIButton *_autonavBtn;
    
    int _index;
    
    NSTimer *_timer;
    NSTimer *_loadTimer;
    
    BOOL _isLoading;
    
    IFlySpeechSynthesizer *_iflySpeechSynthesizer;
}

//人当前位置
@property (nonatomic,assign) CLLocationCoordinate2D curCoordinate;
@property (strong, nonatomic) NSMutableArray *datas;


@end
