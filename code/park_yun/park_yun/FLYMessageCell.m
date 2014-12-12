//
//  FLYMessageCell.m
//  park_yun
//
//  Created by chen on 14-12-12.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYMessageCell.h"

@implementation FLYMessageCell

- (void)awakeFromNib {
    _typeLabel = (UILabel *)[self viewWithTag:101];
    _statusLabel = (UILabel *)[self viewWithTag:102];
    _contentLabel = (UILabel *)[self viewWithTag:103];
    _contentLabel.textAlignment = NSTextAlignmentJustified;
    
    _timeLabel = (UILabel *)[self viewWithTag:104];
    _timeLabel.textAlignment = NSTextAlignmentRight;
}

- (void)layoutSubviews{
    
    _typeLabel.text = self.messageModel.messageType;
    
    if([self.messageModel.messageFlag isEqual:@"未读"]){
        _statusLabel.hidden = NO;
    }else{
        _statusLabel.hidden = YES;
    }
    
    _contentLabel.text = self.messageModel.messageContent;
    [_contentLabel sizeToFit];

    _timeLabel.text = self.messageModel.messageAddtime;
    _timeLabel.top = _contentLabel.bottom + 5;
    
    UIView *sp = [[UIView alloc] init];
    sp.frame = CGRectMake(0, _timeLabel.bottom + 5, 320, 1);
    sp.backgroundColor =  Color(230, 230, 230, 0.6);
    [self addSubview:sp];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
