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
    
    UILabel *_autonavLabel;
    UIView *_autonavView;
    UIButton *_parkTypeBtn;
    UIButton *_voiceBtn;
    
    int _index;
    
    NSTimer *_loadTimer;
    
    BOOL _isLoading;
    BOOL _isClose;
    
    //是否开启自动巡航
    BOOL _isNaving;
    //是否开启语音
    BOOL _isVoice;
    //导航类型
    NSString *_navType;
    
    IFlySpeechSynthesizer *_iflySpeechSynthesizer;
}

@property (strong, nonatomic) NSMutableArray *datas;


@end
