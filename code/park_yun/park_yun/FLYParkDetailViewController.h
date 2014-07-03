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

@interface FLYParkDetailViewController : FLYBaseViewController<JCTopicDelegate>{

}

@property(strong,nonatomic) FLYParkModel *parkModel;

@property(strong,nonatomic)JCTopic *topic;
@property(strong,nonatomic)UIPageControl *page;

@end
