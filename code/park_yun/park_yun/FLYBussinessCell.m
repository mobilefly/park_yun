//
//  FLYBussinessCell.m
//  park_yun
//
//  Created by chen on 14-7-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBussinessCell.h"

@implementation FLYBussinessCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)setFrame:(CGRect)frame {
    
    frame.origin.x = 10;
    
    frame.size.width = ScreenWidth - 20;
    
    [super setFrame:frame];
    
}

@end
