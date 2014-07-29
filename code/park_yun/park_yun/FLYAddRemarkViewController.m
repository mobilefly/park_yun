//
//  FLYAddRemarkViewController.m
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYAddRemarkViewController.h"
#import "DXAlertView.h"
#import "FLYDataService.h"
#import "FLYAppDelegate.h"

#define kBackgroundColor Color(249,249,249,1)

@interface FLYAddRemarkViewController ()

@end

@implementation FLYAddRemarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我要评论";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _contentView = [[UITextView alloc] init];
    _contentView.layer.borderWidth = 1;
    _contentView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _contentView.layer.cornerRadius = 2.0;
    _contentView.backgroundColor = kBackgroundColor;
    _contentView.text = @"请输入评论内容";
    _contentView.frame = CGRectMake(20 , 15 , 280, 120);
    _contentView.textColor = [UIColor grayColor];
    [_contentView setFont:[UIFont systemFontOfSize:14.0f]];
    _contentView.textAlignment = NSTextAlignmentCenter;
    _contentView.delegate = self;
    [self.view addSubview:_contentView];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _contentView.bottom + 20, 0, 20)];
    infoLabel.text = @"环境：";
    infoLabel.textColor = [UIColor grayColor];
    [infoLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [infoLabel sizeToFit];
    [self.view addSubview:infoLabel];

	_ratingControl = [[AMRatingControl alloc] initWithLocation:
                        CGPointMake(infoLabel.right + 10, _contentView.bottom + 20)
                        emptyImage:[UIImage imageNamed:@"mfpparking_ckplstark_all_0.png"]
                        solidImage:[UIImage imageNamed:@"mfpparking_ckplstar_all_0.png"]
                        andMaxRating:5];
    _ratingControl.tag = 101;
    [_ratingControl setRating:5];
    [_ratingControl addTarget:self action:@selector(updateRating:) forControlEvents:UIControlEventEditingChanged];
    [_ratingControl addTarget:self action:@selector(updateEndRating:) forControlEvents:UIControlEventEditingDidEnd];
    [self.view addSubview:_ratingControl];
    
    _ratingLabel = [[UILabel alloc] initWithFrame:CGRectMake(_ratingControl.right + 5, _contentView.bottom + 22, 80, 20)];
    _ratingLabel.font = [UIFont systemFontOfSize:14.0];
    _ratingLabel.textColor = [UIColor grayColor];
    _ratingLabel.text = @"5分";
    _ratingLabel.tag = 102;
    [self.view addSubview:_ratingLabel];
    
    UILabel *info2Label = [[UILabel alloc] initWithFrame:CGRectMake(20, infoLabel.bottom + 20, 0, 20)];
    info2Label.text = @"服务：";
    info2Label.textColor = [UIColor grayColor];
    [info2Label setFont:[UIFont systemFontOfSize:14.0f]];
    [info2Label sizeToFit];
    [self.view addSubview:info2Label];
    
	_rating2Control = [[AMRatingControl alloc] initWithLocation:
                      CGPointMake(info2Label.right + 10, infoLabel.bottom + 20)
                        emptyImage:[UIImage imageNamed:@"mfpparking_ckplstark_all_0.png"]
                        solidImage:[UIImage imageNamed:@"mfpparking_ckplstar_all_0.png"]
                        andMaxRating:5];
    _rating2Control.tag = 103;
    [_rating2Control setRating:5];
    [_rating2Control addTarget:self action:@selector(updateRating:) forControlEvents:UIControlEventEditingChanged];
    [_rating2Control addTarget:self action:@selector(updateEndRating:) forControlEvents:UIControlEventEditingDidEnd];
    [self.view addSubview:_rating2Control];

    _rating2Label = [[UILabel alloc] initWithFrame:CGRectMake(_rating2Control.right + 5, infoLabel.bottom + 22, 80, 20)];
    _rating2Label.font = [UIFont systemFontOfSize:14.0];
    _rating2Label.textColor = [UIColor grayColor];
    _rating2Label.text = @"5分";
    _rating2Label.tag = 104;
    [self.view addSubview:_rating2Label];
    
    UILabel *info3Label = [[UILabel alloc] initWithFrame:CGRectMake(20, info2Label.bottom + 20, 0, 20)];
    info3Label.text = @"价格：";
    info3Label.textColor = [UIColor grayColor];
    [info3Label setFont:[UIFont systemFontOfSize:14.0f]];
    [info3Label sizeToFit];
    [self.view addSubview:info3Label];
    
	_rating3Control = [[AMRatingControl alloc] initWithLocation:
                      CGPointMake(info3Label.right + 10, info2Label.bottom + 20)
                        emptyImage:[UIImage imageNamed:@"mfpparking_ckplstark_all_0.png"]
                        solidImage:[UIImage imageNamed:@"mfpparking_ckplstar_all_0.png"]
                        andMaxRating:5];
    
    _rating3Control.tag = 105;
    [_rating3Control setRating:5];
    [_rating3Control addTarget:self action:@selector(updateRating:) forControlEvents:UIControlEventEditingChanged];
    [_rating3Control addTarget:self action:@selector(updateEndRating:) forControlEvents:UIControlEventEditingDidEnd];
    [self.view addSubview:_rating3Control];
    
    _rating3Label = [[UILabel alloc] initWithFrame:CGRectMake(_ratingControl.right + 5, info2Label.bottom + 22, 80, 20)];
    _rating3Label.font = [UIFont systemFontOfSize:14.0];
    _rating3Label.textColor = [UIColor grayColor];
    _rating3Label.text = @"5分";
    _rating3Label.tag = 106;
    [self.view addSubview:_rating3Label];
    
    _okButton = [UIFactory createButton:@"mfpparking_tj_all_up.png" hightlight:@"mfpparking_tj_all_down.png"];
    _okButton.frame = CGRectMake(20, _rating3Label.bottom + 30, 280, 40);
    [_okButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_okButton];
}

#pragma mark - Action
- (void)submitAction:(UIButton *)button{
    if ([FLYBaseUtil isEmpty:_contentView.text] || [_contentView.text isEqualToString:@"请输入评论内容"]) {
        [self showToast:@"请填写评论内容"];
    }else{
        _okButton.enabled = NO;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [defaults stringForKey:@"memberId"];
        NSString *token = [defaults stringForKey:@"token"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       userid,
                                       @"userid",
                                       token,
                                       @"token",
                                       _contentView.text,
                                       @"content",
                                       _parkId,
                                       @"parkid",
                                       [NSString stringWithFormat:@"%i",_ratingControl.rating],
                                       @"scores1",
                                       [NSString stringWithFormat:@"%i",_rating2Control.rating],
                                       @"scores2",
                                       [NSString stringWithFormat:@"%i",_rating3Control.rating],
                                       @"scores3",
                                       nil];

        //防止循环引用
        __weak FLYAddRemarkViewController *ref = self;
        [FLYDataService requestWithURL:kHttpAddRemark params:params httpMethod:@"POST" completeBolck:^(id result){
            [ref loadRemarkData:result];
        } errorBolck:^(){
            [ref loadRemarkError];
        }];
    }
}

- (void)loadRemarkData:(id)data{
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        FLYAppDelegate *appDelegate = (FLYAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.reloadFlag = @"AddRemark";
        
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"感谢你的评价" leftButtonTitle:nil rightButtonTitle:@"确认"];
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
        _okButton.enabled = YES;
    }
}

- (void)loadRemarkError{
    [FLYBaseUtil alertErrorMsg];
    _okButton.enabled = YES;
}

#pragma mark - Rating

- (void)updateRating:(UIButton *)sender
{
    UILabel *label = (UILabel *)[sender.superview viewWithTag:sender.tag + 1];
	[label setText:[NSString stringWithFormat:@"%d分", [(AMRatingControl *)sender rating]]];
}

- (void)updateEndRating:(UIButton *)sender
{
    UILabel *label = (UILabel *)[sender.superview viewWithTag:sender.tag + 1];
	[label setText:[NSString stringWithFormat:@"%d分", [(AMRatingControl *)sender rating]]];
}

#pragma mark - UITextViewDelegate delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    _contentView.textAlignment = NSTextAlignmentJustified;
    if ([_contentView.text isEqualToString:@"请输入评论内容"]) {
        _contentView.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)backgroundTap:(id)sender {
    [_contentView resignFirstResponder];
}
@end
