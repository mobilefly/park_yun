//
//  FLYParkCell.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYParkModel.h"
#import "BMapKit.h"


@interface FLYParkCell : UITableViewCell{
    UILabel *_parkLabel;
    UIImageView *_distanceImage;
    UILabel *_distanceLabel;
    UIView *_scoreView;
    UILabel *_seatIdle;
    UILabel *_capacity;
    UILabel *_free_time;
    
    UIImageView *_feelevelImage;
    UIImageView *_parkImage;
    UIImageView *_statusImage;
    
    UILabel *_sep;
    UIImageView *_countImage;
    UILabel *_fz;
    UIImageView *_freetimeImage;
    
    UIImageView *_typeImage;
    UIImageView *_freeImage;

}

@property(nonatomic,strong)FLYParkModel *parkModel;
//当前经纬度
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;

@end
