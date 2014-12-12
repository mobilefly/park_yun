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
    //评级
    _ratingview = (UIView *)[self viewWithTag:103];
    //内容
    _contentLabel = (UILabel *)[self viewWithTag:104];
    _contentLabel.textAlignment = NSTextAlignmentJustified;
    
    //评论时间
    _timeLabel = (UILabel *)[self viewWithTag:105];
    _timeLabel.textAlignment = NSTextAlignmentRight;
}

- (void)layoutSubviews{
    
    if([self.remarkModel.member.memberPhone length] == 11){
        NSString *phoneBegin = [self.remarkModel.member.memberPhone substringToIndex:3];
        NSString *phoneEnd = [self.remarkModel.member.memberPhone substringFromIndex:7];
        _phoneLabel.text = [NSString stringWithFormat:@"%@****%@",phoneBegin,phoneEnd];
    }else{
        _phoneLabel.text = self.remarkModel.member.memberPhone;
    }
    
    _contentLabel.frame = CGRectMake(10, _phoneLabel.bottom + 10, 300, 0) ;
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
    
    _timeLabel.top = _contentLabel.bottom + 10;
    _timeLabel.text = [FLYUtils fomateString:self.remarkModel.remarkTime formate:@"yyyy-MM-dd HH:mm"];
    
    UIView *sp = [[UIView alloc] init];
    sp.frame = CGRectMake(0, _timeLabel.bottom + 5, 320, 1);
    sp.backgroundColor =  Color(230, 230, 230, 0.6);
    [self addSubview:sp];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
