//
//  FLYFindPasswordViewController.h
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYFindPasswordViewController : FLYBaseViewController{
    UITextField *_usernameField;
    UITextField *_passwordField;
    UITextField *_passverifyField;
    UITextField *_codeFiled;
    UIButton *_codeBtn;
    UIButton *_submitBtn;
    
    NSTimer *_timer;
}
- (IBAction)backgroundTap:(id)sender;

@end
