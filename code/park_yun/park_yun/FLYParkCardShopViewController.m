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
    _carNoLabel.text = @"购买车牌号:鄂A8888";
    [self.view addSubview:_carNoLabel];
    
    _totalPirceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, sp.bottom + 5, ScreenWidth - 160 - 10, 25)];
    _totalPirceLabel.text = [NSString stringWithFormat:@"合计:￥%.2f元",100.0];
    _totalPirceLabel.font = [UIFont systemFontOfSize:14.0];
    _totalPirceLabel.textColor = [UIColor orangeColor];
    _totalPirceLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_totalPirceLabel];
    
    _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(10, _totalPirceLabel.bottom + 10, 300, 35)];
    [_buyButton setTitle:@"确定购买" forState:UIControlStateNormal];
    [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buyButton setBackgroundColor:Color(19, 142, 235, 1)];
    _buyButton.showsTouchWhenHighlighted = YES;
    _buyButton.layer.cornerRadius = 4.0;
    _buyButton.layer.masksToBounds = YES;
    _buyButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.view addSubview:_buyButton];
    
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
    static NSString *identifier = @"shopCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    FLYShopModel *shopModel = [self.datas objectAtIndex:indexPath.row];
    
    cell.textLabel.text = shopModel.parkValue;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i",shopModel.buyNum];
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
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - UITableViewDelegate delegate
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
