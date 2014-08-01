//
//  FLYRegisterViewController.m
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYRegisterViewController.h"
#import "UIButton+Bootstrap.h"
#import "FLYDataService.h"
#import "DXAlertView.h"
#import "NSString+MD5HexDigest.h"

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
    UIView *usernameIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] ;
    UIView *passwordIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] ;
    UIView *passverifyIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] ;
    
    UIImageView *usernameIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_inputaccount_all_0.png"]];
    usernameIcon.frame = CGRectMake(9, 8, 22, 24);
    [usernameIconView addSubview:usernameIcon];
    
    UIImageView *passwordIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_inputpwd_all_0.png"]];
    passwordIcon.frame = CGRectMake(9, 8, 22, 24);
    [passwordIconView addSubview:passwordIcon];
    
    UIImageView *passverifyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_inputpwd_all_0.png"]];
    passverifyIcon.frame = CGRectMake(9, 8, 22, 24);
    [passverifyIconView addSubview:passverifyIcon];
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 280, 40)];
    _usernameField.borderStyle = UITextBorderStyleRoundedRect;
    _usernameField.clearButtonMode = YES;
    _usernameField.leftView = usernameIconView;
    _usernameField.leftViewMode = UITextFieldViewModeAlways;
    _usernameField.placeholder = @"请输入手机号";
    _usernameField.keyboardType = UIKeyboardTypeASCIICapable;
    _usernameField.font = [UIFont systemFontOfSize:14.0];
    _usernameField.returnKeyType = UIReturnKeyNext;
    _usernameField.tag = 101;
    [_usernameField addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_usernameField];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, _usernameField.bottom + 10, 280, 40)];
    _passwordField.borderStyle = UITextBorderStyleRoundedRect;
    _passwordField.clearButtonMode = YES;
    _passwordField.secureTextEntry = YES;
    _passwordField.leftView = passwordIconView;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
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
    _passverifyField.leftView = passverifyIconView;
    _passverifyField.leftViewMode = UITextFieldViewModeAlways;
    _passverifyField.placeholder = @"请确认输入密码";
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
}

#pragma mark - Action
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
        
        //每60秒请求未读数
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    }else{
        [self showToast:@"请先输入手机号"];
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
                                   nil];
    [self showHUD:@"注册中" isDim:NO];
    
    [_submitBtn setEnabled:NO];
    //防止循环引用
    __weak FLYRegisterViewController *ref = self;
    [FLYDataService requestWithURL:kHttpMemberRegister params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadLoginData:result];
    } errorBolck:^(){
        [ref loadLoginError];
    }];
    
}

- (void)loadLoginData:(id)data{
    [_submitBtn setEnabled:YES];
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"注册成功" leftButtonTitle:nil rightButtonTitle:@"确认"];
        [alert show];
        
        alert.rightBlock = ^() {
            [self.navigationController popViewControllerAnimated:NO];
        };
        alert.dismissBlock = ^() {
            [self.navigationController popViewControllerAnimated:NO];
        };
        
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }

}

- (void)loadLoginError{
    [_submitBtn setEnabled:YES];
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

- (IBAction)backgroundTap:(id)sender {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_passverifyField resignFirstResponder];
    [_codeFiled resignFirstResponder];
}

#pragma mark - other
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
