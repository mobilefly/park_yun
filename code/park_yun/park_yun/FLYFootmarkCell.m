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
     parkNameLabel = (UILabel *)[self viewWithTag:101];
     startTimeLabel = (UILabel *)[self viewWithTag:102];
     endTimeLabel = (UILabel *)[self viewWithTag:103];
     payLabel = (UILabel *)[self viewWithTag:104];
     durationLabel = (UILabel *)[self viewWithTag:105];
     parkImage = (UIImageView *)[self viewWithTag:106];
}

- (void)layoutSubviews{
    
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkname]) {
        parkNameLabel.text = self.traceModel.traceParkname;
    }else{
        parkNameLabel.text = @"";
    }
    
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkbegin]) {
        startTimeLabel.text = [FLYUtils fomateString:self.traceModel.traceParkbegin];
    }else{
        startTimeLabel.text = @"";
    }
    
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkend]) {
         endTimeLabel.text = [FLYUtils fomateString:self.traceModel.traceParkend];
    }else{
         endTimeLabel.text = @"";
    }
    
    if (self.traceModel.traceAmt != nil) {
        double traceAmy = [self.traceModel.traceAmt doubleValue] / 100;
        payLabel.text = [NSString stringWithFormat:@"-%.2f",traceAmy];
    }else{
        payLabel.text = @"暂无数据";
    }
    
    
//    photoUrl
    
    if ([FLYBaseUtil isNotEmpty:self.traceModel.traceParkbegin] && [FLYBaseUtil isNotEmpty:self.traceModel.traceParkend]) {
        NSDate *beginDate = [FLYUtils dateFromFomate:self.traceModel.traceParkbegin formate:@"yyyyMMddHHmmss"];
        NSDate *endDate = [FLYUtils dateFromFomate:self.traceModel.traceParkend formate:@"yyyyMMddHHmmss"];
        durationLabel.text = [FLYUtils betweenDate:beginDate endDate:endDate];
    }else{
        durationLabel.text = @"";
    }
    
    //图片
    UIImage *defaultParkPhoto = [UIImage imageNamed:@"mfpparking_jiazai_all_0.png"];
    if ([FLYBaseUtil isNotEmpty:self.traceModel.photoUrl]) {
        parkImage.image = defaultParkPhoto;
        [parkImage setImageWithURL:[NSURL URLWithString:self.traceModel.photoUrl] placeholderImage:defaultParkPhoto];
    }else{
        parkImage.image = defaultParkPhoto;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
