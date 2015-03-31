//
//  FLYParkCardShopViewController.m
//  park_yun
//
//  Created by chen on 14-12-16.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkCardShopViewController.h"
#import "FLYParkCardModel.h"
#import "FLYShopModel.h"
#import "FLYDataService.h"
#import "DXAlertView.h"

#define SpColor Color(220, 220, 220, 1)

@interface FLYParkCardShopViewController ()

@end

@implementation FLYParkCardShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"购物车";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = [FLYBaseUtil getDelegateShop];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44 - 90)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [self setExtraCellLineHidden:_tableView];
    
    //分割线
    UIView *sp = [[UIView alloc] initWithFrame:CGRectMake(0, _tableView.bottom + 1, ScreenWidth, 1)];
    sp.backgroundColor =  SpColor;
    [self.view addSubview:sp];
    
    
    _carNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, sp.bottom + 5, 150, 25)];
    _carNoLabel.font = [UIFont systemFontOfSize:12.0];
    _carNoLabel.textColor = [UIColor darkGrayColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([FLYBaseUtil checkUserBindCar]) {
        NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
        _carNoLabel.text = [NSString  stringWithFormat:@"车牌:%@",memberCarno];
    }else{
        _carNoLabel.text = @"未绑定车牌";
    }
    [self.view addSubview:_carNoLabel];
    
    _totalPirceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, sp.bottom + 5, ScreenWidth - 160 - 10, 25)];
    _totalPirceLabel.font = [UIFont systemFontOfSize:14.0];
    _totalPirceLabel.textColor = [UIColor orangeColor];
    _totalPirceLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_totalPirceLabel];
    
    [self calcTotalAmount];
    
    _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(10, _totalPirceLabel.bottom + 10, 300, 35)];
    [_buyButton setTitle:@"确定购买" forState:UIControlStateNormal];
    [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buyButton setBackgroundColor:Color(19, 142, 235, 1)];
    _buyButton.showsTouchWhenHighlighted = YES;
    _buyButton.layer.cornerRadius = 4.0;
    _buyButton.layer.masksToBounds = YES;
    _buyButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:_buyButton];
    
    [_buyButton addTarget:self action:@selector(buyAction) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - request
-(void)prepareRequestBuyCard{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"购买中" isDim:NO];
        [self requestBuyCard];
    }else{
        [self showTimeoutView:YES];
        [self showToast:@"请打开网络"];
    }
}

-(void)requestBuyCard{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
    
    NSString *parkid = @"";
    NSString *num = @"";
    NSString *pcid = @"";
    int total = 0;
    
    for (int i = 0 ; i < [self.datas count] ; i++) {
        
        FLYShopModel *shopModel = [self.datas objectAtIndex:i];
        if(i == 0){
            parkid = [parkid stringByAppendingFormat:@"%@", shopModel.parkId];
            num = [num stringByAppendingFormat:@"%i",shopModel.buyNum];
            pcid = [pcid stringByAppendingFormat:@"%@", shopModel.parkCard.pcId];
        }else{
            parkid = [parkid stringByAppendingFormat:@",%@", shopModel.parkId];
            num = [num stringByAppendingFormat:@",%i",shopModel.buyNum];
            pcid = [pcid stringByAppendingFormat:@",%@", shopModel.parkCard.pcId];
        }
        
        total +=  shopModel.buyNum * [shopModel.parkCard.pcPrice intValue];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   memberCarno,
                                   @"carno",
                                   parkid,
                                   @"parkid",
                                   num,
                                   @"num",
                                   pcid,
                                   @"pcid",
                                   [NSString stringWithFormat:@"%i",total],
                                   @"total",
                                   nil];
    
    
    //防止循环引用
    __weak FLYParkCardShopViewController *ref = self;
    [FLYDataService requestWithURL:kHttpBuyParkCard params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadBuyCardData:result];
    } errorBolck:^(){
        [ref loadDataError:YES];
    }];
}

- (void)loadBuyCardData:(id)data{
    [self hideHUD];
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        
        //设置未畅停卡用户
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"3" forKey:@"memberType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"购买成功" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
        
        alert.rightBlock = ^ {
            
            self.datas = [[NSMutableArray alloc] initWithCapacity:20];
            [FLYBaseUtil setDelegateShop:self.datas];
            [_tableView reloadData];
            
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        alert.dismissBlock = ^ {
            self.datas = [[NSMutableArray alloc] initWithCapacity:20];
            [FLYBaseUtil setDelegateShop:self.datas];
            [_tableView reloadData];

        };
        
    
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


-(void)loadDataError:(BOOL)isFirst{
    [self hideHUD];
    [FLYBaseUtil networkError];
}


#pragma mark - util
- (void)calcTotalAmount{
    float total = 0;
    
    for (FLYShopModel *shopModel in self.datas) {
        total += shopModel.buyNum * [shopModel.parkCard.pcPrice intValue] / 100;
    }
    
    _totalPirceLabel.text = [NSString stringWithFormat:@"合计:￥%.2f元",total];
}

#pragma mark - Action
- (void)buyAction{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![FLYBaseUtil checkUserBindCar]) {
        [self showAlert:@"未绑定车牌,无法购买畅停卡"];
    }else if([self.datas count] == 0){
        [self showAlert:@"购物车为空"];
    }else{
        NSString *memberCarno = [defaults stringForKey:@"memberCarno"];
        NSString *msg = [NSString stringWithFormat:@"购买车牌【 %@ 】\n是否确定购买?",memberCarno];
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:msg leftButtonTitle:@"取消" rightButtonTitle:@"确定"];
        [alert show];
        alert.rightBlock = ^(){
            [self prepareRequestBuyCard];
        };
    }
}

#pragma mark - UITableViewDataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.datas == nil || [self.datas count] == 0) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return [self.datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ShopCell";
    FLYParkCardShopCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYParkCardShopCell" owner:self options:nil] lastObject];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.shopModel = [self.datas objectAtIndex:indexPath.row];
    cell.shopDelegate = self;
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //移除单行购物列表
        [self.datas removeObjectAtIndex:indexPath.row];
        [_tableView reloadData];
        [self calcTotalAmount];
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - FLYParkCardShopDelegate
//增加数量
- (void)increase:(FLYShopModel *)model{
    [self calcTotalAmount];
}

//减少数量
- (void)reduce:(FLYShopModel *)model{
    [self calcTotalAmount];
}

//删除
- (void)delete:(FLYShopModel *)model{
    
    for (int i = 0; i < [self.datas count]; i++) {
        FLYShopModel *shopModel = [self.datas objectAtIndex:i];
        if ([shopModel.parkCard.pcId isEqual:model.parkCard.pcId]) {
            [self.datas removeObjectAtIndex:i];
            [_tableView reloadData];
            break;
        }
    }
    [self calcTotalAmount];
    
}

#pragma mark - UITableViewDelegate delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
