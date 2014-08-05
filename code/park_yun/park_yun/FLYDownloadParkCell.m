//
//  FLYDownloadParkCell.m
//  park_yun
//
//  Created by chen on 14-8-1.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYDownloadParkCell.h"
#import "UIButton+Bootstrap.h"

@implementation FLYDownloadParkCell

- (void)awakeFromNib
{
    _cityNameLabel = (UILabel *)[self viewWithTag:101];
    //大小
    _progressLabel = (UILabel *)[self viewWithTag:102];
    //下载按钮
    _updateBtn = (UIButton *)[self viewWithTag:103];
    //删除
    _removeBtn = (UIButton *)[self viewWithTag:104];
}


- (void)layoutSubviews{
    
    // _downloadBtn
    if (self.data != nil) {
        _cityNameLabel.text = self.data.regionName;
        _progressLabel.text = [NSString stringWithFormat:@"%i%@",self.data.ratio,@"%"];
        //已暂停
        if(self.data.status == 0){
            [_updateBtn setTitle:@"更新" forState:UIControlStateNormal];
            if (self.data.update) {
                _updateBtn.enabled = YES;
                [_updateBtn primaryStyle];
                _cityNameLabel.text = [NSString stringWithFormat:@"%@(%@个)",_cityNameLabel.text,self.data.parkCount];
            }else{
                _updateBtn.enabled = NO;
                [_updateBtn disabledStyle];
            }
        }
        
        if (self.data.status == 0) {
            _removeBtn.enabled = YES;
            [_removeBtn primaryStyle];
        }else{
            _removeBtn.enabled = NO;
            [_removeBtn disabledStyle];
        }
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)removeAction:(id)sender {
    if ([self.parkDelegate respondsToSelector:@selector(remove:)]) {
        [self.parkDelegate remove:_data];
    }
}

- (IBAction)updateAction:(id)sender {
    if ([self.parkDelegate respondsToSelector:@selector(update:)]) {
        [self.parkDelegate update:_data];
    }
}
@end
