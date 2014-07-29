//
//  ThemeButton.m
//  
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "ThemeButton.h"
#import "ThemeManager.h"


@implementation ThemeButton

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeNotificcation:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)themeNotificcation:(NSNotification *)notification{
    [self loadThemeImage];
}

- (id)initWithImage:(NSString *)imageName highlighted:(NSString *)highligtImageName{
    self = [self init];
    if (self) {
        self.imageName = imageName;
        self.highligtImageName = highligtImageName;
    }
    return self;
}

- (id)initWithBackgroup:(NSString *)backgroupImageName highlighted:(NSString *)backgroupHighlightImageName{
    self = [self init];
    if (self) {
        self.backgroupImageName = backgroupImageName;
        self.backgroupHighlightImageName = backgroupHighlightImageName;
    }
    return self;
}

- (void)loadThemeImage{
    ThemeManager *themeManager = [ThemeManager shareInstance];
    UIImage *image = [themeManager getThemeImage:_imageName];
    UIImage *highligtImage = [themeManager getThemeImage:_highligtImageName];
    image = [image stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
    highligtImage = [highligtImage stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
    
    
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:highligtImage forState:UIControlStateHighlighted];
    
    UIImage *backImage = [themeManager getThemeImage:_backgroupImageName];
    UIImage *backHighligtImage = [themeManager getThemeImage:_backgroupHighlightImageName];
    backImage = [backImage stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
    backHighligtImage = [backHighligtImage stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
    
    [self setBackgroundImage:backImage forState:UIControlStateNormal];
    [self setBackgroundImage:backHighligtImage forState:UIControlStateHighlighted];
}

#pragma mark - setter
- (void)setImageName:(NSString *)imageName{
    if (_imageName != imageName) {
        _imageName = [imageName copy];
    }
    [self loadThemeImage];
}

- (void)setHighligtImageName:(NSString *)highligtImageName{
    if (_highligtImageName != highligtImageName) {
        _highligtImageName = highligtImageName;
    }
    [self loadThemeImage];
}

- (void)setBackgroupImageName:(NSString *)backgroupImageName{
    if (_backgroupImageName != backgroupImageName) {
        _backgroupImageName = backgroupImageName;
    }
    [self loadThemeImage];
}

- (void)setBackgroupHighlightImageName:(NSString *)backgroupHighlightImageName{
    if(_backgroupHighlightImageName != backgroupHighlightImageName){
        _backgroupHighlightImageName = backgroupHighlightImageName;
    }
    [self loadThemeImage];
}

- (void)setLeftCapWidth:(int)leftCapWidth{
    _leftCapWidth = leftCapWidth;
    [self loadThemeImage];
}

- (void)setTopCapHeight:(int)topCapHeight{
    _topCapHeight = topCapHeight;
    [self loadThemeImage];
}


@end
