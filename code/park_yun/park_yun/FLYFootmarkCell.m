//
//  FLYFootmarkCell.m
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYFootmarkCell.h"
#import "FLYUtils.h"
#import "UIImageView+WebCache.h"
@implementation FLYFootmarkCell

- (void)awakeFromNib
{
     _parkNameLabel = (UILabel *)[self viewWithTag:101];
     _startTimeLabel = (UILabel *)[self viewWithTag:102];
     _endTimeLabel = (UILabel *)[self viewWithTag:103];
     _payLabel = (UILabel *)[self viewWithTag:104];
     _durationLabel = (UILabel *)[self viewWithTag:105];
     _parkImage = (UIImageView *)[self viewWithTag:106];
    
    _parkImage.layer.masksToBounds = YES;
    _parkImage.layer.cornerRadius = 2.0;
    _parkImage.layer.borderWidth = 0.1;
    _parkImage.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)layoutSubviews{
    
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkname]) {
        _parkNameLabel.text = self.traceModel.traceParkname;
    }else{
        _parkNameLabel.text = @"";
    }
    
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkbegin]) {
        _startTimeLabel.text = [FLYUtils fomateString:self.traceModel.traceParkbegin];
    }else{
        _startTimeLabel.text = @"";
    }
    
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkend]) {
         _endTimeLabel.text = [FLYUtils fomateString:self.traceModel.traceParkend];
    }else{
         _endTimeLabel.text = @"";
    }
    
    if (self.traceModel.traceAmt != nil) {
        double traceAmy = [self.traceModel.traceAmt doubleValue] / 100;
        _payLabel.text = [NSString stringWithFormat:@"-%.2f",traceAmy];
    }else{
        _payLabel.text = @"暂无数据";
    }
    
    //    photoUrl
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkbegin] && [FLYBaseUtil isNotEmpty:self.traceModel.traceParkend]) {
        NSDate *beginDate = [FLYUtils dateFromFomate:self.traceModel.traceParkbegin formate:@"yyyyMMddHHmmss"];
        NSDate *endDate = [FLYUtils dateFromFomate:self.traceModel.traceParkend formate:@"yyyyMMddHHmmss"];
        _durationLabel.text = [FLYUtils betweenDate:beginDate endDate:endDate];
    }else{
        _durationLabel.text = @"";
    }
    
    //图片
    UIImage *defaultParkPhoto = [UIImage imageNamed:@"mfpparking_jiazai_all_0.png"];
    if ([FLYBaseUtil isNotEmpty:self.traceModel.photoUrl]) {
        NSString *photoUrl = self.traceModel.photoUrl;
        if ([FLYBaseUtil isNotEmpty:photoUrl]) {
            NSString *smallUrl = [FLYUtils getSmallImage:photoUrl width:@"120" height:@"90"];
            [_parkImage setImageWithURL:[NSURL URLWithString:smallUrl] placeholderImage:defaultParkPhoto];
        }else{
            _parkImage.image = defaultParkPhoto;
        }
    }else{
        _parkImage.image = defaultParkPhoto;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
