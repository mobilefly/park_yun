//
//  FLYGateViewController.m
//  park_yun
//
//  Created by chen on 14-7-22.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYGateViewController.h"
#import "FLYDataService.h"
#import "FLYParkGateModel.h"

@interface FLYGateViewController ()

@end

@implementation FLYGateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"入口引导";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight- 20 - 44)];
    _tableView.hidden = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [self setExtraCellLineHidden:_tableView];
    
    
    // 创建语音合成对象,为单例模式
    _iflySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iflySpeechSynthesizer.delegate = self;
    [_iflySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    [_iflySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]];
    [_iflySpeechSynthesizer setParameter:@"xiaoyan" forKey: [IFlySpeechConstant VOICE_NAME]];
    [_iflySpeechSynthesizer setParameter:@"16000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
    [_iflySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    
    if ([FLYBaseUtil isEnableInternate]) {
        [self requestGateData];
        [self showHUD:@"加载中" isDim:NO];
    }else{
        [self showAlert:@"请打开网络"];
    }
    
    self.ctrlDelegate = self;

}

#pragma mark -delegate

-(void)requestGateData{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.parkModel.parkId,
                                   @"parkid",
                                   nil];
    
    //防止循环引用
    __weak FLYGateViewController *ref = self;
    [FLYDataService requestWithURL:kHttpQueryParkGateList params:params httpMethod:@"POST" completeBolck:^(id result){
        [ref loadGateData:result];
    } errorBolck:^(){
        [ref loadDataError];
    }];
}

- (void)loadGateData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSArray *gates = [result objectForKey:@"parkGates"];
            
            NSMutableArray *gateList = [NSMutableArray arrayWithCapacity:_datas.count];
            for (NSDictionary *gateDic in gates) {
                FLYParkGateModel *gateModel = [[FLYParkGateModel alloc] initWithDataDic:gateDic];
                [gateList addObject:gateModel];
            }
            
            _datas = gateList;
            
            if (_datas != nil && [_datas count] > 0) {
                _tableView.hidden = NO;
                [self showNoDataView:NO];
            }else{
                _tableView.hidden = YES;
                [self showNoDataView:YES];
            }
            
            [_tableView reloadData];
        }
    }else{
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

-(void)loadDataError{
    [self hideHUD];
    [FLYBaseUtil alertErrorMsg];
}



#pragma mark - UITableViewDataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_datas == nil || [_datas count] == 0) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"GateCell";
    FLYGateCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FLYGateCell" owner:self options:nil] lastObject];
        cell.gateDelegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.parkGateModel = [_datas objectAtIndex:indexPath.row];

    return cell;
}

#pragma mark - FLYGateDelegate
- (void)voice:(NSString *)title{
    [_iflySpeechSynthesizer startSpeaking:title];
}

#pragma mark - UITableViewDelegate delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    
    height = 16 + 21 + 10 + 10 + 130 + 10;
    
    //计算入口简介高度
    FLYParkGateModel *model = [_datas objectAtIndex:indexPath.row];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 0)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.text = model.gateDesc;
    label.textAlignment = NSTextAlignmentJustified;
    label.numberOfLines = 0;
    [label sizeToFit];
    
    height = height + label.height;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark  - IFlySpeechSynthesizerDelegate delegate
- (void)onCompleted:(IFlySpeechError*) error{
    //    [self showToast:@"无法发音"];
}

#pragma mark  - FLYBaseCtrlDelegate delegate
- (void)close{
    if (_iflySpeechSynthesizer != nil && _iflySpeechSynthesizer.isSpeaking) {
        [_iflySpeechSynthesizer stopSpeaking];
    }
    [IFlySpeechSynthesizer destroy];
}

#pragma mark - other
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end