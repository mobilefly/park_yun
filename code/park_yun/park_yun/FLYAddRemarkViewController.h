//
//  FLYAddRemarkViewController.h
//  park_yun
//
//  Created by chen on 14-7-23.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "AMRatingControl.h"

@interface FLYAddRemarkViewController : FLYBaseViewController<UITextViewDelegate>{
    UITextView *_contentView;
    UIButton *_okButton;
    
    AMRatingControl *_ratingControl;
    UILabel *_ratingLabel;
    
    AMRatingControl *_rating2Control;
    UILabel *_rating2Label;
    
    AMRatingControl *_rating3Control;
    UILabel *_rating3Label;
}


@property (nonatomic,copy) NSString *parkId;

- (IBAction)backgroundTap:(id)sender;

@end
