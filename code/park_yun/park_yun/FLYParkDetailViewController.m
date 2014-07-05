//
//  FLYParkDetailViewController.m
//  park_yun
//
//  Created by chen on 14-7-3.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYParkDetailViewController.h"
#import "FLYMapViewController.h"
#import "FLYBaseNavigationController.h"
#import "RTLabel.h"
#import "DXAlertView.h"
#import "FLYDataService.h"
#import "UIButton+Bootstrap.h"

#define FontColor [UIColor darkGrayColor]
#define Padding 15

@interface FLYParkDetailViewController ()

@end

@implementation FLYParkDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"停车场详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self requestData];
}

- (void)requestData{
    if (_parkModel != nil && _parkModel.parkId.length > 0) {
        [self showHUD:@"加载中" isDim:NO];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       _parkModel.parkId,
                                       @"parkid",
                                       nil];
        
        [FLYDataService requestWithURL:kHttpQueryParkDetail params:params httpMethod:@"POST" completeBolck:^(id result){
            [self loadData:result];
        }];
    }
    
}

- (void)loadData:(id)data{
    [self hideHUD];
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        NSDictionary *result = [data objectForKey:@"result"];
        if (result != nil) {
            NSDictionary *parkDic = [result objectForKey:@"park"];
            self.park = [[FLYParkModel alloc] initWithDataDic:parkDic];
            
            NSArray *photos = [result objectForKey:@"photos"];
            if (photos != nil && [photos count] > 0) {
                NSMutableArray *photoList = [NSMutableArray arrayWithCapacity:photos.count];
                for (NSDictionary *photoDic in photos) {
                    FLYPhotoModel *photoModel = [[FLYPhotoModel alloc] initWithDataDic:photoDic];
                    [photoList addObject:photoModel];
                }
                self.photos = photoList;
            }
        }
    }
    [self renderDetail];

}

- (void)renderDetail{
    int scollHeight = 0;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 20 -44)];
    [self.view addSubview:scrollView];
    
    
    if (self.photos != nil && [self.photos count] > 0) {
        
        
        //默认图片
        UIImage *placeholderImage = [UIImage imageNamed:@"mfpparking_jiazai_all_0.png"];
        _topic = [[JCTopic alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 180)];
        //代理
        _topic.JCdelegate = self;
        NSMutableArray * photoArray = [[NSMutableArray alloc]init];
        
        for (FLYPhotoModel *photoModel in self.photos) {
            
            [photoArray addObject:[NSDictionary dictionaryWithObjects:
                                   @[photoModel.photoPath,@"",@NO,placeholderImage]
                                                              forKeys:
                                   @[@"pic",@"title",@"isLoc",@"placeholderImage"]]
             ];
        }

        //加入数据
        _topic.pics = photoArray;
        //更新
        [_topic upDate];
        [scrollView addSubview:_topic];
        
        _page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _topic.height - 10, 0, 0)];
        _page.backgroundColor = [UIColor clearColor];
        _page.numberOfPages = [photoArray count];
        _page.currentPage = 0;
        [scrollView addSubview:_page];
        
        _page.right = ScreenWidth - 2 * Padding;
        
        scollHeight += _topic.height;
    }
    
    UILabel *parkName = [[UILabel alloc] initWithFrame:CGRectMake(15, _topic.bottom + 10, 230, 0)];
    parkName.text = self.parkModel.parkName;
    parkName.backgroundColor = [UIColor clearColor];
    parkName.font = [UIFont systemFontOfSize:18.0];
    parkName.textColor = FontColor;
    parkName.numberOfLines = 0;//表示label可以多行显示
    parkName.lineBreakMode = NSLineBreakByCharWrapping;//换行模式，与上面的计算保持一致。
    [parkName sizeToFit];
    [scrollView addSubview:parkName];
    
    //分割线
    UIView *sp = [[UIView alloc] init];
    sp.frame = CGRectMake(0, parkName.bottom + 10, 320, 1);
    sp.backgroundColor =  Color(230, 230, 230, 0.6);
    [scrollView addSubview:sp];
    
    scollHeight += parkName.height + 10 + 10 + 1;
    
    //收藏图片
    UIButton *collectBtn = [UIFactory createButtonWithBackground:@"mfpparking_star_all_up.png" backgroundHightlight:@"mfpparking_star_all_down.png"];
    collectBtn.showsTouchWhenHighlighted = YES;
    collectBtn.frame = CGRectMake(0, 0, 37, 40);
    collectBtn.right = ScreenWidth - 2*Padding;
    collectBtn.top = _topic.bottom + (sp.bottom - _topic.bottom)/2 - collectBtn.height / 2;
    [collectBtn addTarget:self action:@selector(collectAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:collectBtn];
    
    //剩余车位数
    UILabel *textParkCapacity = [[UILabel alloc] initWithFrame:CGRectMake(Padding, sp.bottom + 10, 90, 20)];
    textParkCapacity.text = @"当前剩余车位";
    textParkCapacity.font = [UIFont systemFontOfSize:14.0];
    textParkCapacity.textColor = FontColor;
    [parkName sizeToFit];
    textParkCapacity.numberOfLines = 1;
    [scrollView addSubview:textParkCapacity];
    
    UILabel *parkCapacity = [[UILabel alloc] initWithFrame:CGRectMake(Padding, sp.bottom + 10, 100, 20)];
    parkCapacity.text = [NSString stringWithFormat:@"%@%@",self.parkModel.seatIdle,@"个"];
    parkCapacity.font = [UIFont systemFontOfSize:18.0];
    parkCapacity.textColor = [UIColor orangeColor];
    parkCapacity.numberOfLines = 1;
    [parkName sizeToFit];
    parkCapacity.left = textParkCapacity.right;
    [scrollView addSubview:parkCapacity];
    
    //停车场地址
    UILabel *parkAddress = [[UILabel alloc] initWithFrame:CGRectMake(Padding, parkCapacity.bottom + 5, 230, 20)];
    parkAddress.text = [NSString stringWithFormat:@"%@%@",@"地址 : ",self.parkModel.parkAddress];
    parkAddress.font = [UIFont systemFontOfSize:14.0];
    parkAddress.textColor = FontColor;
    parkAddress.numberOfLines = 0;
    [parkAddress sizeToFit];
    [scrollView addSubview:parkAddress];
    
    //分割线
    UIView *sp2 = [[UIView alloc] init];
    sp2.frame = CGRectMake(0, parkAddress.bottom + 10, 320, 1);
    sp2.backgroundColor =  Color(230, 230, 230, 0.6);
    [scrollView addSubview:sp2];
    
    scollHeight += parkCapacity.height + parkAddress.height + 10 + 5 + 10 + 1;
    
    UIButton *positionBtn = [UIFactory createButtonWithBackground:@"mfpparking_location_all_up.png" backgroundHightlight:@"mfpparking_location_all_down.png"];
    positionBtn.showsTouchWhenHighlighted = YES;
    positionBtn.frame = CGRectMake(0, 0, 37, 40);
    [positionBtn addTarget:self action:@selector(positionAction) forControlEvents:UIControlEventTouchUpInside];
    positionBtn.right = ScreenWidth - 2*Padding;
    positionBtn.top = sp.bottom + (sp2.bottom - sp.bottom)/2 - positionBtn.height / 2;
    [scrollView addSubview:positionBtn];
    
    //停车场收费标准
    UILabel *textParkFeedesc = [[UILabel alloc] initWithFrame:CGRectMake(Padding, sp2.bottom + 10, ScreenWidth - 2 * Padding, 20)];
    textParkFeedesc.text = @"停车场收费标准";
    textParkFeedesc.font = [UIFont systemFontOfSize:14.0];
    textParkFeedesc.textColor = FontColor;
    [textParkFeedesc sizeToFit];
    [scrollView addSubview:textParkFeedesc];
    
    UILabel *parkFeedesc = [[UILabel alloc] initWithFrame:CGRectMake(Padding, textParkFeedesc.bottom + 5, ScreenWidth - 2 * Padding, 20)];
    parkFeedesc.text = self.parkModel.parkFeedesc;
    parkFeedesc.font = [UIFont systemFontOfSize:14.0];
    parkFeedesc.textColor = FontColor;
    parkFeedesc.numberOfLines = 0;
    [parkFeedesc sizeToFit];
    [scrollView addSubview:parkFeedesc];
    
    //分割线
    UIView *sp3 = [[UIView alloc] init];
    sp3.frame = CGRectMake(0, parkFeedesc.bottom + 10, 320, 1);
    sp3.backgroundColor =  Color(230, 230, 230, 0.6);
    [scrollView addSubview:sp3];
    
    scollHeight += textParkFeedesc.height + parkFeedesc.height + 10 + 5 + 10 + 1;
    
    //评论按钮
    UIButton *discussBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    discussBtn.frame = CGRectMake((ScreenWidth - 160) / 2, sp3.bottom + 15, 160, 35);
    [discussBtn primaryStyle];

//    discussBtn.titleLabel.text = @"查看评论";
    [discussBtn setTitle:@"查看评论" forState:UIControlStateNormal];
    [discussBtn addAwesomeIcon:FAIconRoad beforeTitle:YES];


    [discussBtn addTarget:self action:@selector(discussAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:discussBtn];
    
    //停车场详情
    RTLabel *parkRemark = [[RTLabel alloc] initWithFrame:CGRectMake(Padding, discussBtn.bottom + 15, ScreenWidth - 2 * Padding, 0)];
    parkRemark.text = self.parkModel.parkRemark;
    parkRemark.font = [UIFont systemFontOfSize:13.0];
    parkRemark.textColor = FontColor;
    parkRemark.textAlignment = NSTextAlignmentJustified;
    //计算高度
    CGSize optimumSize = [parkRemark optimumSize];
    CGRect frame = [parkRemark frame];
    frame.size.height = (int)optimumSize.height + 5;
    [parkRemark setFrame:frame];
    
    [scrollView addSubview:parkRemark];
    scollHeight += discussBtn.height + parkRemark.height + 15 + 15 + 20;
    
    
    [scrollView setContentSize:CGSizeMake(ScreenWidth, scollHeight)];
}

#pragma mark - view other

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    if (_topic != nil) {
        //停止自己滚动的timer
        [_topic releaseTimer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - JCTopicDelegate delegate
-(void)didClick:(id)data{
    
}


-(void)currentPage:(int)page total:(NSUInteger)total{
    _page.numberOfPages = total;
    _page.currentPage = page;
}


#pragma mark - Action
- (void)positionAction{
    FLYMapViewController *mapController = [[FLYMapViewController alloc] init];
    
    NSNumberFormatter *numFormat = [[NSNumberFormatter alloc] init];
    
    mapController.lat = [numFormat numberFromString:_parkModel.parkLat];
    mapController.lon = [numFormat numberFromString:_parkModel.parkLng];
    
    FLYBaseNavigationController *baseNav = [[FLYBaseNavigationController alloc] initWithRootViewController:mapController];
    //        [self presentViewController:sendNav animated:YES completion:nil];
    [self.view.viewController presentViewController:baseNav animated:NO completion:nil];
}

- (void)collectAction{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"请先登录用户" leftButtonTitle:nil rightButtonTitle:@"确认"];
    [alert show];
    alert.rightBlock = ^() {
        
    };
    alert.dismissBlock = ^() {
        
    };
}

- (void)discussAction{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"系统提示" contentText:@"请先登录用户" leftButtonTitle:nil rightButtonTitle:@"确认"];
    [alert show];
    alert.rightBlock = ^() {
        
    };
    alert.dismissBlock = ^() {
        
    };
}


@end
