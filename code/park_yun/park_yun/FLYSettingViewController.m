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
#import "FLYDataService.h"

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

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    //去除左边15点留白
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self setExtraCellLineHidden:_tableView];
    
    
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    if(appDelegate.version_index == 0){
        [self prepareRequestVersion];
    }
    
}

#pragma mark - 数据请求
- (void)prepareRequestVersion{
    if ([FLYBaseUtil isEnableInternate]) {
        [self requestVersion];
    }
}

- (void)requestVersion{
    
    
    //防止循环引用
    __weak FLYSettingViewController *ref = self;
    
    [FLYDataService requestWithURL:[NSString stringWithFormat:kItunesVersion,kAppId] httpMethod:@"POST" completeBolck:^(id result){
        [ref loadVersionData:result];
    } errorBolck:^(){
        
    }];
}

- (void)loadVersionData:(id)data{
    NSArray *result = [data objectForKey:@"results"];
    if(result != nil && [result count] >0){
        NSString *newVersion = [[result objectAtIndex:0] objectForKey:@"version"];
        
        NSDictionary *infoDictionary =[[NSBundle mainBundle]infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
        
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        if([newVersion isEqualToString:appVersion]){
            appDelegate.version_index = 1;
        }else{
            appDelegate.version_index = 2;
        }
        [_tableView reloadData];
    }
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
        return 5;
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
            cell.textLabel.text = @"修改密码";
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"意见反馈";
        }else if(indexPath.row == 2){
            
            FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
            int version_index = appDelegate.version_index;

            if(version_index == 1){
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = @"当前最新版本";
            }else if(version_index == 2){
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"有新版本下载（更新）";
            }else{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"检测版本";
            }
        }else if(indexPath.row == 3){
            cell.textLabel.text = @"给软件评分";
        }else if(indexPath.row == 4){
            cell.textLabel.text = @"关于停哪儿";
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
            if (![FLYBaseUtil checkUserLogin]) {
                [self showAlert:@"请先登陆用户"];
            }else{
                FLYChangePasswordViewController *changePwdCtrl = [[FLYChangePasswordViewController alloc] init];
                [self.navigationController pushViewController:changePwdCtrl animated:NO];
            }
        }else if (indexPath.row == 1){
            FLYFeedbackViewController *feedBackCtrl = [[FLYFeedbackViewController alloc] init];
            [self.navigationController pushViewController:feedBackCtrl animated:NO];
        }else if (indexPath.row == 2){
            
            FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
            int version_index = appDelegate.version_index;
            if(version_index != 1){
                NSString *url = [NSString stringWithFormat:kItunesDownload,kAppId];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
           
        }else if (indexPath.row == 3){
            NSString *url = [NSString stringWithFormat:kItunesComment,kAppId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }else if (indexPath.row == 4){
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
