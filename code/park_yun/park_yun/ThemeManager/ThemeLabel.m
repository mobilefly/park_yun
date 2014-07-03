//
//  ThemeLabel.m
//  WeiBo
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import "ThemeLabel.h"
#import "ThemeManager.h"

@implementation ThemeLabel

- (id)init{
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeNotificcation:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWIthColorName:(NSString *)colorName{
    self = [self init];
    if (self != nil) {
        self.colorName = colorName;
    }
    return self;
}

- (void)setColorName:(NSString *)colorName{
    if (_colorName != colorName) {
        _colorName = [colorName copy];
    }
    [self setColor];
}

- (void)setColor{
    UIColor *textColor = [[ThemeManager shareInstance] getColorWithName:_colorName];
    self.textColor = textColor;
}


- (void)themeNotificcation:(NSNotification *)notification{
    [self setColor];
}

@end
