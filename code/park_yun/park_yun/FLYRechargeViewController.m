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
#import "RegexKitLite.h"




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
    
    okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(30, 100 , 260, 45);
    okBtn.enabled = NO;
    [okBtn disabledStyle];
    [okBtn setTitle:@"确定充值" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(paymentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 175, 255, 0)];
    infoLabel.font = [UIFont systemFontOfSize:13.0];
    infoLabel.textColor = [UIColor darkGrayColor];
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = NSTextAlignmentJustified;
    infoLabel.text = @"";
    [self.view addSubview:infoLabel];
    
    amountLabel = (UITextField *)[self.view viewWithTag:101];
    amountLabel.delegate = self;
    
    [self requestOffInfo];
}

#pragma mark - 数据请求
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
//            order.notifyURL = notifyUrl;
            NSString *orderInfo = [order description];
            
            id<DataSigner> signer = CreateRSADataSigner(privateKey);
            NSString *signedString = [signer signString:orderInfo];
            
            NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderInfo, signedString, @"RSA"];
            
            NSLog(@"%@",orderString);
            [AlixLibService payOrder:orderString AndScheme:@"FLyAlipayParkSmart" seletor:@selector(alipayPaymentResult:) target:self];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


//wap回调函数
-(void)alipayPaymentResult:(NSString *)resultd
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
    [FLYBaseUtil networkError];
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

#pragma mark - 控件事件
- (IBAction)backgroupTap:(id)sender {
    [self.moneyText resignFirstResponder];
}

//支付方式选择
- (void)paymentAction:(UIButton *)btn{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"支付宝" otherButtonTitles:@"微信支付", nil];
    [actionSheet showInView:self.view];
}


#pragma mark - UIActionSheetDelegate delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //支付宝
    if (buttonIndex == 0) {
        [self requestAlipayOrder];
    }
    //微信支付
    else if (buttonIndex == 1){
        [FLYToast showWithText:@"暂不支持"];
    }
    //取消
    else if (buttonIndex == 2){
        return;
    }
}

#pragma mark - UITextFieldDelegate delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSMutableString *amountText = [NSMutableString stringWithString:textField.text];
    [amountText replaceCharactersInRange:range withString:string];
    
//    if (range.length > 0) {
//        //截取中间部分
//        if (range.location + range.length < textField.text.length) {
//            NSRange rbegin = NSMakeRange(0, range.location);
//            NSRange rend = NSMakeRange(range.location + range.length, textField.text.length);
//            amountText = [NSString stringWithFormat:@"%@%@",[textField.text substringWithRange:rbegin],[textField.text substringWithRange:rend]];
//        }
//        //从后截取
//        else{
//            NSRange rbegin = NSMakeRange(0, range.location);
//            amountText = [textField.text substringWithRange:rbegin];
//        }
//    }else{
//        amountText = [NSString stringWithFormat:@"%@%@",amountLabel.text,string];
//    }
    
    if (![FLYBaseUtil isEmpty:amountText] && [FLYBaseUtil isPureNumber:amountText]) {
        [okBtn primaryStyle];
        okBtn.enabled = true;
    }else{
        [okBtn disabledStyle];
        okBtn.enabled = false;
    }
    
    return [self shouldChangeMoney:textField inRange:range replacementString:string];

}

//金额检测
-(BOOL)shouldChangeMoney:(UITextField *)input inRange:(NSRange)range replacementString:(NSString *)string{
    NSArray * temp = [string arrayOfCaptureComponentsMatchedByRegex:@"[.]"];
    if (temp.count > 1) {
        return NO;
    }
    if (temp.count > 0) {
        if ([[input text] arrayOfCaptureComponentsMatchedByRegex:@"[.]"].count>0) {
            return NO;
        }
    }
    
    if ([input.text isEqualToString:@"0"] && (![string isEqualToString:@"."] && ![string isEqualToString:@""])) {
        return NO;
    }
    
    NSMutableString * str = [NSMutableString stringWithString:[input text]];
    [str replaceCharactersInRange:range withString:string];
    
    NSRange r = [str rangeOfString:@"."];
    int loc = r.location;
    int pos = str.length - 3;
    if ((loc != NSNotFound) && (loc < pos)) {
        return NO;
    }
    
    return YES;
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
