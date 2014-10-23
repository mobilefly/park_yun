//
//  FLYLoginViewController.h
//  park_yun
//
//  Created by chen on 14-7-8.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYLoginViewController : FLYBaseViewController{
    NSString *_passMd5;
    NSString *_uuid;
    NSString *_ts;
    NSString *_key;
    NSString *_usertext;
    NSString *_deviceId;
    BOOL _isLogin;
}
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *usernameBtn;
@property (weak, nonatomic) IBOutlet UIButton *passwordBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetpassBtn;



- (IBAction)passwordChange:(id)sender;

- (IBAction)usernameChange:(id)sender;

- (IBAction)backgroupTap:(id)sender;

- (IBAction)usernameClear:(id)sender;
- (IBAction)passwordClear:(id)sender;

- (IBAction)passwordEnd:(id)sender;
- (IBAction)forgetpassAction:(id)sender;
- (IBAction)registerAction:(id)sender;


@end
