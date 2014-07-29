//
//  FLYBussinessViewController.m
//  park_yun
//
//  Created by chen on 14-7-29.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBussinessViewController.h"
#import "FLYBussinessModel.h"
#import "FLYAppDelegate.h"
#import "FLYDataService.h"
#import "FLYSearhBussinessViewController.h"


#define blueColor Color(86, 127, 188 ,1)

@interface FLYBussinessViewController ()

@end

@implementation FLYBussinessViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
        self.title = [NSString stringWithFormat:@"商圈(%@)",appDelegate.city] ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pic_background"]];
    
    //查询商圈
    FLYAppDelegate *appDelegate = (FLYAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([FLYBaseUtil isNotEmpty:appDelegate.city]) {
        if ([FLYBaseUtil isEnableInternate]) {
            [self requestBussines:appDelegate.city];
        }else{
            [self showAlert:@"请打开网络"];
        }
    }
}

#pragma mark - reuqest
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
    [FLYBaseUtil alertErrorMsg];
}

- (void)loadData:(id)data{
    [self hideHUD];
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *businesss = [result objectForKey:@"businesss"];
            NSMutableArray *businessList = [NSMutableArray arrayWithCapacity:businesss.count];
            for (NSDictionary *bussinessDic in businesss) {
                FLYBussinessModel *bussinessModel = [[FLYBussinessModel alloc] initWithDataDic:bussinessDic];
                [businessList addObject:bussinessModel];
            }
            
            self.datas = businessList;
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
            button.layer.borderWidth = 1.0f;
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
        
        [scrollView setContentSize:CGSizeMake(ScreenWidth, 10 + 50 * ceil([_datas count] / 3))];
    }else{
        [self showNoDataView:YES];
    }
}

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


#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
