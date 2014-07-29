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
#define kHttpDomain @"http://192.168.110.55:8080/park_yun"
//window
//#define kHttpDomain @"http://123.85.3.220:8105/park_yun"
//linux
//#define kHttpDomain @"http://123.85.3.25:8105/park_yun"
//小朱
//#define kHttpDomain @"http://192.168.110.117:8080/park_yun"

//停车场
#define kHttpQueryNearbyList @"/park/queryNearbyList.json"

#define kHttpQueryNearbySimplifyList @"/park/queryNearbySimplifyList.json"

#define kHttpQuerySelfMotionParkList @"/park/querySelfMotionParkList.json"

#define kHttpQueryParkDetail @"/park/queryParkDetail.json"

#define kHttpQueryParkGateList @"/park/queryParkGateList.json"

//会员
#define kHttpLogin @"/member/loginForAes256.json"

#define kHttpLogout @"/member/logout.json"

#define kHttpMemberRegister @"/member/register.json"

#define kHttpFindPassword @"/member/findPwd.json"

#define kHttpUpdatePassword @"/member/updatePwd.json"

#define kHttpParkCollectAdd @"/member/addMemberCollect.json"

#define kHttpParkCollectRemove @"/member/removeMemberCollect.json"

#define kHttpQueryBillList @"/member/queryMemberTraceList.json"

#define kHttpAddFeedback @"/member/addFeedback.json"

#define kHttpFootmarkList @"/member/queryParkHisList.json"

#define kHttpQueryParkCardList @"/member/queryParkCardList.json"

#define kHttpQueryMemberCollectList @"/member/queryMemberCollectList.json"

#define kHttpQueryBalance @"/member/queryBalance.json"

#define kHttpQueryCarnoList @"/member/queryMemberCarnoList.json"

#define kHttpChangeCarno @"/member/changeCarno.json"

#define kHttpRemoveCarno @"/member/removeCarno.json"

#define kHttpAddCarno @"/member/addMemberCarno.json"

#define kHttpAddRemark @"/member/addRemark.json"

#define kHttpQueryRemarkList @"/member/queryRemarkList.json"


//其他
#define kHttpQueryBusinessList @"/common/queryBusinessList.json"

#define kAnnotationTypePark @"PARK"

#define kMapRange 0.005f

//json flag
#define kFlagYes @"0"


#define kBaiduKey @"U2NLMulqHTdAa5hnalS2Ps9c"
//公司
#define kBaiduStat @"8c73d05bef"
//本地
//#define kBaiduStat @"c5c1533fb8"
#define kXunfeiKey @"53c47fda"


