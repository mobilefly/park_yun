//
//  FLYDownloadCell.h
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYCityCell.h"

@interface FLYDownloadCell : UITableViewCell{
    //城市名称
    UILabel *_cityNameLabel;
    //大小
    UILabel *_progressLabel;
    //下载按钮
    UIButton *_updateBtn;
    //删除
    UIButton *_removeBtn;
}

//@property(unsafe_unretained,nonatomic)id<FLYOfflineCellDelegate> cellDelegate;
@property(assign,nonatomic)id<FLYOfflineCellDelegate> cellDelegate;


@property(strong,nonatomic)BMKOLUpdateElement *data;

- (IBAction)updateAction:(id)sender;

- (IBAction)removeAction:(id)sender;


@end
