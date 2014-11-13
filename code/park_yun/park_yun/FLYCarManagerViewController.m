//
//  FLYCarLManageViewController.m
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCarManagerViewController.h"
#import "FLYCarBindViewController.h"
#import "FLYCarnoModel.h"
#import "FLYDataService.h"
#import "DXAlertView.h"


@interface FLYCarManagerViewController ()

@end

@implementation FLYCarManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"车辆管理";
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.datas = [[NSMutableArray alloc] initWithCapacity:10];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
    _defaultCarno = memberCarno;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.hidden = YES;
    [self.view addSubview:_tableView];
    
    UIButton *editButton = [UIFactory createNavigationButton:CGRectMake(0, 0, 45, 30) title:@"编辑" target:self action:@selector(editAction)];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [self prepareRequestCarNoData];
}

#pragma mark - 控件事件
-(void)editAction{
    if ([_tableView isEditing]) {
        [_tableView setEditing:NO animated:NO];
    }else{
        [_tableView setEditing:YES animated:NO];
    }
}

#pragma mark - 数据请求
-(void)prepareRequestCarNoData{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestCarNoData];
    }else{
        [self showTimeoutView:YES];
        [self showToast:@"请打开网络"];
    }
}


-(void)requestCarNoData{
    [self showTimeoutView:NO];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   nil];
    
    //防止循环引用
    __weak FLYCarManagerViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryCarnoList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadCarnoData:result];
    } errorBolck:^(){
        [ref loadDataError:YES];
    }];
}

-(void)loadDataError:(BOOL)isFirst{
    if (isFirst) {
        [self showTimeoutView:YES];
    }
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (void)loadCarnoData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *carnos = [result objectForKey:@"carnos"];
            
            NSMutableArray *carnoList = [NSMutableArray arrayWithCapacity:carnos.count];
            for (NSDictionary *carnoDic in carnos) {
                FLYCarnoModel *carnoModel = [[FLYCarnoModel alloc] initWithDataDic:carnoDic];
                [carnoList addObject:carnoModel];
            }
            
            self.datas = carnoList;
            _tableView.hidden = NO;
            [_tableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

-(void)requestChangeCarno:(FLYCarnoModel *)model{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   model.mcCarno,
                                   @"carno",
                                   nil];
    
    //防止循环引用
    __weak FLYCarManagerViewController *ref = self;
    [FLYDataService requestWithURL:kHttpChangeCarno params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadChangeData:result carno:model.mcCarno];
    } errorBolck:^(){
        [ref loadDataError:NO];
    }];
}

-(void)loadChangeData:(id)data carno:(NSString *)carno{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        
        _defaultCarno = carno;
        
        [[NSUserDefaults standardUserDefaults] setObject:carno forKey:@"memberCarno"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [_tableView reloadData];
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

-(void)requestDeleteCarno:(NSIndexPath *)index{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    FLYCarnoModel *model = [self.datas objectAtIndex:index.row];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   model.mcCarno,
                                   @"carno",
                                   nil];
    
    //防止循环引用
    __weak FLYCarManagerViewController *ref = self;
    [FLYDataService requestWithURL:kHttpRemoveCarno params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadDeleteData:result index:index] ;
    } errorBolck:^(){
        [ref loadDataError:NO];
    }];
}

-(void)loadDeleteData:(id)data index:(NSIndexPath *)index{

    //关闭编辑状态
    [_tableView setEditing:NO animated:NO];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        [self showHUDComplete:@"删除成功"];

        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSString *carno = [result objectForKey:@"carno"];
            
            _defaultCarno = carno;
            [[NSUserDefaults standardUserDefaults] setObject:carno forKey:@"memberCarno"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
       
        //删除数据
        [self.datas removeObjectAtIndex:index.row];
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
        
        [_tableView reloadData];
    }else{
        [self hideHUD];
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


#pragma mark - UITableViewDataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"carnoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textColor = [UIColor grayColor];
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    if (indexPath.row == [self.datas count]) {
        cell.textLabel.text = @"添加车牌号";
        cell.detailTextLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:@"mfpparking_clgldelete_all_0.png"];
    }else{
        FLYCarnoModel *model = [self.datas objectAtIndex:indexPath.row];
        
        if ([model.mcFlag isEqualToString:@"1"]) {
            cell.textLabel.text = model.mcCarno;
            cell.detailTextLabel.text = @"待审核";
            cell.imageView.image = [UIImage imageNamed:@"mfpparking_empty.png"];
        }else if([model.mcFlag isEqualToString:@"0"]){
            cell.textLabel.text = model.mcCarno;
            if ([_defaultCarno isEqualToString:model.mcCarno]) {
                cell.detailTextLabel.text = @"默认车辆";
                cell.imageView.image = [UIImage imageNamed:@"mfpparking_clglgou_all_0.png"];
            }else{
                cell.detailTextLabel.text = @"设为默认车辆";
                cell.imageView.image = [UIImage imageNamed:@"mfpparking_empty.png"];
            }
        }
        
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.datas count]) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"确认解除绑定吗？" leftButtonTitle:@"取消" rightButtonTitle:@"确认"];
        [alert show];
        alert.rightBlock = ^{
            [self showHUD:@"删除中" isDim:NO];
            [self requestDeleteCarno:indexPath];
        };
        
    }

}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLYCarnoModel *model = [self.datas objectAtIndex:indexPath.row];
    if ([model.mcFlag isEqualToString:@"1"]) {
        return @"删除";
    }else{
        return @"解绑";
    }
}

#pragma mark - UITableViewDelegate delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //添加车牌
    if (indexPath.row == [self.datas count]) {
        FLYCarBindViewController *carBindCtrl = [[FLYCarBindViewController alloc] init];
        [self.navigationController pushViewController:carBindCtrl animated:NO];
    }
    //切换默认车牌
    else{
        FLYCarnoModel *model = [self.datas objectAtIndex:indexPath.row];
        if ([_defaultCarno isEqualToString:model.mcCarno]) {
            [self showToast:@"已设为默认车辆"];
        }else{
            [self requestChangeCarno:model];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Override FLYBaseViewController
-(void)timeoutClickAction:(UITapGestureRecognizer*)gesture{
    [self prepareRequestCarNoData];
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
