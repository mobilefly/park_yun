//
//  ThemeManager.h
//  WeiBo
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeManager : NSObject

@property(strong,nonatomic) NSString *themeName;
@property(strong,nonatomic) NSDictionary *themePlist;
@property(strong,nonatomic) NSDictionary *fontColorPlist;

+ (ThemeManager *)shareInstance;

//返回当前主题下，图片对应的图片
- (UIImage *)getThemeImage:(NSString *)imageName;

- (UIColor *)getColorWithName:(NSString *)name;

@end
