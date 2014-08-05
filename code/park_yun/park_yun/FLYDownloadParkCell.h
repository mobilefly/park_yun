//
//  FLYDownloadParkCell.h
//  park_yun
//
//  Created by chen on 14-8-1.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYCityParkCell.h"

@interface FLYDownloadParkCell : UITableViewCell{
    //城市名称
    UILabel *_cityNameLabel;
    //大小
    UILabel *_progressLabel;
    //下载按钮
    UIButton *_updateBtn;
    //删除
    UIButton *_removeBtn;
}


@property(assign,nonatomic)id<FLYOfflineParkDelegate> parkDelegate;

@property(strong,nonatomic)FLYOfflineParkModel *data;

- (IBAction)removeAction:(id)sender;

- (IBAction)updateAction:(id)sender;
@end