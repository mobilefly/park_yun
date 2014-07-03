//
//  FLYParkCell.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYParkModel.h"



@interface FLYParkCell : UITableViewCell{
    UILabel *_parkLabel;
    UIImageView *_p_distance;
    UILabel *_distance;
    UIView *_scoreView;
    UILabel *_seatIdle;
    UILabel *_capacity;
    UILabel *_free_time;
    
    UIImageView *_p_feelevel;
    UIImageView *_park_image;
    UIImageView *_p_status;
    
    UILabel *_sep;
    UIImageView *_p_count;
    UILabel *_fz;
    UIImageView *_p_freetime;

}

@property(nonatomic,strong)FLYParkModel *parkModel;
@property(nonatomic,strong)NSNumber *lat;
@property(nonatomic,strong)NSNumber *lon;

@end
