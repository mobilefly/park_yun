//
//  ThemeLabel.h
//  WeiBo
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeLabel : UILabel

@property(nonatomic,copy) NSString *colorName;

- (id)initWIthColorName:(NSString *)colorName;

@end
