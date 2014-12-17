//
//  DownSheetCell.h
//  park_yun
//
//  Created by chen on 14-12-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DownSheetModel.h"
@interface DownSheetCell : UITableViewCell{
    UIImageView *leftView;
    UILabel *infoLabel;
    DownSheetModel *cellData;
    UIView *backgroundView;
}

@property(nonatomic,copy)NSString *originalData;

-(void)setData:(DownSheetModel *) dicdata;

@end
