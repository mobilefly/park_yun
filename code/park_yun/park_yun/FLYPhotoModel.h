//
//  FLYPhotoModel.h
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//


//photoId	string	停车场图片UID
//photoPath	string	停车场图片路径

#import "FLYBaseModel.h"

@interface FLYPhotoModel : FLYBaseModel

@property(nonatomic,copy) NSString *photoId;
@property(nonatomic,copy) NSString *photoPath;

@end
