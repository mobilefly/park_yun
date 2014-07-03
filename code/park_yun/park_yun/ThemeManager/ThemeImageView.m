//
//  ThemeImageView.m
//  WeiBo
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import "ThemeImageView.h"
#import "ThemeManager.h"

@implementation ThemeImageView

- (id)init{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeNotificcation:) name:kThemeDidChangeNotification object:nil];
    }
    return  self;
}

//xib初始化控件，不在调用init
- (void)awakeFromNib{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeNotificcation:) name:kThemeDidChangeNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setImageName:(NSString *)imageName{
    if(_imageName != imageName){
        _imageName = [imageName copy];
    }
    [self loadThemeImage];
}

- (id)initWithImageName:(NSString *)imageName{
    self = [self init];
    if (self != nil) {
        self.imageName = imageName;
    }
    return self;
}

- (void)loadThemeImage{
    if (self.imageName == nil) {
        return;
    }
        
   UIImage *image  = [[ThemeManager shareInstance] getThemeImage:_imageName];
   image = [image stretchableImageWithLeftCapWidth:self.leftCapWidth topCapHeight:self.topCapHeight];
   self.image = image;
}

- (void)themeNotificcation:(NSNotification *)notification{
    [self loadThemeImage];
}


@end
