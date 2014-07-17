//
//  FLYFootmarkCell.h
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYTraceModel.h"

@interface FLYFootmarkCell : UITableViewCell{

    UILabel *_parkNameLabel;
    UILabel *_startTimeLabel;
    UILabel *_endTimeLabel;
    UILabel *_payLabel;
    UILabel *_durationLabel;
    UIImageView *_parkImage;
    
}

@property(nonatomic,strong)FLYTraceModel *traceModel;

@end
