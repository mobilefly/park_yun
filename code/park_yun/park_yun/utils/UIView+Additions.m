//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)


- (UIViewController *)viewController {
    
    //获取下一响应者
    UIResponder *next = [self nextResponder];
    do{
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        
        next = [next nextResponder];
    }while (next != nil);
    
    return nil;
}



@end
