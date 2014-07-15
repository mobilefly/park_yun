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

//本机
#define kHttpDomain @"http://192.168.110.24:8080/park_yun"
//window
//#define kHttpDomain @"http://123.85.3.220:8105/park_yun"
//linux
//#define kHttpDomain @"http://123.85.3.25:8105/park_yun"
//小朱
//#define kHttpDomain @"http://192.168.110.117:8080/park_yun"

#define kHttpQueryNearbyList @"/park/queryNearbyList.json"

#define kHttpQueryNearbySimplifyList @"/park/queryNearbySimplifyList.json"

#define kHttpQueryBusinessList @"/common/queryBusinessList.json"

#define kHttpQueryParkDetail @"/park/queryParkDetail.json"

#define kHttpLogin @"/member/loginForAes256.json"

#define kHttpParkCollectAdd @"/member/addMemberCollect.json"

#define kHttpParkCollectRemove @"/member/removeMemberCollect.json"

#define kHttpQueryBillList @"/member/queryMemberTrace.json"

#define kHttpFeedback @"/member/feedback.json"

#define kHttpFootmarkList @"/member/queryParkHis.json"

#define kHttpMemberRegister @"/member/register.json"

#define kHttpQueryParkCard @"/member/queryParkCard.json"


#define kAnnotationTypePark @"PARK"

#define kMapRange 0.005f

//json flag
#define kFlagYes @"0"


#define kBaiduKey @"fly2014918"
#define kXunfeiKey @""


