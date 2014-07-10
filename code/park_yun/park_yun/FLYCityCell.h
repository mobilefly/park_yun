//
//  FLYCityCell.h
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@protocol FLYOfflineCellDelegate <NSObject>
@optional
//下载
- (void)download:(int)cityID;
//更新
- (void)update:(int)cityID;
//删除
- (void)remove:(int)cityID;
//取消
- (void)cancel:(int)cityID;
@end


@interface FLYCityCell : UITableViewCell{
    //城市名称
    UILabel *_cityNameLabel;
    //大小
    UILabel *_sizeLabel;
    //下载按钮
    UIButton *_downloadBtn;
}
- (IBAction)downloadAction:(id)sender;


@property(unsafe_unretained,nonatomic)id<FLYOfflineCellDelegate> cellDelegate;
@property(strong,nonatomic)BMKOLSearchRecord *data;

@end
