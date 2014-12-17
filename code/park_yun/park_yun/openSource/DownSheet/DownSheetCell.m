//
//  DownSheetCell.m
//  park_yun
//
//  Created by chen on 14-12-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "DownSheetCell.h"

@implementation DownSheetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        leftView = [[UIImageView alloc]init];
        infoLabel = [[UILabel alloc]init];
        infoLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:leftView];
        [self.contentView addSubview:infoLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    leftView.frame = CGRectMake(20, (self.frame.size.height - 20)/2, 20, 20);
    infoLabel.frame = CGRectMake(leftView.frame.size.width + leftView.frame.origin.x + 15, (self.frame.size.height-20)/2, self.frame.size.width - 60, 20);
}

-(void)setData:(DownSheetModel *)dicdata{
    cellData = dicdata;
    if([FLYBaseUtil isNotEmpty:self.originalData] && [self.originalData isEqualToString:dicdata.value]){
        leftView.image = [UIImage imageNamed:@"icon_down_selected.png"];
    }else{
       leftView.image = nil;
    }
    infoLabel.text = dicdata.title;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    self.backgroundColor = [UIColor whiteColor];
//    if(selected){
//        
//        infoLabel.textColor = Color(87, 127, 188, 1);
//    }else{
//        leftView.image = nil;
//        infoLabel.textColor = [UIColor blackColor];
//    }
//}

@end
