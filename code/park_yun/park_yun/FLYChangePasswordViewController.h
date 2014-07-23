//
//  FLYChangePasswordViewController.h
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYChangePasswordViewController : FLYBaseViewController{
    UITextField *_oldPwdField;
    UITextField *_passwordField;
    UITextField *_passverifyField;
    
    UIButton *_submitBtn;
}

- (IBAction)backgroundTap:(id)sender;

@end
