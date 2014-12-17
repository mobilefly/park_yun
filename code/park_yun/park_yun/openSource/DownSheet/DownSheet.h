//
//  DownSheet.h
//  park_yun
//
//  Created by chen on 14-12-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownSheetCell.h"

@protocol DownSheetDelegate <NSObject>
@optional
-(void)didSelectIndex:(NSInteger)index;
@end


@interface DownSheet : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    UITableView *view;
    NSArray *listData;
    NSString *originalData;
}

-(id)initWithlist:(NSArray *)list height:(CGFloat)height original:(NSString *)original;
- (void)showInView:(UIViewController *)subView;

@property(nonatomic,assign) id <DownSheetDelegate> delegate;

@end
