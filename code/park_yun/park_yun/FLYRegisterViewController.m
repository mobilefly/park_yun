//
//  FLYRegisterViewController.m
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYRegisterViewController.h"
#import "FLYMemberModel.h"
#import "FLYDataService.h"
#import "DXAlertView.h"
#import "SecurityUtil.h"
#import "NSString+MD5HexDigest.h"
#import "UIButton+Bootstrap.h"


@interface FLYRegisterViewController ()

@end

@implementation FLYRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"用户注册";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 280, 40)];
    _usernameField.borderStyle = UITextBorderStyleRoundedRect;
    _usernameField.clearButtonMode = YES;
    _usernameField.placeholder = @"请输入手机号";
    _usernameField.keyboardType = UIKeyboardTypePhonePad;
    _usernameField.font = [UIFont systemFontOfSize:14.0];
    _usernameField.returnKeyType = UIReturnKeyNext;
    _usernameField.tag = 101;
    [_usernameField addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_usernameField];
    
    if (ScreenHeight == 568) {
        _usernameField.top = _usernameField.top + 30;
    }
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, _usernameField.bottom + 10, 280, 40)];
    _passwordField.borderStyle = UITextBorderStyleRoundedRect;
    _passwordField.clearButtonMode = YES;
    _passwordField.secureTextEntry = YES;
    _passwordField.placeholder = @"请输入密码";
    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordField.font = [UIFont systemFontOfSize:14.0];
    _passwordField.returnKeyType = UIReturnKeyNext;
    _passwordField.tag = 102;
    [_passwordField addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_passwordField];
    
    _passverifyField = [[UITextField alloc] initWithFrame:CGRectMake(20, _passwordField.bottom + 10, 280, 40)];
    _passverifyField.borderStyle = UITextBorderStyleRoundedRect;
    _passverifyField.clearButtonMode = YES;
    _passverifyField.secureTextEntry = YES;
    _passverifyField.placeholder = @"请确认密码";
    _passverifyField.keyboardType = UIKeyboardTypeASCIICapable;
    _passverifyField.font = [UIFont systemFontOfSize:14.0];
    _passverifyField.returnKeyType = UIReturnKeyNext;
    _passverifyField.tag = 103;
    [_passverifyField addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_passverifyField];
    
    _codeFiled = [[UITextField alloc] initWithFrame:CGRectMake(20, _passverifyField.bottom + 10, 160, 40)];
    _codeFiled.borderStyle = UITextBorderStyleRoundedRect;
    _codeFiled.placeholder = @"验证码";
    _codeFiled.textAlignment = NSTextAlignmentCenter;
    _codeFiled.keyboardType = UIKeyboardTypeASCIICapable;
    _codeFiled.font = [UIFont systemFontOfSize:14.0];
    _codeFiled.returnKeyType = UIReturnKeyDone;
    _codeFiled.tag = 104;
    [_codeFiled addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_codeFiled];
    
    _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame = CGRectMake(_codeFiled.right + 20, _passverifyField.bottom + 10, 100, 40);
    [_codeBtn infoStyle];
    [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_codeBtn setTitle:@"60" forState:UIControlStateDisabled];
    _codeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_codeBtn addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_codeBtn];

    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(20,_codeBtn.bottom + 30 , 280, 40);
    [_submitBtn primaryStyle];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
    
    //获取
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [defaults stringForKey:@"deviceToken"];
    _deviceId = [SecurityUtil encodeBase64String:deviceToken];
}

#pragma mark - 控件事件
- (void)didEndAction:(UITextField *)textField{
    if (textField.tag == 101) {
        [_usernameField resignFirstResponder];
        [_passwordField becomeFirstResponder];
    }else if (textField.tag == 102) {
        [_passwordField resignFirstResponder];
        [_passverifyField becomeFirstResponder];
    }else if (textField.tag == 103) {
        [_passverifyField resignFirstResponder];
        [_codeFiled becomeFirstResponder];
    }else if (textField.tag == 104) {
        [_codeFiled resignFirstResponder];
        [self submitAction];
    }
}

- (void)refreshAction:(UIButton *)button{
    if ([FLYBaseUtil isNotEmpty:_usernameField.text]) {
        _codeBtn.enabled = NO;
        [_codeBtn disabledStyle];
        
        if ([FLYBaseUtil isNotEmpty:_usernameField.text]) {
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
            //向词典中动态添加数据
            [params setObject:_usernameField.text forKey:@"phoneNum"];
            [params setObject:@"1" forKey:@"type"];
            
            __weak FLYRegisterViewController *ref = self;
            [FLYDataService requestWithURL:kHttpQueryVCode params:params httpMethod:@"POST" completeBolck:^(id result){
                [ref loadVCode:result];
            } errorBolck:^(){
                [ref loadError];
            }];
        }
        
        //每60秒请求未读数
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
        
        
    }else{
        [self showToast:@"请先输入手机号"];
    }
}

- (void)loadVCode:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        [self showMessage:@"验证码已发送"];
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showMessage:msg];
        //取消定时器
        [_timer invalidate];
        _codeBtn.enabled = YES;
        [_codeBtn primaryStyle];
        [_codeBtn setTitle:@"60" forState:UIControlStateDisabled];
    }
}

- (void)timeAction:(NSTimer *)timer{
    if ([_codeBtn.titleLabel.text isEqualToString:@"1"]) {
        [_timer invalidate];
        _codeBtn.enabled = YES;
        [_codeBtn primaryStyle];
        [_codeBtn setTitle:@"60" forState:UIControlStateDisabled];
    }else{
        int num = [_codeBtn.titleLabel.text intValue];
        [_codeBtn setTitle:[NSString stringWithFormat:@"%i",num -1 ] forState:UIControlStateDisabled];
    }
}


- (void)submitAction{
    
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_passverifyField resignFirstResponder];
    [_codeFiled resignFirstResponder];
    
    if ([FLYBaseUtil isEmpty:_usernameField.text]) {
        [self showToast:@"请输入手机号"];
        return;
    }else if([FLYBaseUtil isEmpty:_passwordField.text] || [FLYBaseUtil isEmpty:_passverifyField.text]){
        [self showToast:@"请输入密码"];
        return;
    }else if ([FLYBaseUtil isEmpty:_codeFiled.text]) {
        [self showToast:@"请输入验证码"];
        return;
    }else if (![_passwordField.text isEqualToString:_passverifyField.text]) {
        [self showToast:@"两次密码输入不相同"];
        return;
    }
    
    //kHttpMemberRegister
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   _usernameField.text,
                                   @"phone",
                                   [_passwordField.text md5HexDigest],
                                   @"password",
                                   _codeFiled.text,
                                   @"checkNo",
                                   _deviceId,
                                   @"deviceId",
                                   nil];
    
    
    [self showHUD:@"注册中" isDim:NO];
    
    [_submitBtn setEnabled:NO];
    //防止循环引用
    __weak FLYRegisterViewController *ref = self;
    [FLYDataService requestWithURL:kHttpMemberRegister params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadRegisterData:result];
    } errorBolck:^(){
        [ref loadError];
    }];
    
}

- (void)loadRegisterData:(id)data{
    [_submitBtn setEnabled:YES];
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            //存储登陆信息
            NSDictionary *memberDic = [result objectForKey:@"member"];
            FLYMemberModel *memberModel = [[FLYMemberModel alloc] initWithDataDic:memberDic];
            NSString *token = [result objectForKey:@"token"];
            
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberId forKey:@"memberId"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberPhone forKey:@"memberPhone"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberName forKey:@"memberName"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberCarno forKey:@"memberCarno"];
            [[NSUserDefaults standardUserDefaults] setObject:memberModel.memberType forKey:@"memberType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"注册成功" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
        
        alert.rightBlock = ^() {
            [self dismissViewControllerAnimated:NO completion:NULL];

        };
        alert.dismissBlock = ^() {
            [self dismissViewControllerAnimated:NO completion:NULL];
        };
        
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }

}

- (void)loadError{
    [_submitBtn setEnabled:YES];
    [self hideHUD];
    [FLYBaseUtil networkError];
}

- (IBAction)backgroundTap:(id)sender {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_passverifyField resignFirstResponder];
    [_codeFiled resignFirstResponder];
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    //取消定时器
    [_timer invalidate];
    _timer = nil;
    
    NSLog(@"%s",__FUNCTION__);
}


@end
