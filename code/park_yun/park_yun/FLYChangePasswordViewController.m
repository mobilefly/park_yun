//
//  FLYChangePasswordViewController.m
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYChangePasswordViewController.h"
#import "UIButton+Bootstrap.h"
#import "FLYDataService.h"
#import "DXAlertView.h"
#import "NSString+MD5HexDigest.h"

@interface FLYChangePasswordViewController ()

@end

@implementation FLYChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"修改密码";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *oldPwdIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] ;
    UIView *passwordIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] ;
    UIView *passverifyIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] ;
    
    UIImageView *oldPwdIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_inputpwd_all_0.png"]];
    oldPwdIcon.frame = CGRectMake(9, 8, 22, 24);
    [oldPwdIconView addSubview:oldPwdIcon];
    
    UIImageView *passwordIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_inputpwd_all_0.png"]];
    passwordIcon.frame = CGRectMake(9, 8, 22, 24);
    [passwordIconView addSubview:passwordIcon];
    
    UIImageView *passverifyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mfpparking_inputpwd_all_0.png"]];
    passverifyIcon.frame = CGRectMake(9, 8, 22, 24);
    [passverifyIconView addSubview:passverifyIcon];
    
    _oldPwdField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 280, 40)];
    _oldPwdField.borderStyle = UITextBorderStyleRoundedRect;
    _oldPwdField.clearButtonMode = YES;
    _oldPwdField.secureTextEntry = YES;
    _oldPwdField.leftView = oldPwdIconView;
    _oldPwdField.leftViewMode = UITextFieldViewModeAlways;
    _oldPwdField.placeholder = @"请输入原密码";
    _oldPwdField.keyboardType = UIKeyboardTypeASCIICapable;
    _oldPwdField.font = [UIFont systemFontOfSize:14.0];
    _oldPwdField.returnKeyType = UIReturnKeyNext;
    _oldPwdField.tag = 101;
    [_oldPwdField addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_oldPwdField];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, _oldPwdField.bottom + 10, 280, 40)];
    _passwordField.borderStyle = UITextBorderStyleRoundedRect;
    _passwordField.clearButtonMode = YES;
    _passwordField.secureTextEntry = YES;
    _passwordField.leftView = passwordIconView;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.placeholder = @"请输入新密码";
    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordField.font = [UIFont systemFontOfSize:14.0];
    _passwordField.returnKeyType = UIReturnKeyNext;
    _passwordField.tag = 102;
    [_passwordField addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_passwordField];
    
    _passverifyField = [[UITextField alloc] initWithFrame:CGRectMake(20, _passwordField.bottom + 10, 280, 40)];
    _passverifyField.clearButtonMode = YES;
    _passverifyField.borderStyle = UITextBorderStyleRoundedRect;
    _passverifyField.secureTextEntry = YES;
    _passverifyField.leftView = passverifyIconView;
    _passverifyField.leftViewMode = UITextFieldViewModeAlways;
    _passverifyField.placeholder = @"请确认新密码";
    _passverifyField.keyboardType = UIKeyboardTypeASCIICapable;
    _passverifyField.font = [UIFont systemFontOfSize:14.0];
    _passverifyField.returnKeyType = UIReturnKeyDone;
    _passverifyField.tag = 103;
    [_passverifyField addTarget:self action:@selector(didEndAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_passverifyField];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(20,_passverifyField.bottom + 50 , 280, 40);
    [_submitBtn primaryStyle];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
}

#pragma mark - Action
- (void)didEndAction:(UITextField *)textField{
    if (textField.tag == 101) {
        [_oldPwdField resignFirstResponder];
        [_passwordField becomeFirstResponder];
    }else if (textField.tag == 102) {
        [_passwordField resignFirstResponder];
        [_passverifyField becomeFirstResponder];
    }else if (textField.tag == 103) {
        [_passverifyField resignFirstResponder];
        [self submitAction];
    }
}

- (void)submitAction{
    [_oldPwdField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_passverifyField resignFirstResponder];
    
    if ([FLYBaseUtil isEmpty:_oldPwdField.text]) {
        [self showToast:@"请输入原密码"];
        return;
    }else if([FLYBaseUtil isEmpty:_passwordField.text] || [FLYBaseUtil isEmpty:_passverifyField.text]){
        [self showToast:@"请输入新密码"];
        return;
    }else if (![_passwordField.text isEqualToString:_passverifyField.text]) {
        [self showToast:@"两次新密码输入不相同"];
        return;
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    //kHttpMemberRegister
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   [_oldPwdField.text md5HexDigest],
                                   @"pwd",
                                   [_passwordField.text md5HexDigest],
                                   @"newPwd",
                                   nil];
    [self showHUD:@"注册中" isDim:NO];
    
    [_submitBtn setEnabled:NO];
    //防止循环引用
    __weak FLYChangePasswordViewController *ref = self;
    [FLYDataService requestWithURL:kHttpUpdatePassword params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadData:result];
    } errorBolck:^(){
        [ref loadError];
    }];
}

- (void)loadData:(id)data{
    [_submitBtn setEnabled:YES];
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        [FLYBaseUtil clearUserInfo];
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"密码重置成功" leftButtonTitle:nil rightButtonTitle:@"确认"];
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

- (void)loadError{
    [_submitBtn setEnabled:YES];
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}

#pragma mark - Action
- (IBAction)backgroundTap:(id)sender {
    [_oldPwdField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_passverifyField resignFirstResponder];
}

#pragma mark - other
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
