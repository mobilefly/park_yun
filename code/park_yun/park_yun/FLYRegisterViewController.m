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

#define kLoginBackgroundColor Color(233,247,241,1)
#define kLoginBorderColor Color(206,215,225,1)

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
//    self.view.backgroundColor = kLoginBackgroundColor;
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
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    _usernameField.clearButtonMode = YES;
    _usernameField.layer.masksToBounds = YES;
    _usernameField.layer.borderColor = [kLoginBorderColor CGColor];
    _usernameField.layer.borderWidth = 1.0f;
    _usernameField.leftView = usernameIconView;
    _usernameField.leftViewMode = UITextFieldViewModeAlways;
    _usernameField.placeholder = @"请输入手机号";
    _usernameField.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:_usernameField];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, _usernameField.bottom + 20, 280, 40)];
    _passwordField.clearButtonMode = YES;
    _passwordField.layer.masksToBounds = YES;
    _passwordField.layer.borderColor = [kLoginBorderColor CGColor];
    _passwordField.layer.borderWidth = 1.0f;
    _passwordField.secureTextEntry = YES;
    _passwordField.leftView = passwordIconView;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.placeholder = @"请输入密码";
    [self.view addSubview:_passwordField];
    
    _passverifyField = [[UITextField alloc] initWithFrame:CGRectMake(20, _passwordField.bottom + 20, 280, 40)];
    _passverifyField.clearButtonMode = YES;
    _passverifyField.layer.masksToBounds = YES;
    _passverifyField.layer.borderColor = [kLoginBorderColor CGColor];
    _passverifyField.layer.borderWidth = 1.0f;
    _passverifyField.secureTextEntry = YES;
    _passverifyField.leftView = passverifyIconView;
    _passverifyField.leftViewMode = UITextFieldViewModeAlways;
    _passverifyField.placeholder = @"请确认输入密码";
    [self.view addSubview:_passverifyField];
    
    _codeFiled = [[UITextField alloc] initWithFrame:CGRectMake(20, _passverifyField.bottom + 20, 160, 40)];
    _codeFiled.layer.masksToBounds = YES;
    _codeFiled.layer.borderColor = [kLoginBorderColor CGColor];
    _codeFiled.layer.borderWidth = 1.0f;
    _codeFiled.placeholder = @"验证码";
    _codeFiled.textAlignment = NSTextAlignmentCenter;
    _codeFiled.keyboardType = UIKeyboardTypePhonePad;
    [self.view addSubview:_codeFiled];
    
    _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame = CGRectMake(_codeFiled.right + 20, _passverifyField.bottom + 20, 100, 40);
    [_codeBtn infoStyle];
    [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    _codeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:_codeBtn];

    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(20,_codeBtn.bottom + 20 , 280, 40);
    [_submitBtn primaryStyle];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
}

#pragma mark - Action
- (void)submitAction:(UIButton *)button{
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


@end
