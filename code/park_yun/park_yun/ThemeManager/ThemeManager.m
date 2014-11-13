//
//  ThemeManager.m
//  
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "ThemeManager.h"

static ThemeManager *sigleton = nil;

@implementation ThemeManager

+ (ThemeManager *)shareInstance{
    if(sigleton == nil){
        sigleton = [[ThemeManager alloc] init];
    }
    return sigleton;
}

- (id)init{
    self = [super init];
    if(self){
        NSString *themePath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"];
        self.themePlist = [NSDictionary dictionaryWithContentsOfFile:themePath];
        //默认主题
        self.themeName = nil;
    }
    return self;
}

//切换主题调用
- (void)setThemeName:(NSString *)themeName{
    if(_themeName != themeName){
        _themeName = themeName;
    }
    
    NSString *themePath = [self getThemePath];
    NSString *filePath = [themePath stringByAppendingPathComponent:@"fontColor.plist"];
    self.fontColorPlist = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
}

//返回当前主题下，图片对应的图片
- (UIImage *)getThemeImage:(NSString *)imageName{
    if (imageName.length == 0) {
        return nil;
    }
    NSString *themePath = [self getThemePath];
    NSString *imagePath = [themePath stringByAppendingPathComponent:imageName];
 
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

//获取主题目录
- (NSString *)getThemePath{
    if(self.themeName == nil){
        //获取根路径
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        return resourcePath;
    }
    //获取主题路径
    NSString *themePath = [self.themePlist objectForKey:_themeName];
    //获取根路径
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSString *path = [resourcePath stringByAppendingPathComponent:themePath];
    return path;
}


- (UIColor *)getColorWithName:(NSString *)name{
    if (name.length == 0) {
        return nil;
    }
    
    NSString *rgb = [_fontColorPlist objectForKey:name];
    NSArray *rgbs = [rgb componentsSeparatedByString:@","];
    if (rgbs.count == 3) {
        float r = [rgbs[0] floatValue];
        float g = [rgbs[1] floatValue];
        float b = [rgbs[2] floatValue];
        UIColor *color = Color(r, g, b, 1);
        return color;
    }
    return nil;
    
}


#pragma mark - singleton settting
+ (id) allocWithZone:(NSZone *)zone{
    @synchronized (self) {
        if (sigleton == nil) {
            sigleton = [super allocWithZone:zone];
            return sigleton;
        }
    }
    return nil;
}



@end
