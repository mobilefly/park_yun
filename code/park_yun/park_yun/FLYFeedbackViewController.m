//
//  FLYFeedbackViewController.m
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYFeedbackViewController.h"
#import "UIFactory.h"
#import "FLYDataService.h"
#import "DXAlertView.h"

#define kBackgroundColor Color(249,249,249,1)

@interface FLYFeedbackViewController ()

@end

@implementation FLYFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"意见反馈";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _phoneFiled = [[UITextField alloc] init];
    _phoneFiled.frame = CGRectMake(20, 20, 280, 40);
    _phoneFiled.borderStyle = UITextBorderStyleRoundedRect;
    _phoneFiled.placeholder = @"请输入手机号码";
    [_phoneFiled setFont:[UIFont systemFontOfSize:14.0f]];
    _phoneFiled.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_phoneFiled];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(20, _phoneFiled.bottom + 10, 200, 20)];
    info.numberOfLines = 1;
    info.text = @"问题描述";
    [info setFont:[UIFont systemFontOfSize:14.0f]];
    [self.view addSubview:info];
    
    _contentView = [[UITextView alloc] init];
    _contentView.layer.borderWidth = 1;
    _contentView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _contentView.layer.cornerRadius = 2.0;
    _contentView.backgroundColor = kBackgroundColor;
//    _contentView.background = [UIImage imageWithCGImage:[kBackgroundColor CGColor]];
    _contentView.text = @"在此处输入你的反馈意见";
    _contentView.frame = CGRectMake(20,info.bottom + 10 , 280, 120);
    _contentView.textColor = [UIColor grayColor];
    [_contentView setFont:[UIFont systemFontOfSize:14.0f]];
    _contentView.textAlignment = NSTextAlignmentCenter;
    
    _contentView.delegate = self;
    
    [self.view addSubview:_contentView];
    
    _okButton = [UIFactory createButton:@"mfpparking_tj_all_up.png" hightlight:@"mfpparking_tj_all_down.png"];
    _okButton.frame = CGRectMake(20, _contentView.bottom + 10, 280, 40);
    [_okButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_okButton];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *memberPhone = [defaults stringForKey:@"memberPhone"];
    if ([FLYBaseUtil isNotEmpty:memberPhone]) {
        _phoneFiled.text = memberPhone;
    }
}

#pragma mark - UITextViewDelegate delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    _contentView.textAlignment = NSTextAlignmentJustified;
    if ([_contentView.text isEqualToString:@"在此处输入你的反馈意见"]) {
        _contentView.text = @"";
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        _contentView.transform = CGAffineTransformMakeTranslation(0 , -80);
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.4 animations:^{
        _contentView.transform = CGAffineTransformIdentity;
    }];
}

-(void)submitAction:(UIButton *)button{
    if ([FLYBaseUtil isEmpty:_contentView.text] || [_contentView.text isEqualToString:@"在此处输入你的反馈意见"]) {
        [self showToast:@"请填写意见"];
    }else{
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [defaults stringForKey:@"memberId"];
        NSString *token = [defaults stringForKey:@"token"];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:5];
        [params setObject:_contentView.text forKey:@"content"];
        //建议
        [params setObject:@"2" forKey:@"type"];
        if ([FLYBaseUtil isNotEmpty:userid] && [FLYBaseUtil isNotEmpty:token]) {
            [params setObject:userid forKey:@"userid"];
            [params setObject:token forKey:@"token"];
            //1 App类型(1.ios 2.android)
            [params setObject:@"1" forKey:@"app_type"];
        }
        
        if ([FLYBaseUtil isNotEmpty:_phoneFiled.text]){
            [params setObject:_phoneFiled.text forKey:@"contact"];
        }
        
        //防止循环引用
        __weak FLYFeedbackViewController *ref = self;
        [FLYDataService requestWithURL:kHttpAddFeedback params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadFeedbackData:result];
        } errorBolck:^(){
            [ref loadLoginError];
        }];
    }
}

- (void)loadFeedbackData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"感谢你的意见" leftButtonTitle:nil rightButtonTitle:@"确认"];
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
    [FLYBaseUtil alertErrorMsg];
}

- (IBAction)backgroundTap:(id)sender {
    [_phoneFiled resignFirstResponder];
    [_contentView resignFirstResponder];
}

#pragma mark - other
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
