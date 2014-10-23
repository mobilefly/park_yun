//
//  FLYRechargeViewController.m
//  park_yun
//
//  Created by chen on 14-7-9.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYRechargeViewController.h"
#import "FLYDataService.h"
#import "FLYToast.h"
#import "UIButton+Bootstrap.h"
#import "NSString+URLEncoding.h"

#import "AlixPayOrder.h"
#import "AlixLibService.h"
#import "AlixPayResult.h"
#import "DataSigner.h"
#import "DataVerifier.h"



@interface FLYRechargeViewController ()

@end

@implementation FLYRechargeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"账户充值";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(30, 100 , 260, 45);
    [okBtn primaryStyle];
    [okBtn setTitle:@"确定充值" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(requestAlipayOrder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 175, 255, 0)];
    infoLabel.font = [UIFont systemFontOfSize:13.0];
    infoLabel.textColor = [UIColor darkGrayColor];
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = NSTextAlignmentJustified;
    infoLabel.text = @"";
    [self.view addSubview:infoLabel];
    
    amountLabel = (UILabel *)[self.view viewWithTag:101];
    
    [self requestOffInfo];
}

#pragma mark - request
-(void)requestAlipayOrder{
    [amountLabel resignFirstResponder];

    NSString *amountText = amountLabel.text;
   
    if ([FLYBaseUtil isEmpty:amountText]) {
        [FLYToast showWithText:@"金额不能为空"];
    }else if(![FLYBaseUtil isPureNumber:amountText]){
        [FLYToast showWithText:@"金额格式不正确"];
    }else{
        NSString *amount = [NSString stringWithFormat:@"%.2f",[amountText floatValue]];
        NSString *amountParms = [NSString stringWithFormat:@"%.0f",[amount floatValue] * 100];
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults stringForKey:@"token"];
        NSString *userid = [defaults stringForKey:@"memberId"];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       token,
                                       @"token",
                                       userid,
                                       @"userid",
                                       amountParms,
                                       @"amount",
                                       nil];
        
        [self showHUD:@"加载中" isDim:NO];
        
        //防止循环引用
        __weak FLYRechargeViewController *ref = self;
        [FLYDataService requestWithURL:kHttpAddAlipay params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadAlipayOrderData:result amount:amount];
        } errorBolck:^(){
            [ref loadDataError];
        }];
    }
    
    
    
}

-(void)loadAlipayOrderData:(id)data amount:(NSString *)amount{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            //支付宝（RSA）公钥
            publicKey = [result objectForKey:@"publicKey"];
            //商户（RSA）私钥
            privateKey = [result objectForKey:@"privateKey"];
            //商品名字
            NSString *subject = [result objectForKey:@"subject"];
            //合作商户ID
            NSString *partner = [result objectForKey:@"partner"];
            //支付宝账户ID
            NSString *seller = [result objectForKey:@"seller"];
            //回调url
            NSString *notifyUrl = [result objectForKey:@"notifyUrl"];
            //订单号
            NSString *outTradeNo = [result objectForKey:@"outTradeNo"];
            
            AlixPayOrder *order = [[AlixPayOrder alloc] init];
            order.partner = partner;
            order.seller = seller;
            order.tradeNO = outTradeNo; //订单ID（由商家自行制定）
            order.productName = subject; //商品标题
            order.productDescription = subject; //商品描述
            order.amount = amount; //商品价格
            order.notifyURL = [notifyUrl URLEncodedString]; //回调URL
            NSString *orderInfo = [order description];
            
            id<DataSigner> signer = CreateRSADataSigner(privateKey);
            NSString *signedString = [signer signString:orderInfo];
            
            NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderInfo, signedString, @"RSA"];
            
            NSLog(@"%@",orderString);
            [AlixLibService payOrder:orderString AndScheme:@"FLyAlipayParkSmart" seletor:@selector(paymentResult:) target:self];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


//wap回调函数
-(void)paymentResult:(NSString *)resultd
{
    //结果处理
    AlixPayResult *result = [[AlixPayResult alloc] initWithString:resultd];
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
			//用公钥验证签名 严格验证请使用result.resultString与result.signString验签
            //交易成功
            NSString *key = publicKey;
            //签约帐户后获取到的支付宝公钥
			id<DataVerifier> verifier = CreateRSADataVerifier(key);
			if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                //验证签名成功，交易结果无篡改
                [FLYToast showWithText:@"交易成功"];
			}
        }
        else
        {
            //交易失败
            [FLYToast showWithText:@"交易失败"];
        }
    }
    else
    {
        //失败
        [FLYToast showWithText:@"交易失败"];
    }
    
}


-(void)loadDataError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}


//获取优惠信息
-(void)requestOffInfo{
    //防止循环引用
    __weak FLYRechargeViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryOffInfo params:nil httpMethod:@"POST" completeBolck:^(id result){
        [ref loadOffinfoData:result];
    } errorBolck:^(){
        
    }];
}

-(void)loadOffinfoData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSString *offInfo = [result objectForKey:@"offInfo"];
            if([FLYBaseUtil isNotEmpty:offInfo]){
                infoLabel.text = offInfo;
                [infoLabel sizeToFit];
            }
        }
    }
}

#pragma mark - Action
- (IBAction)backgroupTap:(id)sender {
    [self.moneyText resignFirstResponder];
}

#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
