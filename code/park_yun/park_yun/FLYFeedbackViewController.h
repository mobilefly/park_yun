//
//  FLYFeedbackViewController.h
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"

@interface FLYFeedbackViewController : FLYBaseViewController<UITextViewDelegate>{
    UITextField *_phoneFiled;
    UITextView *_contentView;
    UIButton *_okButton;
}

- (IBAction)backgroundTap:(id)sender;

@end
