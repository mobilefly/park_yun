//
//  FLYCollectCell.m
//  park_yun
//
//  Created by chen on 14-7-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCollectCell.h"
#import "UIImageView+WebCache.h"

@implementation FLYCollectCell

- (void)awakeFromNib
{
    _parkImage = (UIImageView *)[self viewWithTag:101];
    _parkNameLabel = (UILabel *)[self viewWithTag:102];
    _distanceImage = (UIImageView *)[self viewWithTag:103];
    _distanceLabel = (UILabel *)[self viewWithTag:104];
    
    _countImage = (UIImageView *)[self viewWithTag:105];
    _seatIdleLabel = (UILabel *)[self viewWithTag:106];
    _sepLabel = (UILabel *)[self viewWithTag:107];
    _capacityLabel = (UILabel *)[self viewWithTag:108];
    _addressLabel = (UILabel *)[self viewWithTag:109];
    _statusImage = (UIImageView *)[self viewWithTag:110];
    
    _addressLabel.textAlignment = NSTextAlignmentJustified;
    _parkImage.layer.masksToBounds = YES;
    _parkImage.layer.cornerRadius = 2.0;
    _parkImage.layer.borderWidth = 0.1;
    _parkImage.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //图片
    UIImage *defaultParkPhoto = [UIImage imageNamed:@"mfpparking_jiazai_all_0.png"];
    NSString *photoUrl = self.collectModel.photoUrl;
    
    if (![FLYBaseUtil isNoPic]) {
        if ([FLYBaseUtil isNotEmpty:photoUrl]) {
            NSString *smallUrl = [FLYUtils getSmallImage:photoUrl width:@"120" height:@"90"];
            [_parkImage sd_setImageWithURL:[NSURL URLWithString:smallUrl] placeholderImage:defaultParkPhoto];
        }else{
            _parkImage.image = defaultParkPhoto;
        }
    }else{
        _parkImage.image = defaultParkPhoto;
    }
    
    //停车场名称
    _parkNameLabel.text = self.collectModel.park.parkName;

    //距离
    BMKMapPoint point1 = BMKMapPointForCoordinate(self.coordinate);
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([self.collectModel.park.parkLat doubleValue],[self.collectModel.park.parkLng doubleValue]));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    if (distance > 1000) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1fK",distance / 1000];
    }else{
        _distanceLabel.text = [NSString stringWithFormat:@"%.0f",distance];
    }
    [_distanceLabel sizeToFit];
    _distanceLabel.right = 310;
    _distanceImage.right = _distanceLabel.left - 2;
    
    //空位数    
    //加盟标示
    if ([self.collectModel.park.parkStatus isEqualToString:@"0"]) {
        _statusImage.hidden = NO;
        _seatIdleLabel.text = [self.collectModel.park.seatIdle stringValue];
    }else if([self.collectModel.park.parkStatus isEqualToString:@"1"]){
        _statusImage.hidden = YES;
        _seatIdleLabel.text = @"-";
    }else{
        _statusImage.hidden = YES;
        _seatIdleLabel.text = @"-";
    }
    
    //容量
    _capacityLabel.text = [self.collectModel.park.parkCapacity stringValue];
   
    
    [_sepLabel sizeToFit];
    [_seatIdleLabel sizeToFit];
    [_capacityLabel sizeToFit];
    _seatIdleLabel.left = _countImage.right + 4;
    _sepLabel.left = _seatIdleLabel.right + 2;
    _capacityLabel.left = _sepLabel.right + 2;
    
    //地址
    if ([FLYBaseUtil isNotEmpty:self.collectModel.park.parkAddress]) {
        _addressLabel.text = self.collectModel.park.parkAddress;
    }else{
        _addressLabel.text = @"暂无";
    }
    
    [_addressLabel sizeToFit];
    _addressLabel.bottom = 70;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
