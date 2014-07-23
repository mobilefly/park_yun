//
//  FLYGateViewController.h
//  park_yun
//
//  Created by chen on 14-7-22.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "FLYParkModel.h"
#import "FLYGateCell.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechConstant.h"

@interface FLYGateViewController : FLYBaseViewController<UITableViewDataSource,UITableViewDelegate,FLYGateDelegate,IFlySpeechSynthesizerDelegate,FLYBaseCtrlDelegate>{
    
    UITableView *_tableView;
    NSMutableArray *_datas;
    
    IFlySpeechSynthesizer *_iflySpeechSynthesizer;
}

@property (nonatomic,strong) FLYParkModel *parkModel;

@end
