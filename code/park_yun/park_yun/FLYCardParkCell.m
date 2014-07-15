//
//  FLYCardParkCell.m
//  park_yun
//
//  Created by chen on 14-7-14.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCardParkCell.h"

@implementation FLYCardParkCell

- (void)awakeFromNib
{
    _bgView = (UIView *)[self viewWithTag:100];
    _parknameLabel = (UILabel *)[self viewWithTag:101];
    _mcCarnoLabel = (UILabel *)[self viewWithTag:102];
    _cardCodeLabel = (UILabel *)[self viewWithTag:103];
    _cpExpdateLabel = (UILabel *)[self viewWithTag:104];
    
//    parkCardModel
    
}

- (void)layoutSubviews{
    _bgView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _bgView.layer.borderWidth = 1;
    _bgView.layer.cornerRadius = 5.0;
    _bgView.layer.masksToBounds = YES;
    
    _parknameLabel.text = self.cardParkModel.park.parkName;
    _mcCarnoLabel.text = self.cardParkModel.memberCarno.mcCarno;
    _cardCodeLabel.text = self.cardParkModel.memberCarno.cardCode;
    
    NSDate *date = [FLYUtils dateFromFomate:self.cardParkModel.cpExpdate formate:@"yyyyMMdd"];
    NSString *datetText = [FLYUtils stringFromFomate:date formate:@"yyyy.MM.dd"];
    _cpExpdateLabel.text = datetText;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
