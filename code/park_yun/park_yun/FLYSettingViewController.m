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
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];

    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    //去除左边15点留白
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self setExtraCellLineHidden:tableView];
}

#pragma mark - 控件事件
- (void)offlineSwitchAction:(UISwitch *)button{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (button.on) {
        [defaults setObject:@"YES" forKey:@"offline"];
    }else{
        [defaults setObject:@"NO" forKey:@"offline"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)noPicSwitchAction:(UISwitch *)button{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (button.on) {
        [defaults setObject:@"YES" forKey:@"noPic"];
    }else{
        [defaults setObject:@"NO" forKey:@"noPic"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if(section == 1){
        return 1;
    }else{
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SettingCell";
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
            cell.textLabel.text = @"离线数据管理";
        }else if(indexPath.row == 1){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"离线浏览";
            
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchview addTarget:self action:@selector(offlineSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchview;
            
            if ([FLYBaseUtil isOffline]) {
                [switchview setOn:YES];
            }else{
                [switchview setOn:NO];
            }
            
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"无图模式";
            
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchview addTarget:self action:@selector(noPicSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchview;
            
            if ([FLYBaseUtil isNoPic]) {
                [switchview setOn:YES];
            }else{
                [switchview setOn:NO];
            }
            
        }
    }else if(indexPath.section == 2){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
        
        if(indexPath.row == 0){
            cell.textLabel.text = @"意见反馈";
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"修改密码";
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"关于我们";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            FLYOfflineParkViewController *offlineCtrl = [[FLYOfflineParkViewController alloc] init];
            [self.navigationController pushViewController:offlineCtrl animated:NO];
            
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0){
            FLYFeedbackViewController *feedBackCtrl = [[FLYFeedbackViewController alloc] init];
            [self.navigationController pushViewController:feedBackCtrl animated:NO];
        }else if (indexPath.row == 1){
            if (![FLYBaseUtil checkUserLogin]) {
                [self showAlert:@"请先登陆用户"];
            }else{
                FLYChangePasswordViewController *changePwdCtrl = [[FLYChangePasswordViewController alloc] init];
                [self.navigationController pushViewController:changePwdCtrl animated:NO];
            }
        }else if (indexPath.row == 2){
            FLYAbortViewController *abortCtrl = [[FLYAbortViewController alloc] init];
            [self.navigationController pushViewController:abortCtrl animated:NO];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}




@end
