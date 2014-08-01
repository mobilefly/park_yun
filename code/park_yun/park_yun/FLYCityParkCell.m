//
//  FLYCityParkCell.m
//  park_yun
//
//  Created by chen on 14-8-1.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCityParkCell.h"
#import "UIButton+Bootstrap.h"

@implementation FLYCityParkCell

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
    _cityNameLabel.text = self.data.regionName;
    _sizeLabel.text =  [NSString stringWithFormat:@"%@个",self.data.parkCount];
    [_downloadBtn primaryStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Action
- (IBAction)downloadAction:(id)sender {
    
}


@end
