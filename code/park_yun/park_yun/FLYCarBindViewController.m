//
//  FLYCarBindViewController.m
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCarBindViewController.h"
#import "FLYDataService.h"
#import "UIButton+Bootstrap.h"

#define kCarBackgroundColor Color(249,249,249,1)
#define kCarBorderColor Color(204,204,204,1)
#define kCarTitColor Color(172,172,172,1)

@interface FLYCarBindViewController ()

@end

@implementation FLYCarBindViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"绑定车牌";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _carnoField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    _carnoField.layer.masksToBounds = YES;
    _carnoField.layer.borderColor = [kCarBorderColor CGColor];
    _carnoField.layer.borderWidth = 1.0f;
    _carnoField.layer.cornerRadius = 5.0;
    _carnoField.backgroundColor = kCarBackgroundColor;
    _carnoField.placeholder = @"输入车牌号";
    _carnoField.textAlignment = NSTextAlignmentCenter;
    _carnoField.textColor = [UIColor grayColor];
    _carnoField.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:_carnoField];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _carnoField.bottom + 20, 280, 0)];
    _detailLabel.numberOfLines = 0;
    _detailLabel.text = @"请输入车牌号，注意车牌号大小写。";
    _detailLabel.font = [UIFont systemFontOfSize:13.0];
    _detailLabel.textColor = [UIColor grayColor];
    [_detailLabel sizeToFit];
    [self.view addSubview:_detailLabel];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(20,_detailLabel.bottom + 20 , 280, 40);
    [_submitBtn primaryStyle];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
}

#pragma mark - 数据请求
- (void)requestUpload{
    [self showHUDProgress:@"车牌绑定中" isDim:NO];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   _carnoField.text,
                                   @"carno",
                                   nil];
    
    //防止循环引用
    __weak FLYCarBindViewController *ref = self;
    [FLYDataService requestWithURL:kHttpAddCarno params:params progress:self completeBolck:^(id result){
        [ref loadBindData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}

- (void)loadDataError{
    [self hideHUD];
    [FLYBaseUtil networkError];
}

//
- (void)loadBindData:(id)data{
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        [self showHUDComplete:@"提交成功"];
        
        if(![FLYBaseUtil checkUserBindCar]){
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_carnoField.text forKey:@"memberCarno"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        [self performSelector:@selector(closeWin) withObject:nil afterDelay:1];
    }else{
        [self hideHUD];
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

- (void)closeWin{
     [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 控件事件
- (void)submitAction:(UIButton *)button{
    if ([FLYBaseUtil isEmpty:_carnoField.text]) {
        [self showAlert:@"请输入车牌号"];
    }else{
         if ([FLYBaseUtil isEnableInternate]) {
             [self requestUpload];
         }else{
             [self showToast:@"请打开网络"];
         }
    }
}

- (IBAction)backgroundTap:(id)sender {
    [_carnoField resignFirstResponder];
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
