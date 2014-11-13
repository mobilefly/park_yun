//
//  FLYBillDetailViewController.m
//  park_yun
//
//  Created by chen on 14-7-30.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBillDetailViewController.h"
#import "FLYBillDetailCell.h"
#import "FLYGoodsOrderModel.h"
#import "FLYDataService.h"

#define bgColor Color(230, 230, 230 ,1)

@interface FLYBillDetailViewController ()

@end

@implementation FLYBillDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"账单详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = bgColor;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 - 44)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self setExtraCellLineHidden:_tableView];
    
    [self prepareRequestBillDetailData];
}

#pragma mark - 数据请求
-(void)prepareRequestBillDetailData{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestBillDetailData];
    }else{
        [self showTimeoutView:YES];
        [self showToast:@"请打开网络"];
    }
}

-(void)requestBillDetailData{
    [self showTimeoutView:NO];

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   self.orderId,
                                   @"orderid",
                                   nil];
    
    //防止循环引用
    __weak FLYBillDetailViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryBillDetail params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadBillData:result];
    } errorBolck:^(){
        [ref loadBillError];
    }];
}

-(void)loadBillError{
    [self showTimeoutView:YES];
    
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (void)loadBillData:(id)data{
    [self hideHUD];
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSDictionary *orderDic = [result objectForKey:@"order"];
            _orderModel = [[FLYOrderModel alloc] initWithDataDic:orderDic];
            
            NSArray *goList = [orderDic objectForKey:@"goList"];
            _datas = [NSMutableArray arrayWithCapacity:goList.count];
            for (NSDictionary *goDic in goList) {
                FLYGoodsOrderModel *goModel = [[FLYGoodsOrderModel alloc] initWithDataDic:goDic];
                [_datas addObject:goModel];
            }
            
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
            
            UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 120)];
            detailView.layer.cornerRadius = 2.0f;
            detailView.layer.masksToBounds = YES;
            detailView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            detailView.layer.borderWidth = 1.0f;
            detailView.backgroundColor = [UIColor whiteColor];
            [headView addSubview:detailView];

            UILabel *orderCodeTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 20)];
            orderCodeTitle.font = [UIFont systemFontOfSize:13.0];
            orderCodeTitle.text = @"订单号：";
            orderCodeTitle.textColor = [UIColor lightGrayColor];
            [detailView addSubview:orderCodeTitle];
            
            UILabel *orderCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 0, 20)];
            orderCodeLabel.font = [UIFont systemFontOfSize:13.0];
            orderCodeLabel.text = _orderModel.orderCode;
            orderCodeLabel.textColor = [UIColor darkGrayColor];
            [orderCodeLabel sizeToFit];
            orderCodeLabel.right = detailView.width - 10;
            [detailView addSubview:orderCodeLabel];
            
            UILabel *totalTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, orderCodeTitle.bottom + 10, 80, 20)];
            totalTitle.font = [UIFont systemFontOfSize:13.0];
            totalTitle.text = @"总金额：";
            totalTitle.textColor = [UIColor lightGrayColor];
            [detailView addSubview:totalTitle];
            
            UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, orderCodeTitle.bottom + 10, 0, 20)];
            totalLabel.font = [UIFont systemFontOfSize:13.0];
            totalLabel.text = [NSString stringWithFormat:@"%.2f元",[_orderModel.orderTotalprice doubleValue] / 100];
            totalLabel.textColor = [UIColor darkGrayColor];
            [totalLabel sizeToFit];
            totalLabel.right = detailView.width - 10;
            [detailView addSubview:totalLabel];
            
            UILabel *offTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, totalTitle.bottom + 10, 80, 20)];
            offTitle.font = [UIFont systemFontOfSize:13.0];
            offTitle.text = @"折扣：";
            offTitle.textColor = [UIColor lightGrayColor];
            [detailView addSubview:offTitle];
            
            UILabel *offLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, totalTitle.bottom + 10, 0, 20)];
            offLabel.font = [UIFont systemFontOfSize:13.0];
            offLabel.text = [NSString stringWithFormat:@"- %.2f元",[_orderModel.orderOffprice doubleValue] / 100];
            offLabel.textColor = [UIColor darkGrayColor];
            [offLabel sizeToFit];
            offLabel.right = detailView.width - 10;
            [detailView addSubview:offLabel];
            
            UILabel *priceTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, offTitle.bottom + 10, 80, 20)];
            priceTitle.font = [UIFont systemFontOfSize:13.0];
            priceTitle.text = @"付款金额：";
            priceTitle.textColor = [UIColor lightGrayColor];
            [detailView addSubview:priceTitle];
            
            UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offTitle.bottom + 10, 0, 20)];
            priceLabel.font = [UIFont systemFontOfSize:13.0];
            priceLabel.text = [NSString stringWithFormat:@"%.2f元",fabs([_orderModel.orderPrice doubleValue]) / 100];
            priceLabel.textColor = [UIColor darkGrayColor];
            [priceLabel sizeToFit];
            priceLabel.right = detailView.width - 10;
            [detailView addSubview:priceLabel];
            
            if ([_orderModel.orderPrice doubleValue]  > 0) {
                priceLabel.textColor = [UIColor blueColor];
            }else{
                priceLabel.textColor = [UIColor redColor];
            }
            _tableView.tableHeaderView = headView;
            [_tableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"BillDetailCell";
    FLYBillDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYBillDetailCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    FLYGoodsOrderModel *goModel = [_datas objectAtIndex:indexPath.row];
    cell.goModel = goModel;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

#pragma mark - Override FLYBaseViewController
-(void)timeoutClickAction:(UITapGestureRecognizer*)gesture{
    [self prepareRequestBillDetailData];
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
