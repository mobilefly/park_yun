//
//  FLYGateCell.m
//  ;;
//
//  Created by chen on 14-7-22.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYGateCell.h"
#import "UIFactory.h"
#import "UIImageView+WebCache.h"

@implementation FLYGateCell

- (void)awakeFromNib
{
    _gateTypeLabel = (UILabel *)[self viewWithTag:101];
    _voiceBtn = (UIButton *)[self viewWithTag:102];
    _gateDescLabel = (UILabel *)[self viewWithTag:103];
    _gateImage = (UIImageView *)[self viewWithTag:104];
    
    _gateDescLabel.textAlignment = NSTextAlignmentJustified;
    
    _gateImage.layer.masksToBounds = YES;
    _gateImage.layer.cornerRadius = 5.0;
    _gateImage.layer.borderWidth = 1;
    _gateImage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [_voiceBtn addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
    
   
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if ([_parkGateModel.gateType isEqualToString:@"1"]) {
        _gateTypeLabel.text = @"入口";
    }else if([_parkGateModel.gateType isEqualToString:@"2"]) {
        _gateTypeLabel.text = @"出口";
    }else{
        _gateTypeLabel.text = @"未知";
    }
    
    _gateDescLabel.top = _gateTypeLabel.bottom + 10;
    _gateDescLabel.text = _parkGateModel.gateDesc;
    [_gateDescLabel sizeToFit];
    
    UIImage *defaultImage = [UIImage imageNamed:@"mfpparking_rkydjiazai_all_0.png"];
    
    NSString *photoUrl = _parkGateModel.photo.photoPath;
    if ([FLYBaseUtil isNotEmpty:photoUrl]) {
        [_gateImage sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:defaultImage];
    }else{
        _gateImage.image = defaultImage;
    }
    _gateImage.top = _gateDescLabel.bottom + 10;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

#pragma mark - Action
- (void)voiceAction:(UIButton *)button{
    if ([self.gateDelegate respondsToSelector:@selector(voice:)]) {
        [self.gateDelegate voice:_parkGateModel.gateDesc];
    }
}

@end
