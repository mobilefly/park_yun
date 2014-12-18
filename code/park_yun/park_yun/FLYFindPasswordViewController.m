//
//  FLYFindPasswordViewController.m
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYFindPasswordViewController.h"
#import "FLYDataService.h"
#import "DXAlertView.h"
#import "NSString+MD5HexDigest.h"
#import "UIButton+Bootstrap.h"

#define bgColor Color(241,241,241,1)
#define textBorderColor Color(206,206,206,1)

@interface FLYFindPasswordViewController ()

@end

@implementation FLYFindPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"找回密码";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    step = 0;
    
    self.view.backgroundColor = bgColor;
    
    //返回事件
    self.ctrlDelegate = self;
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 20, 300, 40)];
    _usernameField.borderStyle = UITextBorderStyleNone;
    _usernameField.placeholder = @"请输入手机号";
    _usernameField.textAlignment = NSTextAlignmentLeft;
    _usernameField.keyboardType = UIKeyboardTypePhonePad;
    _usernameField.font = [UIFont systemFontOfSize:15.0];
    _usernameField.returnKeyType = UIReturnKeyNext;
    _usernameField.backgroundColor = [UIColor whiteColor];
    _usernameField.layer.borderColor = [textBorderColor CGColor];
    _usernameField.layer.borderWidth = 1.0f;
    _usernameField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone.png"]];
    _usernameField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_usernameField];
    
    _codeFiled = [[UITextField alloc] initWithFrame:CGRectMake(10, 20, 180, 40)];
    _codeFiled.borderStyle = UITextBorderStyleNone;
    _codeFiled.placeholder = @"验证码";
    _codeFiled.textAlignment = NSTextAlignmentCenter;
    _codeFiled.keyboardType = UIKeyboardTypePhonePad;
    _codeFiled.font = [UIFont systemFontOfSize:15.0];
    _codeFiled.returnKeyType = UIReturnKeyDone;
    _codeFiled.layer.borderColor = [textBorderColor CGColor];
    _codeFiled.layer.borderWidth = 1.0f;
    _codeFiled.hidden = YES;
    [self.view addSubview:_codeFiled];
    
    _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame = CGRectMake(_codeFiled.right + 20, 20, 100, 40);
    [_codeBtn primaryStyle];
    [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_codeBtn setTitle:@"60" forState:UIControlStateDisabled];
    _codeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _codeBtn.hidden = YES;
    [_codeBtn addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_codeBtn];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(10 , 20, 300, 40)];
    _passwordField.borderStyle = UITextBorderStyleNone;
    _passwordField.textAlignment = NSTextAlignmentCenter;
    _passwordField.clearButtonMode = YES;
    _passwordField.secureTextEntry = YES;
    _passwordField.placeholder = @"请输入新密码";
    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    _passwordField.font = [UIFont systemFontOfSize:15.0];
    _passwordField.returnKeyType = UIReturnKeyNext;
    _passwordField.layer.borderColor = [textBorderColor CGColor];
    _passwordField.layer.borderWidth = 1.0f;
    _passwordField.hidden = YES;
    [self.view addSubview:_passwordField];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(10,_codeBtn.bottom + 30 , 300, 40);
    [_submitBtn primaryStyle];
    [_submitBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
}


#pragma mark - 控件事件
- (void)refreshAction:(UIButton *)button{
    _codeBtn.enabled = NO;
    [_codeBtn disabledStyle];
    
    if ([FLYBaseUtil isNotEmpty:_usernameField.text]) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
        //向词典中动态添加数据
        [params setObject:_usernameField.text forKey:@"phoneNum"];
        [params setObject:@"2" forKey:@"type"];
        
         __weak FLYFindPasswordViewController *ref = self;
        [FLYDataService requestWithURL:kHttpQueryVCode params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadVCode:result];
        } errorBolck:^(){
            [ref loadError];
        }];
    }
   
    //每60秒请求未读数
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
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
    [self responderKeybord];
    
    if(step == 0){
        
        if ([FLYBaseUtil isEmpty:_usernameField.text]) {
            [self showToast:@"请输入手机号"];
            return;
        }else if(_usernameField.text.length != 11){
            [self showToast:@"手机号长度不对"];
            return;
        }
        
        _usernameField.hidden = YES;
        _codeFiled.hidden = NO;
        _codeBtn.hidden = NO;
        
        step++;
        
    }else if(step == 1){
        
        if ([FLYBaseUtil isEmpty:_codeFiled.text]) {
            [self showToast:@"请输入验证码"];
            return;
        }
        
        _codeFiled.hidden = YES;
        _codeBtn.hidden = YES;
        _passwordField.hidden = NO;
        [_submitBtn setTitle:@"完成" forState:UIControlStateNormal];
        
        step++;
        
    }else if(step == 2){

        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       _usernameField.text,
                                       @"phone",
                                       [_passwordField.text md5HexDigest],
                                       @"pwd",
                                       _codeFiled.text,
                                       @"checkNum",
                                       nil];
        [self showHUD:@"提交中" isDim:NO];
        
        [_submitBtn setEnabled:NO];
        //防止循环引用
        __weak FLYFindPasswordViewController *ref = self;
        [FLYDataService requestWithURL:kHttpFindPassword params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadData:result];
        } errorBolck:^(){
            [ref loadError];
        }];

    }
    
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
    [FLYBaseUtil networkError];
}

- (IBAction)backgroundTap:(id)sender {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_codeFiled resignFirstResponder];
}

-(void)responderKeybord{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_codeFiled resignFirstResponder];
}

#pragma mark  - FLYBaseCtrlDelegate delegate
- (BOOL)close{
    [self responderKeybord];
    
    if (step == 0) {
        return YES;
    }else if(step == 1){
        _usernameField.hidden = NO;
        _codeFiled.hidden = YES;
        _codeBtn.hidden = YES;
        
        step--;
        return NO;
    }else if(step == 2){
        _codeFiled.hidden = NO;
        _codeBtn.hidden = NO;
        _passwordField.hidden = YES;
        
        step--;
        return NO;
    }
    return YES;
    
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
