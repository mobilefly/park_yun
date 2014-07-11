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

    UILabel *parkNameLabel;
    UILabel *startTimeLabel;
    UILabel *endTimeLabel;
    UILabel *payLabel;
    UILabel *durationLabel;
    UIImageView *parkImage;
    
}

@property(nonatomic,strong)FLYTraceModel *traceModel;

@end
