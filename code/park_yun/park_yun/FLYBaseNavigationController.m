//
//  BaseNavigationController.m
//  park_yun
//
//  Created by chen on 14-7-2.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseNavigationController.h"
#import "ThemeManager.h"

@interface FLYBaseNavigationController ()

@end

@implementation FLYBaseNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadThemeImage];
    
    //左滑返回
    UISwipeGestureRecognizer *swipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipAction:)];
    swipGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipGesture];
}

- (void)swipAction:(UISwipeGestureRecognizer *)gesture{
    if(self.viewControllers.count > 1){
        if(gesture.direction == UISwipeGestureRecognizerDirectionRight){
            [self popViewControllerAnimated:NO];
        }
    }
}

- (void)loadThemeImage {
    float version = FLYOSVersion();
    if(version > 5.0){
        UIImage *image = [[ThemeManager shareInstance] getThemeImage:@"navigationbar_background.png"];
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        //[self.navigationBar setBackgroundColor:Color(86.0,127.0,188.0,0.5)];
    } else{
        //调用drawRect
        [self.navigationBar setNeedsDisplay];
    }
}

#pragma mark - view other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




@end
