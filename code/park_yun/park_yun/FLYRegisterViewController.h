//
//  FLYRegisterViewController.h
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYRegisterViewController : FLYBaseViewController{
    UITextField *_usernameField;
    UITextField *_passwordField;
    UITextField *_passverifyField;
    UITextField *_codeFiled;
    UIButton *_codeBtn;
    UIButton *_submitBtn;
}
- (IBAction)backgroundTap:(id)sender;

@end
