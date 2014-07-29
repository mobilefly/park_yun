//
//  ThemeButton.h
//  
//
//  Created by chen on 14-6-8.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeButton : UIButton

//设置背景拉伸位置
@property(nonatomic,assign)int leftCapWidth;
@property(nonatomic,assign)int topCapHeight;

@property (copy,nonatomic) NSString *imageName;
@property (copy,nonatomic) NSString *highligtImageName;

@property (copy,nonatomic) NSString *backgroupImageName;
@property (copy,nonatomic) NSString *backgroupHighlightImageName;

- (id)initWithImage:(NSString *)imageName highlighted:(NSString *)highligtImageName;
- (id)initWithBackgroup:(NSString *)backgroupImageName highlighted:(NSString *)backgroupHighlightImageName;

@end
