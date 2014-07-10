//
//  FLYRechargeViewController.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYRechargeViewController.h"
#import "UIButton+Bootstrap.h"

@interface FLYRechargeViewController ()

@end

@implementation FLYRechargeViewController

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
    [super viewDidLoad];
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(30, 100 , 260, 45);
    [okBtn primaryStyle];
    [okBtn setTitle:@"确定充值" forState:UIControlStateNormal];
    [self.view addSubview:okBtn];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 155, 260, 60)];
    infoLabel.font = [UIFont systemFontOfSize:12.0];
    infoLabel.textColor = [UIColor darkGrayColor];
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = NSTextAlignmentJustified;
//    [infoLabel sizeToFit];
    infoLabel.text = @"6月15日至6月30日间,充值满200元送20元,充值满500送60元,充值满1000元送150元。";
    [self.view addSubview:infoLabel];
}


#pragma mark - Action
- (IBAction)backgroupTap:(id)sender {
    [self.moneyText resignFirstResponder];
}

#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
