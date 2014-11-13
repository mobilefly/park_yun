//
//  FLYBussinessViewController.m
//  park_yun
//
//  Created by chen on 14-7-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBussinessViewController.h"

#import "FLYSearhBussinessViewController.h"
#import "FLYBussinessModel.h"
#import "FLYDataService.h"
#import "FLYDBUtil.h"
#import "FLYAppDelegate.h"


#define bgColor Color(230, 230, 230 ,1)

@interface FLYBussinessViewController ()

@end

@implementation FLYBussinessViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _city = [FLYBaseUtil getCity];
        
        if ([FLYBaseUtil isOffline]) {
            self.title = [NSString stringWithFormat:@"%@商圈(离线)", _city];
        }else{
            self.title = [NSString stringWithFormat:@"%@商圈", _city];
        }
 
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = bgColor;

    //离线请求数据库
    if ([FLYBaseUtil isOffline]) {
        NSMutableArray *bussinessList = [FLYDBUtil queryBussinessList:_city];
        self.datas = bussinessList;
        [self renderBussiness];
    }else{
        if ([FLYBaseUtil isEnableInternate]) {
            [self requestBussines:_city];
        }else{
            [self showToast:@"请打开网络"];
        }
    }
}

#pragma mark - 数据请求
- (void)requestBussines:(NSString *)city{
    [self showHUD:@"加载中" isDim:NO];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   city,
                                   @"city",
                                   @"100",
                                   @"count",
                                   nil];
    
    //防止循环引用
    __weak FLYBussinessViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryBusinessList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}

- (void)loadDataError{
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (void)loadData:(id)data{
    [self hideHUD];
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *bussinesss = [result objectForKey:@"businesss"];
            NSMutableArray *bussinessList = [NSMutableArray arrayWithCapacity:bussinesss.count];
            for (NSDictionary *bussinessDic in bussinesss) {
                FLYBussinessModel *bussinessModel = [[FLYBussinessModel alloc] initWithDataDic:bussinessDic];
                [bussinessList addObject:bussinessModel];
            }
            
            self.datas = bussinessList;
            [self renderBussiness];
        }
    }else{
        [self showNoDataView:YES];
    }
}

- (void)renderBussiness{
    if (_datas != nil && [_datas count] > 0) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44 - 20)];
        int i = 0;
        
        for (FLYBussinessModel *bussinessModel in _datas) {
            int j = i / 3;
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10 + 103 * (i % 3), 10 + j * 50, 93, 40)];
            button.layer.cornerRadius = 2.0f;
            button.layer.masksToBounds = YES;
            button.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            button.layer.borderWidth = 0.4f;
            button.backgroundColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont systemFontOfSize: 12.0];
            button.titleLabel.numberOfLines = 2;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.showsTouchWhenHighlighted = YES;
            button.tag = 100 + i;
            
            [button setTitle:bussinessModel.bussinessName forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:button];
            i++;
        }
        [self.view addSubview:scrollView];
        
        [scrollView setContentSize:CGSizeMake(ScreenWidth, 10 + 50 + 50 * ceil([_datas count] / 3))];
    }else{
        [self showNoDataView:YES];
    }
}

#pragma mark - 控件事件
- (void)location:(UIButton *)button{
    long tag = button.tag;
    long index = tag - 100;
    FLYBussinessModel *bussinessModel = [_datas objectAtIndex:index];
    FLYSearhBussinessViewController *bussinessCtrl = [[FLYSearhBussinessViewController alloc] init];
    
    CLLocationCoordinate2D coor = {[bussinessModel.bussinessLat doubleValue],[bussinessModel.bussinessLng doubleValue]};
    bussinessCtrl.coordinate = coor;
    bussinessCtrl.titleName = bussinessModel.bussinessName;
    [self.navigationController pushViewController:bussinessCtrl animated:NO];
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
