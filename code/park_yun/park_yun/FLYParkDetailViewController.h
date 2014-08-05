//
//  FLYParkDetailViewController.h
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "FLYParkModel.h"
#import "JCTopic.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechConstant.h"

@interface FLYParkDetailViewController : FLYBaseViewController<JCTopicDelegate,IFlySpeechSynthesizerDelegate,FLYBaseCtrlDelegate>{

    BOOL _isCollect;
    UIButton *_collectBtn;
    
    UIScrollView *_scrollView;
    
    IFlySpeechSynthesizer *_iflySpeechSynthesizer;
    
    BOOL _isClose;
}

@property(strong,nonatomic) NSString *parkId;
//请求后台数据
@property(strong,nonatomic) FLYParkModel *park;
@property(strong,nonatomic) NSMutableArray *photos;

@property(strong,nonatomic) JCTopic *topic;
@property(strong,nonatomic) UIPageControl *page;

@property(assign,nonatomic) BOOL showLocation;

@end
