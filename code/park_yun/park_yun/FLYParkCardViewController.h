//
//  FLYParkCardViewController.h
//  park_yun
//
//  Created by chen on 14-12-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYBaseViewController.h"
#import "FLYParkCardDetailView.h"
#import "DownSheet.h"

@interface FLYParkCardViewController : FLYBaseViewController<UITableViewDataSource,UITableViewDelegate,DownSheetDelegate>{
    
    UITableView *_tableView;
    
    //收费标准弹出界面
    FLYParkCardDetailView *_detailView;
    UIView *_parkDetailView;
    UILabel *_parkNameLabel;
    UIView *_tariffView;
    UILabel *_tariffDetailLabel;
    UILabel *_tariffTitleLabel;
    UILabel *_tariffPriceLabel;
    UIButton *_increaseButton;
    UIButton *_reduceButton;
    UITextField *_numField;
    UILabel *_totalPirceLabel;
    UIButton *_shopButton;
    UIButton *_buyButton;
    
    //收费标准
    int _selectIndex;
    NSMutableArray *_btnArray;
    
    //省区域ID
    NSString *_provinceId;
    NSString *_provinceTitle;
    
    //市区域ID
    NSString *_cityId;
    NSString *_cityTitle;
    
    //区域ID
    NSString *_areaId;
    NSString *_areaTitle;
    
    //停车场ID
    NSString *_parkId;
    NSString *_parkTitle;
    
    //下拉类型
    int _listType;
    //下拉数据
    NSArray *_listData;
    
}

@property (strong,nonatomic) NSMutableArray *parkCardList;
@property (strong,nonatomic) NSMutableArray *parkList;

@end
