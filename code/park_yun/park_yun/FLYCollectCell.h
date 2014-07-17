//
//  FLYCollectCell.h
//  park_yun
//
//  Created by chen on 14-7-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYCollectModel.h"
#import "BMapKit.h"


@interface FLYCollectCell : UITableViewCell{
    
    UIImageView *_parkImage;
    UILabel *_parkNameLabel;
    UIImageView *_distanceImage;
    UILabel *_distanceLabel;
    
    UIImageView *_countImage;
    UILabel *_seatIdleLabel;
    UILabel *_capacityLabel;
    UILabel *_sepLabel;
    UILabel *_addressLabel;
    
    UIImageView *_statusImage;
}

@property(nonatomic,strong)FLYCollectModel *collectModel;
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;

@end
