//
//  FLYCarBindViewController.h
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "ASIFormDataRequest.h"

@interface FLYCarBindViewController : FLYBaseViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,ASIProgressDelegate>{
    UITextField *_carnoField;
    UIButton *_uploadBtn;
    UIImageView *_photoView;
    UILabel *_detailLabel;
    UIButton *_submitBtn;
    
    BOOL _isUpload;
}

- (IBAction)backgroundTap:(id)sender;

@end
