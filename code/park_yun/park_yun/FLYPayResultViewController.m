//
//  FLYPayResultViewController.m
//  park_yun
//
//  Created by chen on 14-10-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYPayResultViewController.h"

@interface FLYPayResultViewController ()

@end

@implementation FLYPayResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"账户充值";
    }
    return self;
}

- (void)viewDidLoad
{
    UILabel *resultLabel = (UILabel *)[self.view viewWithTag:101];
    resultLabel.text = _result;
    if([_result compare:@"充值成功"] == NSOrderedSame){
        resultLabel.textColor = [UIColor greenColor];
    }else{
        resultLabel.textColor = [UIColor redColor];
    }
    [resultLabel sizeToFit];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
