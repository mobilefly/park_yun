//
//  UIFactory.h
//  WeiBo
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeButton.h"
#import "ThemeLabel.h"
#import "ThemeImageView.h"

@interface UIFactory : NSObject

+ (ThemeButton *)createButton:(NSString *)imageName hightlight:(NSString *)highlightedName;


+ (ThemeButton *)createButtonWithBackground:(NSString *)backgroundimageName backgroundHightlight:(NSString *)highlightedName;

//创建导航栏上的按钮
+ (UIButton *)createNavigationButton:(CGRect)frame
                               title:(NSString *)title
                              target:(id)target
                              action:(SEL)action;

+ (ThemeImageView *)createImageView:(NSString *)imageName;

+ (ThemeLabel *)createLabel:(NSString *)colorName;


@end
