//
//  FLYSettingViewController.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYSettingViewController.h"
#import "DXAlertView.h"
#import "FLYFeedbackViewController.h"

@interface FLYSettingViewController ()

@end

@implementation FLYSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor grayColor];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"清除缓存";
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"消息接受设置";
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"意见反馈";
    }else if(indexPath.row == 3){
        cell.textLabel.text = @"关于我们";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"清除缓存" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
    }else if (indexPath.row == 1){
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"消息接受设置" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
    }else if (indexPath.row == 2){
        FLYFeedbackViewController *feedBack = [[FLYFeedbackViewController alloc] init];
        [self.navigationController pushViewController:feedBack animated:NO];
    }else if (indexPath.row == 3){
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"关于我们" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - other
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}




@end
