//
//  FLYDownloadCell.m
//  park_yun
//
//  Created by chen on 14-7-10.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYDownloadCell.h"
#import "UIButton+Bootstrap.h"

@implementation FLYDownloadCell

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
        _cityNameLabel.text = self.data.cityName;
        _progressLabel.text = [NSString stringWithFormat:@"%i%@",self.data.ratio,@"%"];
        
        //已暂停
        if ((self.data.status != 1 && self.data.status != 2) && self.data.ratio != 100) {
            _updateBtn.enabled = true;
            [_updateBtn setTitle:@"继续" forState:UIControlStateNormal];
            [_updateBtn primaryStyle];
        }else{
            [_updateBtn setTitle:@"更新" forState:UIControlStateNormal];
            if (self.data.update) {
                _updateBtn.enabled = true;
                [_updateBtn primaryStyle];
                NSString *size = [FLYUtils getDataSizeString:self.data.size];
                _cityNameLabel.text = [NSString stringWithFormat:@"%@(%@)",_cityNameLabel.text,size];
            }else{
                _updateBtn.enabled = false;
                [_updateBtn disabledStyle];
            }
        }
        
        if (self.data.status == 4) {
            [_removeBtn primaryStyle];
        }else{
            [_removeBtn primaryStyle];
        }
        
    }

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (IBAction)updateAction:(id)sender {
    if (self.data.status != 1 && self.data.ratio != 100) {
        if ([self.cellDelegate respondsToSelector:@selector(download:)]) {
            [self.cellDelegate download:_data.cityID];
            _updateBtn.enabled = false;
            [_updateBtn defaultStyle];
            [_updateBtn setTitle:@"更新" forState:UIControlStateNormal];
        }
    }else{
        if ([self.cellDelegate respondsToSelector:@selector(update:)]) {
            [self.cellDelegate update:_data.cityID];
        }
    }
    
    
}

- (IBAction)removeAction:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(remove:)]) {
        [self.cellDelegate remove:_data.cityID];
    }
}
@end
