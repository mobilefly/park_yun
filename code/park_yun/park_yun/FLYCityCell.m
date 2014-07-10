//
//  FLYCityCell.m
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCityCell.h"
#import "UIButton+Bootstrap.h"

@implementation FLYCityCell

- (void)awakeFromNib
{
    //城市名称
    _cityNameLabel = (UILabel *)[self viewWithTag:101];
    //大小
    _sizeLabel = (UILabel *)[self viewWithTag:102];
    //下载按钮
    _downloadBtn = (UIButton *)[self viewWithTag:103];
    
}

- (void)layoutSubviews{
    
//    _downloadBtn
    _cityNameLabel.text = self.data.cityName;
    
    _sizeLabel.text = [FLYUtils getDataSizeString:self.data.size];
    
    [_downloadBtn primaryStyle];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


#pragma mark - Action
- (IBAction)downloadAction:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(download:)]) {
        [self.cellDelegate download:_data.cityID];
    }
}

@end
