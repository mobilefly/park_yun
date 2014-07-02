//
//  FLYParkCell.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkCell.h"
#import "UIImageView+WebCache.h"

@implementation FLYParkCell



- (void)awakeFromNib
{
    [super awakeFromNib];
    _parkLabel = (UILabel *)[self viewWithTag:101];
    _p_distance = (UIImageView *)[self viewWithTag:102];
    _distance = (UILabel *)[self viewWithTag:103];
    _scoreView = (UILabel *)[self viewWithTag:104];
    _seatIdle = (UILabel *)[self viewWithTag:105];
    _capacity = (UILabel *)[self viewWithTag:106];
    _free_time = (UILabel *)[self viewWithTag:107];
    _p_freelevel = (UIImageView *)[self viewWithTag:108];
    _park_image = (UIImageView *)[self viewWithTag:109];
    _p_status = (UIImageView *)[self viewWithTag:110];
    
    _sep = (UILabel *)[self viewWithTag:111];
    _p_count = (UIImageView *)[self viewWithTag:112];
    
    _fz = (UILabel *)[self viewWithTag:113];
    _p_freetime = (UIImageView *)[self viewWithTag:114];
    
    _park_image.layer.masksToBounds = YES;
    _park_image.layer.cornerRadius = 3.0;
    _park_image.layer.borderWidth = 0.1;
    _park_image.layer.borderColor = [[UIColor grayColor] CGColor];
    

}

- (void)layoutSubviews{
    [super layoutSubviews];
    //停车场名称
    _parkLabel.text = self.parkModel.parkName;
    //空位数
    _seatIdle.text = [self.parkModel.seatIdle stringValue];
    //容量
    _capacity.text = [self.parkModel.parkCapacity stringValue];
    //免费时间
    NSString *freeTime = [self.parkModel.parkFreetime stringValue];
    if (freeTime == nil || [freeTime isEqualToString:@"0"]) {
        _fz.hidden = YES;
        _free_time.text = @"";
        _p_freetime.hidden = YES;
    }else{
        _free_time.text = freeTime;
        _fz.hidden = NO;
        _p_freetime.hidden = NO;
    }
    
    
    //加盟标示
    if ([self.parkModel.parkStatus isEqual:@"0"]) {
        _p_status.hidden = NO;
        
    }else if([self.parkModel.parkStatus isEqual:@"1"]){
        _p_status.hidden = YES;
        _seatIdle.text = @"-";
    }else{
        _p_status.hidden = YES;
        _seatIdle.text = @"-";
    }
    
    //图片
    UIImage *defaultParkPhoto = [UIImage imageNamed:@"mfpparking_jiazai_all_0.png"];
    if (self.parkModel.photo != nil && self.parkModel.photo.photoPath != nil) {
        [_park_image setImageWithURL:[NSURL URLWithString:self.parkModel.photo.photoPath]placeholderImage:defaultParkPhoto];
    }else{
        _park_image.image = defaultParkPhoto;
    }
    
    
    
    [_sep sizeToFit];
    [_seatIdle sizeToFit];
    [_capacity sizeToFit];
    //CGFloat fl = _p_count.right;
    _seatIdle.left = _p_count.right + 2;
    _sep.left = _seatIdle.right;
    _capacity.left = _sep.right;
    
    [_free_time sizeToFit];
    _free_time.left = _p_freetime.right + 2;
    _fz.left = _free_time.right;
    
    
    
   
    
//    _seatIdle.text = self.parkModel.seatIdle;
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
