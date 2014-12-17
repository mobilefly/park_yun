//
//  FLYParkCardDetail.h
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLYParkCardDetailView : UIView<UIGestureRecognizerDelegate>{
    UIView *view;
}

-(id)initWithView:(UIView *)view;

- (void)showInView:(UIViewController *)subView;

@end
