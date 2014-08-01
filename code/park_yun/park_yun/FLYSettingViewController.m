//
//  FLYSettingViewController.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYSettingViewController.h"
#import "FLYFeedbackViewController.h"
#import "FLYChangePasswordViewController.h"
#import "FLYAbortViewController.h"
#import "FLYOfflineParkViewController.h"

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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [self setExtraCellLineHidden:tableView];
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
        cell.textLabel.text = @"离线数据管理";
    }else if(indexPath.row == 1){
        cell.textLabel.text = @"意见反馈";
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"修改密码";
    }else if(indexPath.row == 3){
        cell.textLabel.text = @"关于我们";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        FLYOfflineParkViewController *offlineCtrl = [[FLYOfflineParkViewController alloc] init];
        [self.navigationController pushViewController:offlineCtrl animated:NO];
        
    }else if (indexPath.row == 1){
        FLYFeedbackViewController *feedBackCtrl = [[FLYFeedbackViewController alloc] init];
        [self.navigationController pushViewController:feedBackCtrl animated:NO];
    }else if (indexPath.row == 2){
        if (![FLYBaseUtil checkUserLogin]) {
            [self showAlert:@"请先登陆用户"];
        }else{
            FLYChangePasswordViewController *changePwdCtrl = [[FLYChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:changePwdCtrl animated:NO];
        }
    }else if (indexPath.row == 3){
        FLYAbortViewController *abortCtrl = [[FLYAbortViewController alloc] init];
        [self.navigationController pushViewController:abortCtrl animated:NO];
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
