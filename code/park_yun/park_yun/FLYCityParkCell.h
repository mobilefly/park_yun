//
//  FLYCityParkCell.h
//  park_yun
//
//  Created by chen on 14-8-1.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLYOfflineParkModel.h"

@protocol FLYOfflineParkDelegate <NSObject>
@optional
//下载
- (void)download:(FLYOfflineParkModel *)model;
//更新
- (void)update:(FLYOfflineParkModel *)model;
//删除
- (void)remove:(FLYOfflineParkModel *)model;
@end

@interface FLYCityParkCell : UITableViewCell{
    //城市名称
    UILabel *_cityNameLabel;
    //大小
    UILabel *_sizeLabel;
    //下载按钮
    UIButton *_downloadBtn;
}

- (IBAction)downloadAction:(id)sender;


@property(strong,nonatomic)FLYOfflineParkModel *data;

@property(assign,nonatomic)id<FLYOfflineParkDelegate> parkDelegate;

@end
