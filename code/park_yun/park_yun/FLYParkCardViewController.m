//
//  FLYParkCardViewController.m
//  park_yun
//
//  Created by chen on 14-12-15.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkCardViewController.h"
#import "FLYDBUtil.h"
#import "FLYRegionModel.h"
#import "FLYParkModel.h"
#import "FLYShopModel.h"
#import "FLYParkCardModel.h"
#import "FLYDataService.h"
#import "FLYParkCardShopViewController.h"


#define SpColor Color(220, 220, 220, 1)

@interface FLYParkCardViewController ()

@end

@implementation FLYParkCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"购买畅停卡";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //购物车按钮
    UIButton *shopBtn = [UIFactory createButton:@"icon_shopping_up.png" hightlight:@"icon_shopping_down.png"];
    shopBtn.frame = CGRectMake(0, 0, 30, 30);
    shopBtn.showsTouchWhenHighlighted = YES;
    [shopBtn addTarget:self action:@selector(toShopAction) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *shopItem = [[UIBarButtonItem alloc] initWithCustomView:shopBtn];
    self.navigationItem.rightBarButtonItem = shopItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44 * 4) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self setExtraCellLineHidden:_tableView];
    [self.view addSubview:_tableView];
    

}

- (void)initParkDetail{
    _selectIndex = 0;
    
    //收费标准选择高度
    int btnHeight = ([self.parkCardList count] - 1) / 3 * 40 + 50;
    
    _parkDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, btnHeight + 220)];
    _parkDetailView.backgroundColor = [UIColor whiteColor];
    
    _detailView = [[FLYParkCardDetailView alloc] initWithView:_parkDetailView];
    [_detailView showInView:nil];

    //分割线
    UIView *sp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    sp.backgroundColor =  SpColor;
    [_parkDetailView addSubview:sp];
    
    _parkNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, sp.bottom + 10, ScreenWidth - 10, 25)];
    _parkNameLabel.text = _parkTitle;
    _parkNameLabel.backgroundColor = [UIColor clearColor];
    _parkNameLabel.font = [UIFont systemFontOfSize:16.0];
    [_parkDetailView addSubview:_parkNameLabel];
    
    //分割线
    UIView *sp2 = [[UIView alloc] initWithFrame:CGRectMake(0, _parkNameLabel.bottom + 10, ScreenWidth, 1)];
    sp2.backgroundColor =  SpColor;
    [_parkDetailView addSubview:sp2];
    
    _tariffView = [[UIView alloc] initWithFrame:CGRectMake(0, sp2.bottom, ScreenWidth, btnHeight)];
    
    _btnArray = [NSMutableArray arrayWithCapacity:[self.parkCardList count]];
    
    for (int i = 0; i < [self.parkCardList count] ; i++) {
        FLYParkCardModel *model = [self.parkCardList objectAtIndex:i];
        int btnY = i / 3 * 40 + 10;
        int btnX = i % 3 * 100 + 15;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, 90, 30)];
        [button setTitle:[NSString stringWithFormat:@"%i个月套餐",[model.pcMonth intValue]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 4.0;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1.0;
        button.tag = 200 + i;
        if(i == 0){
            button.layer.borderColor = [[UIColor orangeColor] CGColor];
        }else{
            button.layer.borderColor = [SpColor CGColor];
        }
        
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_tariffView addSubview:button];
        [_btnArray addObject:button];
    }
    [_parkDetailView addSubview:_tariffView];
    
    FLYParkCardModel *detailModel = [self.parkCardList objectAtIndex:0];
    
    _tariffDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _tariffView.bottom, ScreenWidth, 15)];
    if ([detailModel.pcMonthadd intValue] > 0) {
        _tariffDetailLabel.text = [NSString stringWithFormat:@"套餐详情 : 买%i个月送%i个月", [detailModel.pcMonth intValue], [detailModel.pcMonthadd intValue]]; ;
    }else{
        _tariffDetailLabel.text = [NSString stringWithFormat:@"套餐详情 : %i个月套餐", [detailModel.pcMonth intValue]];
    }
    
    _tariffDetailLabel.backgroundColor = [UIColor clearColor];
    _tariffDetailLabel.font = [UIFont systemFontOfSize:13.0];
    [_parkDetailView addSubview:_tariffDetailLabel];
    
    _tariffTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _tariffDetailLabel.bottom + 5, ScreenWidth - 150 - 30, 15)];
    _tariffTitleLabel.text = @"套餐单价 : ";
    _tariffTitleLabel.backgroundColor = [UIColor clearColor];
    _tariffTitleLabel.font = [UIFont systemFontOfSize:13.0];
    [_parkDetailView addSubview:_tariffTitleLabel];
    
    _tariffPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_tariffTitleLabel.right, _tariffDetailLabel.bottom + 5, 150, 15)];
    _tariffPriceLabel.text = [NSString stringWithFormat:@"￥%.2f元",[detailModel.pcPrice floatValue] / 100];
    _tariffPriceLabel.backgroundColor = [UIColor clearColor];
    _tariffPriceLabel.font = [UIFont systemFontOfSize:13.0];
    _tariffPriceLabel.textColor = [UIColor orangeColor];
    _tariffPriceLabel.textAlignment = NSTextAlignmentRight;
    [_parkDetailView addSubview:_tariffPriceLabel];
    
    //分割线
    UIView *sp3 = [[UIView alloc] initWithFrame:CGRectMake(0, _tariffPriceLabel.bottom + 5, ScreenWidth, 1)];
    sp3.backgroundColor =  SpColor;
    [_parkDetailView addSubview:sp3];
   
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, sp3.bottom + 15, 100, 15)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:13.0];
    title.text = @"数量 : ";
    [_parkDetailView addSubview:title];
    
    _reduceButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 125, sp3.bottom + 12.5, 20, 20)];
    [_reduceButton setBackgroundImage:[UIImage imageNamed:@"mfpparking_gmctkcut_all_0.png"] forState:UIControlStateNormal];
    [_reduceButton addTarget:self action:@selector(reduceAction) forControlEvents:UIControlEventTouchDown];
    [_parkDetailView addSubview:_reduceButton];
    
    _numField = [[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth - 90, sp3.bottom + 10, 40, 25)];
    _numField.borderStyle = UITextBorderStyleRoundedRect;
    _numField.font = [UIFont systemFontOfSize:13.0];
    _numField.returnKeyType = UIReturnKeyDone;
    _numField.text = @"1";
    _numField.userInteractionEnabled = NO;
    _numField.textAlignment = NSTextAlignmentCenter;
    [_parkDetailView addSubview:_numField];
    
    _increaseButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 35, sp3.bottom + 12.5, 20, 20)];
    [_increaseButton setBackgroundImage:[UIImage imageNamed:@"mfpparking_gmctkadd_all_0.png"] forState:UIControlStateNormal];
    [_increaseButton addTarget:self action:@selector(increaseAction) forControlEvents:UIControlEventTouchDown];
    [_parkDetailView addSubview:_increaseButton];
    
    _totalPirceLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 200 - 15, _reduceButton.bottom + 15, 200, 25)];
    _totalPirceLabel.text = [NSString stringWithFormat:@"共 : ￥%.2f元",[detailModel.pcPrice floatValue] / 100];
    _totalPirceLabel.backgroundColor = [UIColor clearColor];
    _totalPirceLabel.font = [UIFont systemFontOfSize:16.0];
    _totalPirceLabel.textColor = [UIColor orangeColor];
    _totalPirceLabel.textAlignment = NSTextAlignmentRight;
    [_parkDetailView addSubview:_totalPirceLabel];
    
    _shopButton = [[UIButton alloc] initWithFrame:CGRectMake(15, _totalPirceLabel.bottom + 10, 140, 35)];
    [_shopButton setTitle:@"加入购物车" forState:UIControlStateNormal];
    [_shopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shopButton setBackgroundColor:Color(19, 142, 235, 1)];
    _shopButton.showsTouchWhenHighlighted = YES;
    _shopButton.layer.cornerRadius = 4.0;
    _shopButton.layer.masksToBounds = YES;
    _shopButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_shopButton addTarget:self action:@selector(shopAction) forControlEvents:UIControlEventTouchUpInside];
    [_parkDetailView addSubview:_shopButton];
    
    _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(_shopButton.right + 10, _totalPirceLabel.bottom + 10, 140, 35)];
    [_buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
    [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buyButton setBackgroundColor:[UIColor orangeColor]];
    _buyButton.showsTouchWhenHighlighted = YES;
    _buyButton.layer.cornerRadius = 4.0;
    _buyButton.layer.masksToBounds = YES;
    _buyButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_buyButton addTarget:self action:@selector(buyAction) forControlEvents:UIControlEventTouchUpInside];
    [_parkDetailView addSubview:_buyButton];
  
}

#pragma mark - Action
-(void)increaseAction{
    //收费标准
    FLYParkCardModel *detailModel = [self.parkCardList objectAtIndex:_selectIndex];
    
    int num = [_numField.text intValue] + 1;
    _numField.text = [NSString stringWithFormat:@"%i",num];
    
    _totalPirceLabel.text = [NSString stringWithFormat:@"共 : ￥%.2f元",[detailModel.pcPrice floatValue] / 100 * num];
}

-(void)reduceAction{
    int num = [_numField.text intValue];
    if (num > 1) {
        
        //收费标准
        FLYParkCardModel *detailModel = [self.parkCardList objectAtIndex:_selectIndex];
        
        int num = [_numField.text intValue] - 1;
        _numField.text = [NSString stringWithFormat:@"%i",num];
        _totalPirceLabel.text = [NSString stringWithFormat:@"共 : ￥%.2f元",[detailModel.pcPrice floatValue] / 100 * num];
    }

}

-(void)changeAction:(UIButton *)button{
    //改变选中收费标准样式
    for (UIButton *btn in _btnArray) {
        if (btn.tag == button.tag) {
            btn.layer.borderColor = [[UIColor orangeColor] CGColor];
        }else{
            btn.layer.borderColor = [SpColor CGColor];
        }
    }
    
    _selectIndex = button.tag - 200;
    
    FLYParkCardModel *detailModel = [self.parkCardList objectAtIndex:_selectIndex];
    if ([detailModel.pcMonthadd intValue] > 0) {
        _tariffDetailLabel.text = [NSString stringWithFormat:@"套餐详情 : 买%i个月送%i个月", [detailModel.pcMonth intValue], [detailModel.pcMonthadd intValue]]; ;
    }else{
        _tariffDetailLabel.text = [NSString stringWithFormat:@"套餐详情 : %i个月套餐", [detailModel.pcMonth intValue]];
    }
    _tariffPriceLabel.text = [NSString stringWithFormat:@"￥%.2f元",[detailModel.pcPrice floatValue] / 100];
    _numField.text = @"1";
    _totalPirceLabel.text = [NSString stringWithFormat:@"共 : ￥%.2f元",[detailModel.pcPrice floatValue] / 100];
}

- (void)shopAction{
    [self addShop];
    [self showToast:@"已加入购物车"];
}

- (void)buyAction{
    [self addShop];
    
    [_detailView removeFromSuperview];
    
    FLYParkCardShopViewController *shopController = [[FLYParkCardShopViewController alloc]init];
    [self.navigationController pushViewController:shopController animated:NO];
}

- (void)toShopAction{
    FLYParkCardShopViewController *shopController = [[FLYParkCardShopViewController alloc]init];
    [self.navigationController pushViewController:shopController animated:NO];
}

- (void)addShop{
    FLYParkCardModel *detailModel = [self.parkCardList objectAtIndex:_selectIndex];
    int count = [_numField.text intValue];

    NSMutableArray *shopArray = [FLYBaseUtil getDelegateShop];
    if (shopArray == nil) {
        shopArray = [[NSMutableArray alloc] init];
    }
    
    BOOL flag = NO;
    for (FLYShopModel *shopModel in shopArray) {
        //已购买过,增加数量
        if ([shopModel.parkCard.pcId isEqualToString:detailModel.pcId]) {
            shopModel.buyNum = shopModel.buyNum + count;
            flag = YES;
            break;
        }
    }
    
    if (!flag) {
        FLYShopModel *shopModel = [[FLYShopModel alloc] init];
        shopModel.buyNum = count;
        shopModel.parkId = _parkId;
        shopModel.parkValue = _parkTitle;
        shopModel.parkCard = detailModel;
        [shopArray addObject:shopModel];
    }
    [FLYBaseUtil setDelegateShop:shopArray];
}

#pragma mark - request
//加载停车场列表
-(void)prepareRequestParkListData{
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestParkListData];
    }else{
        [self showToast:@"请打开网络"];
    }
}

//加载停车场列表
-(void)requestParkListData{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   _areaId,
                                   @"regionId",
                                   nil];
    
    //防止循环引用
    __weak FLYParkCardViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryParkListByRegion params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadParkListData:result];
    } errorBolck:^(){
        [ref loadDataError:YES];
    }];
}

//加载停车场列表
- (void)loadParkListData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *parks = [result objectForKey:@"parks"];
            
            
            NSMutableArray *parkList = [NSMutableArray arrayWithCapacity:parks.count];
            for (NSDictionary *parkDic in parks) {
                FLYParkModel *parkModel = [[FLYParkModel alloc] initWithDataDic:parkDic];
                [parkList addObject:parkModel];
            }
            
            self.parkList = parkList;
            if([parkList count] == 0){
                [self showToast:@"该区域暂无提供畅停卡的停车场"];
            }else{
                [self showParkPicker:parkList];
            }
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

//加载停车场收费标准
-(void)prepareRequestParkCardListData{
    if ([FLYBaseUtil isEnableInternate]) {
        [self showHUD:@"加载中" isDim:NO];
        [self requestParkCardListData];
    }else{
        [self showToast:@"请打开网络"];
    }
}

//加载停车场收费标准
-(void)requestParkCardListData{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   _parkId,
                                   @"parkId",
                                   nil];
    
    //防止循环引用
    __weak FLYParkCardViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryBuyParkCardList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadParkCardListData:result];
    } errorBolck:^(){
        [ref loadDataError:YES];
    }];
}

//加载停车场收费标准
- (void)loadParkCardListData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *parkCards = [result objectForKey:@"parkCards"];
            
            NSMutableArray *parkCardList = [NSMutableArray arrayWithCapacity:parkCards.count];
            for (NSDictionary *parkCardDic in parkCards) {
                FLYParkCardModel *parkCardModel = [[FLYParkCardModel alloc] initWithDataDic:parkCardDic];
                [parkCardList addObject:parkCardModel];
            }
            
            self.parkCardList = parkCardList;
            if ([parkCardList count] > 0) {
                [self initParkDetail];
            }else{
                [self showToast:@"该停车场暂无畅停卡"];
            }
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}


-(void)loadDataError:(BOOL)isFirst{
    [self hideHUD];
    [FLYBaseUtil networkError];
}

#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ParkCardCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
    if(indexPath.row == 0){
        
        if([FLYBaseUtil isNotEmpty:_provinceId]){
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = _provinceTitle;
        }else{
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = @"请选择省份";
        }
        
    }else if(indexPath.row == 1){
        
        if([FLYBaseUtil isNotEmpty:_cityId]){
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = _cityTitle;
        }else{
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = @"请选择城市";
        }
        
    }else if(indexPath.row == 2){
        
        if([FLYBaseUtil isNotEmpty:_areaId]){
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = _areaTitle;
        }else{
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = @"请选择区域";
        }
        
    }else if(indexPath.row == 3){
        
        if([FLYBaseUtil isNotEmpty:_parkId]){
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = _parkTitle;
        }else{
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text = @"请选择停车场";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self didSelectProvince];
    }else if(indexPath.row == 1){
        [self didSelectCity];
    }else if(indexPath.row == 2){
        [self didSelectArea];
    }else if(indexPath.row == 3){
        [self didSelectPark];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 下拉选择栏
- (void)didSelectProvince{
    _listType = 0;
    
    NSMutableArray *list = [FLYDBUtil queryRegionOfProvice];
    [self showPicker:list];
}

- (void)didSelectCity{
    _listType = 1;
    
    if([FLYBaseUtil isNotEmpty:_provinceId]){
        NSMutableArray *list = [FLYDBUtil queryRegionOfCity:_provinceId];
        [self showPicker:list];
    }
}

- (void)didSelectArea{
    _listType = 2;
    
    if([FLYBaseUtil isNotEmpty:_cityId]){
        NSMutableArray *list = [FLYDBUtil queryRegionOfArea:_cityId];
        [self showPicker:list];
    }
}

- (void)didSelectPark{
    _listType = 3;
    
    if([FLYBaseUtil isNotEmpty:_areaId]){
        if(self.parkList == nil){
            [self prepareRequestParkListData];
        }else{
            if([self.parkList count] == 0){
                [self showToast:@"该区域暂无提供畅停卡的停车场"];
            }else{
                [self showParkPicker:self.parkList];
            }
        }
    }
    
}

- (void)showPicker:(NSMutableArray *)list{
    NSMutableArray *modelList = [NSMutableArray arrayWithCapacity:list.count];
    for (FLYRegionModel *region in list) {
        DownSheetModel *model = [[DownSheetModel alloc] init];
        model.title = region.regionName;
        model.value = region.regionId;
        
        [modelList addObject:model];
    }
    _listData = [NSArray arrayWithArray:modelList];
    
    DownSheet *sheet;
    if (_listType == 0) {
        sheet = [[DownSheet alloc]initWithlist:_listData height:44 * 7 original:_provinceId];
    }else if(_listType == 1){
        sheet = [[DownSheet alloc]initWithlist:_listData height:44 * 7 original:_cityId];
    }else if(_listType == 2){
        sheet = [[DownSheet alloc]initWithlist:_listData height:44 * 7 original:_areaId];
    }
    sheet.delegate = self;
    [sheet showInView:nil];
}

- (void)showParkPicker:(NSMutableArray *)list{
    NSMutableArray *modelList = [NSMutableArray arrayWithCapacity:list.count];
    for (FLYParkModel *park in list) {
        DownSheetModel *model = [[DownSheetModel alloc] init];
        model.title = park.parkName;
        model.value = park.parkId;
        [modelList addObject:model];
    }
    _listData = [NSArray arrayWithArray:modelList];
    
    DownSheet *sheet = [[DownSheet alloc]initWithlist:_listData height:44 * 7 original:_parkId];
    sheet.delegate = self;
    [sheet showInView:nil];
}

#pragma mark - DownSheetDelegate
- (void)didSelectIndex:(NSInteger)index{
    
    DownSheetModel *model = [_listData objectAtIndex:index];
    if(_listType == 0){
        
        _provinceId = model.value;
        _provinceTitle = model.title;
        _cityId = nil;
        _cityTitle = nil;
        _areaId = nil;
        _areaTitle = nil;
        _parkId = nil;
        _parkTitle = nil;
        
        self.parkList = nil;
        
    }else if(_listType == 1){
        
        _cityId = model.value;
        _cityTitle = model.title;
        _areaId = nil;
        _areaTitle = nil;
        _parkId = nil;
        _parkTitle = nil;
        
        self.parkList = nil;
        
    }else if(_listType == 2){
        
        _areaId = model.value;
        _areaTitle = model.title;
        _parkId = nil;
        _parkTitle = nil;
        
        self.parkList = nil;
        
    }else if(_listType == 3){
        
        _parkId = model.value;
        _parkTitle = model.title;
        [self prepareRequestParkCardListData];
        
    }
    
    [_tableView reloadData];
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}


@end
