//
//  FLYGateCell.h
//  park_yun
//
//  Created by chen on 14-7-22.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYParkGateModel.h"

@protocol FLYGateDelegate <NSObject>
@required
//语音播报
- (void)voice:(NSString *)title;
@end


@interface FLYGateCell : UITableViewCell{
    UILabel *_gateTypeLabel;
    UIButton *_voiceBtn;
    UILabel *_gateDescLabel;
    UIImageView *_gateImage;
    
}

@property (nonatomic,strong) FLYParkGateModel *parkGateModel;
@property(assign,nonatomic)id<FLYGateDelegate> gateDelegate;

@end
