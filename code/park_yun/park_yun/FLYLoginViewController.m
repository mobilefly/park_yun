//
//  FLYLoginViewController.m
//  park_yun
//
//  Created by chen on 14-7-8.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYLoginViewController.h"
#import "FLYRegisterViewController.h"
#import "FLYFindPasswordViewController.h"
#import "FLYMemberModel.h"
#import "FLYDataService.h"
#import "SecurityUtil.h"
#import "NSString+MD5HexDigest.h"
#import "NSData+AES.h"

#define fontColor Color(64,64,64,1)
#define bordColor Color(230,230,230,1)

@interface FLYLoginViewController ()

@end

@implementation FLYLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"用户登录";
        self.isBackButton = NO;
        self.isCancelButton = YES;
        _isLogin = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginView.layer.borderWidth = 1;
    self.loginView.layer.borderColor = [bordColor CGColor];
    self.loginView.layer.cornerRadius = 6.0;
    self.loginView.layer.masksToBounds = YES;
    
    self.username.textColor = fontColor;
    self.username.font = [UIFont systemFontOfSize:16.0];
    self.password.textColor = fontColor;
    self.password.font = [UIFont systemFontOfSize:16.0];
    self.password.secureTextEntry = YES;
    
    ThemeButton *loginBtn = [UIFactory createButtonWithBackground:@"mfpparking_accountlogin_all_up.png" backgroundHightlight:@"mfpparking_accountlogin_all_down.png"];
    loginBtn.frame = CGRectMake(20, 160, 280, 40);
    [loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.leftCapWidth = 20;
    loginBtn.topCapHeight = 20;
    
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登  陆" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [self.view addSubview:loginBtn];
    
    self.registerBtn.top = loginBtn.bottom + 20;
    self.forgetpassBtn.top = loginBtn.bottom + 20;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 控件事件
- (IBAction)passwordChange:(id)sender {
    if (self.password.text.length > 0) {
        self.passwordBtn.hidden = NO;
    }else{
        self.passwordBtn.hidden = YES;
    }
}

- (IBAction)usernameChange:(id)sender {
    if (self.username.text.length > 0) {
        self.usernameBtn.hidden = NO;
    }else{
        self.usernameBtn.hidden = YES;
    }
}

- (IBAction)backgroupTap:(id)sender {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

- (IBAction)usernameClear:(id)sender {
    self.username.text = @"";
    self.usernameBtn.hidden = YES;
}

- (IBAction)passwordClear:(id)sender {
    self.password.text = @"";
    self.passwordBtn.hidden = YES;
}

- (IBAction)passwordEnd:(id)sender {
    [self loginAction];
}

- (IBAction)forgetpassAction:(id)sender {
    FLYFindPasswordViewController *findController = [[FLYFindPasswordViewController alloc] init];
    [self.navigationController pushViewController:findController animated:NO];
}

- (IBAction)registerAction:(id)sender {
    FLYRegisterViewController *registerController = [[FLYRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerController animated:NO];
}

- (void)loginAction{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    
    if (self.username.text != nil && self.username.text.length <= 0) {
        [self showToast:@"手机号不能为空"];
        return;
    }else if(self.password.text != nil &&  self.password.text.length <= 0){
        [self showToast:@"密码不能为空"];
        return;
    }
    
    if (!_isLogin) {
        _isLogin = YES;
        _usertext = self.username.text;
        _passMd5 = [self.password.text md5HexDigest];
        _uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        _ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        _key = [NSString stringWithFormat:@"%@,%@,%@",_uuid,_ts,_passMd5];
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *deviceToken = [defaults stringForKey:@"deviceToken"];
        _deviceId = [SecurityUtil encodeBase64String:deviceToken];
        
        NSData *keyValue = [_key dataUsingEncoding:NSUTF8StringEncoding];
        
        Byte keyByte[] = {0x0f, 0x07, 0x0d, 0x00, 0x07, 0x07, 0x02, 0x0c, 0x06, 0x06, 0x0f, 0x0e, 0x03, 0x02, 0x0a,0x0d, 0x0b, 0x0d, 0x0b, 0x03, 0x02, 0x05, 0x03, 0x0e, 0x0c, 0x00, 0x0d, 0x08, 0x0f, 0x0d, 0x0b, 0x09};
        
        //byte转换为NSData类型，以便下边加密方法的调用
        NSData *keyData = [[NSData alloc] initWithBytes:keyByte length:32];
        
        NSData *cipherTextData =[keyValue AES256EncryptWithKey:keyData];
        
        _key = [SecurityUtil encodeBase64Data:cipherTextData];
        

        [self requestLogin];
    }
}

#pragma mark - 事件请求
//停车场位置
- (void)requestLogin{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   _usertext,
                                   @"username",
                                   _uuid,
                                   @"guid",
                                   _ts,
                                   @"ts",
                                   _key,
                                   @"key",
                                   _deviceId,
                                   @"deviceId",
                                   nil];
    [self showHUD:@"登陆中" isDim:NO];
    
    //防止循环引用
    __weak FLYLoginViewController *ref = self;
    [FLYDataService requestWithURL:kHttpLogin params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadLoginData:result];
    } errorBolck:^(){
        [ref loadLoginError];
    }];
    
    
}

- (void)loadLoginError{
    _isLogin = NO;
    [self hideHUD];
    [FLYBaseUtil networkError];
}

//
- (void)loadLoginData:(id)data{
    _isLogin = NO;
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSDictionary *memberDic = [result objectForKey:@"member"];
            FLYMemberModel *memberModel = [[FLYMemberModel alloc] initWithDataDic:memberDic];
            NSString *token = [result objectForKey:@"token"];
            
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberId forKey:@"memberId"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberPhone forKey:@"memberPhone"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberName forKey:@"memberName"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberCarno forKey:@"memberCarno"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberType forKey:@"memberType"];
            [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:@"memberPassword"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [self dismissViewControllerAnimated:NO completion:NULL];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

#pragma mark - Override UIViewController
- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}



@end
