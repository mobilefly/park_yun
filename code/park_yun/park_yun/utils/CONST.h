//
//  CONST.h
//
//  Created by chen on 14-6-7.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//


//主题切换通知
#define kThemeDidChangeNotification @"kThemeDidChangeNotification"
//当前位置改变
#define kMapLocationNotification @"kMapLocationNotification"

#define kNavigationBarTitleLabel @"kNavigationBarTitleLabel"

//颜色
#define Color(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

//本机
//#define kHttpDomain @"http://192.168.110.97:8080/park_yun"
//linux
#define kHttpDomain @"http://112.124.57.167:8080/park_service"
//小朱
//#define kHttpDomain @"http://192.168.110.178:8080/park_yun"

//------停车场-----
//周边停车场查询
#define kHttpQueryNearbyList @"/park/queryNearbyList.json"
//周边停车场查询(精简版本)
#define kHttpQueryNearbySimplifyList @"/park/queryNearbySimplifyList.json"
//自动巡航
#define kHttpQuerySelfMotionParkList @"/park/querySelfMotionParkList.json"
//停车场详情
#define kHttpQueryParkDetail @"/park/queryParkDetail.json"
//停车场入口列表
#define kHttpQueryParkGateList @"/park/queryParkGateList.json"
//根据城市名查询区域下的停车场信息
#define kHttpQueryParkByCityNameList @"/park/queryParkByCityNameList.json"

//------会员------
//登陆
#define kHttpLogin @"/member/loginForAes256.json"
//注销
#define kHttpLogout @"/member/logout.json"
//注册
#define kHttpMemberRegister @"/member/register.json"
//找回密码
#define kHttpFindPassword @"/member/findPwd.json"
//修改密码
#define kHttpUpdatePassword @"/member/updatePwd.json"
//添加停车场收藏
#define kHttpParkCollectAdd @"/member/addMemberCollect.json"
//删除停车场收藏
#define kHttpParkCollectRemove @"/member/removeMemberCollect.json"
//查询账单
#define kHttpQueryBillList @"/member/queryMemberTraceList.json"
//查询账单明细
#define kHttpQueryBillDetail @"/member/queryGoodsOrderList.json"
//用户反馈
#define kHttpAddFeedback @"/member/addFeedback.json"
//查询足迹
#define kHttpFootmarkList @"/member/queryParkHisList.json"
//查询停车场会员列表
#define kHttpQueryParkCardList @"/member/queryParkCardList.json"
//查询用户收藏列表
#define kHttpQueryMemberCollectList @"/member/queryMemberCollectList.json"
//查询余额
#define kHttpQueryBalance @"/member/queryBalance.json"
//查询车牌列表
#define kHttpQueryCarnoList @"/member/queryMemberCarnoList.json"
//切换默认车牌
#define kHttpChangeCarno @"/member/changeCarno.json"
//解绑车牌
#define kHttpRemoveCarno @"/member/removeCarno.json"
//绑定车牌
#define kHttpAddCarno @"/member/addMemberCarno.json"
//添加评论
#define kHttpAddRemark @"/member/addRemark.json"
//查询评论
#define kHttpQueryRemarkList @"/member/queryRemarkList.json"
//获取验证码
#define kHttpQueryVCode @"/member/sendMsg.json"
//获取未读消息数
#define kHttpQueryMessageUnread @"/member/queryMessageUnread.json"
//获取消息列表
#define kHttpQueryMessageList @"/member/queryMessageList.json"
//获取未使用优惠劵数量
#define kHttpQueryCouponUnuse @"/member/queryCouponUnuse.json"
//获取优惠劵列表
#define kHttpQueryCouponList @"/member/queryCouponList.json"
//优惠劵充值
#define kHttpCouponOrder @"/member/couponOrder.json"
//根据区域查询停车场列表
#define kHttpQueryParkListByRegion @"/common/queryParkListByRegion.json"
//查询停车场畅停卡收费标准
#define kHttpQueryBuyParkCardList @"/park/queryParkCardList.json"
//购买畅听卡
#define kHttpBuyParkCard @"/member/addParkCard.json"

//------充值------
//获取充值优惠信息
#define kHttpQueryOffInfo @"/order/queryOffInfo.json"
//生成支付宝用户充值订单接口
#define kHttpAddAlipay @"/order/addAlipayRechargeOrder.json"

//------其他------
//商圈列表
#define kHttpQueryBusinessList @"/common/queryBusinessList.json"

//------离线数据
//根据城市名，查询是否有离线数据
#define kHttpQueryOfflineByCityName @"/offline/queryOfflineByCityName.json"
//查询停车场离线数据
#define kHttpQueryOfflineData @"/offline/queryOfflineData.json"
//查询离线数据是否有更新
#define kHttpQueryOfflineUpdate @"/offline/queryOfflineUpdate.json"

//停车场标注
#define kAnnotationTypePark @"PARK"
//地图显示范围
#define kMapRange 0.005f

//json flag
#define kFlagYes @"0"

#define kNavHeight 64

//百度地图
#define kBaiduKey @"U2NLMulqHTdAa5hnalS2Ps9c"
//百度统计（公司）
#define kBaiduStat @"8c73d05bef"
//百度统计（个人测试）
//#define kBaiduStat @"c5c1533fb8"
//讯飞语音
#define kXunfeiKey @"53c47fda"

#define kAplipayPublicKey @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"


