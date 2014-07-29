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

@interface FLYShakeViewController : FLYBaseViewController<iCarouselDataSource, iCarouselDelegate,IFlySpeechSynthesizerDelegate,FLYBaseCtrlDelegate>{
    iCarousel *_carousel;
    UIImageView *_loadingView;
    
    UIImageView *_imageView;
    UIButton *_autonavBtn;
    
    int _index;
    
    NSTimer *_timer;
    NSTimer *_loadTimer;
    
    BOOL _isLoading;
    
    IFlySpeechSynthesizer *_iflySpeechSynthesizer;
}

@property (strong, nonatomic) NSMutableArray *datas;


@end
