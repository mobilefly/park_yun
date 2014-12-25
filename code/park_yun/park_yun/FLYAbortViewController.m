//
//  FLYAbortViewController.m
//  park_yun
//
//  Created by chen on 14-7-31.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYAbortViewController.h"

@interface FLYAbortViewController ()

@end

@implementation FLYAbortViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"关于我们";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *iconImage = [UIImage imageNamed:@"mfpparking_gywmicon_all_0.png"];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
    iconView.left = (ScreenWidth - iconView.width) / 2;
    iconView.top = 30;
    [self.view addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.bottom + 5, 0, 30)];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.text = @"停哪儿";
    [titleLabel sizeToFit];
    titleLabel.left = (ScreenWidth - titleLabel.width) / 2;
    [self.view addSubview:titleLabel];
    
    UILabel *versionTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom + 30, ScreenWidth, 25)];
    versionTitle.font = [UIFont systemFontOfSize:14.0];
    versionTitle.textColor = [UIColor lightGrayColor];
    versionTitle.text = @"当前版本号";
    versionTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionTitle];
    
    
    NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, versionTitle.bottom + 2, ScreenWidth, 25)];
    versionLabel.font = [UIFont systemFontOfSize:14.0];
    versionLabel.textColor = [UIColor lightGrayColor];
    versionLabel.text = [NSString stringWithFormat:@"iPhone - v%@",appVersion];;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
    
    UIImage *bottomImage = [UIImage imageNamed:@"mfpparking_gywmtu_all_0.png"];
    UIImageView *bottomView = [[UIImageView alloc] initWithImage:bottomImage];
    bottomView.left = (ScreenWidth - bottomView.width) / 2;
    bottomView.bottom = ScreenHeight - 60 - 20 - 44;
    [self.view addSubview:bottomView];
    
    if (ScreenHeight == 568) {
        bottomView.top = bottomView.top - 40;
    }
    
    UILabel *copyrightTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bottomView.bottom + 10, 0, 30)];
    copyrightTitle.font = [UIFont systemFontOfSize:12.0];
    copyrightTitle.textColor = [UIColor lightGrayColor];
    copyrightTitle.text = @"版权所有©2014";
    [copyrightTitle sizeToFit];
    copyrightTitle.left = (ScreenWidth - copyrightTitle.width) / 2;
    [self.view addSubview:copyrightTitle];
    
    UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, copyrightTitle.bottom + 2, 0, 30)];
    copyrightLabel.font = [UIFont systemFontOfSize:12.0];
    copyrightLabel.textColor = [UIColor lightGrayColor];
    copyrightLabel.text = @"武汉无线飞翔科技有限公司 保留所有权利";
    [copyrightLabel sizeToFit];
    copyrightLabel.left = (ScreenWidth - copyrightLabel.width) / 2;
    [self.view addSubview:copyrightLabel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
