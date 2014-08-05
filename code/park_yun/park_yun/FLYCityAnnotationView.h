//
//  FLYCityAnnotationView.h
//  park_yun
//
//  Created by chen on 14-8-4.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "BMKAnnotationView.h"
#import "FLYRegionParkModel.h"

@interface FLYCityAnnotationView : BMKAnnotationView{
    UILabel *regionLabel;
    
    UILabel *subTitleLabel;
    
//    UILabel *capacityLabel;
}

@property (nonatomic,strong) FLYRegionParkModel *regionModel;

@end
