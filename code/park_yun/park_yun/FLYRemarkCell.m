//
//  FLYRemarkCell.m
//  park_yun
//
//  Created by chen on 14-7-24.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYRemarkCell.h"
#import "FLYUtils.h"

@implementation FLYRemarkCell

- (void)awakeFromNib
{
    //手机号
    _phoneLabel = (UILabel *)[self viewWithTag:102];
    
    _ratingview = (UIView *)[self viewWithTag:103];
    //内容
    _contentLabel = (UILabel *)[self viewWithTag:104];
    _contentLabel.textAlignment = NSTextAlignmentJustified;

    _timeLabel = (UILabel *)[self viewWithTag:105];
}


- (void)layoutSubviews{
    _phoneLabel.text = self.remarkModel.member.memberPhone;
    
    //U0001f42f
    
    _contentLabel.frame = CGRectMake(20, _phoneLabel.bottom + 10, 280, 0) ;
    _contentLabel.text = [NSString stringWithFormat:@"%@", self.remarkModel.remarkContent];
    
    
    [_contentLabel sizeToFit];
    
    int rating = round([self.remarkModel.remarkTotal intValue] / 3.0);
    for(id subView in _ratingview.subviews)
    {
        [subView removeFromSuperview]; //删除子视图
    }
    
    //满❤
    UIImage *start1 = [UIImage imageNamed:@"mfpparking_ckplstar_all_0.png"];
    //空❤
    UIImage *start2 = [UIImage imageNamed:@"mfpparking_ckplstark_all_0.png"];
    
    UIImageView *tempStar = nil;
    for (int i=1; i<=5; i++) {
        if (rating >= i) {
            UIImageView *startView = [[UIImageView alloc] initWithImage:start1];
            if (tempStar != nil) {
                startView.left = tempStar.right + 5;
            }
            tempStar = startView;
            [_ratingview addSubview:startView];
        }else{
            UIImageView *startView = [[UIImageView alloc] initWithImage:start2];
            if (tempStar != nil) {
                startView.left = tempStar.right + 5;
            }
            tempStar = startView;
            [_ratingview addSubview:startView];
        }
    }
    
    _timeLabel.text = [FLYUtils fomateString:self.remarkModel.remarkTime formate:@"yyyy-MM-dd HH:mm"];
    [_timeLabel sizeToFit];
    _timeLabel.top = _contentLabel.bottom + 10;
    _timeLabel.right = ScreenWidth - 20;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
