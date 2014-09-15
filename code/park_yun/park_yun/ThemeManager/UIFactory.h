//
//  UIFactory.h
//  
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeImageView.h"
#import "ThemeButton.h"
#import "ThemeLabel.h"


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
