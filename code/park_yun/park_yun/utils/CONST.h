//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 陈晟. All rights reserved.
//


//主题切换通知
#define kThemeDidChangeNotification @"kThemeDidChangeNotification"
#define kNavigationBarTitleLabel @"kNavigationBarTitleLabel"

//颜色
#define Color(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

//http
//#define kHttpDomain @"http://192.168.110.13:8080/park_yun"
#define kHttpDomain @"http://123.85.3.220:8105/park_yun"

#define kHttpQueryNearbyList @"/park/queryNearbyList.json"

#define kHttpQueryBusinessList @"/common/queryBusinessList.json"

#define kHttpQueryParkDetail @"/park/queryParkDetail.json"



//json flag
#define kFlagYes @"0"
