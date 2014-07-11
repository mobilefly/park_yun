//
//  FLYTraceModel.h
//  park_yun
//
//  Created by chen on 14-7-11.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//


//traceReturn	string	结果(00:完成 90:停车中 99:逃逸 66:使用自助缴费但并未离开园区道闸)
//tracePoscode	String	POS终端号
//traceCarno	string	车牌号
//traceType	string	收费类型(0.正常收费 1.补交收费)
//traceAoperno	String	收费员ID(实际收费的收费员)
//traceWhitetype	string	车白名单标志(0正常车，其他对应白名单值)
//traceSeatno1	string	车位序号1
//traceDevicecode	string	设备序列号
//tracePaybatch	string	POS批次号
//tracePark	string	停车场
//tracePaydate	string	缴费日期
//traceParkend	string	离场时间
//traceSeatnum	string	占用车位数(1-3)
//tracePreamt	string	预收金额(单位为分)
//traceCartype	string	车型(0：小车 1：大车)
//traceSeatcode1	string	车位编号1
//traceIndex1	string	索引1
//tracePostrace	string	POS流水号
//traceIndex2	string	索引2
//tracePpark	string	第一个停车场
//traceSettleflag	string	结算情况(0：平衡 1未结 2POS多、3、平台多)
//tracePoperno	string	收费员ID
//tracePamt	int	第一个收费员收费金额
//traceParkbegin	String	进场时间
//tracePosbatch	String	POS批次号
//traceReserve	String	保留
//traceAmt	int	实收金额(单位为分)
//traceAgentcode	String	终端外包号
//tracePayflag	String	缴费方式(0：现金 1：刷卡5：自助缴费6：点卡 7：小时卡 8：年卡 9：停车卡)
//traceParkamt	String	应该收费金额(单位为分)
//traceParkname	String	停车场名称
//traceSystrace	String	系统流水号
//traceSysbatch	String	系统批次号
//traceParktime	String	停车时长(单位为分钟)

#import "FLYBaseModel.h"

@interface FLYTraceModel : FLYBaseModel

@property(nonatomic,copy) NSString *traceReturn;
@property(nonatomic,copy) NSString *traceCarno;
@property(nonatomic,copy) NSString *traceType;
@property(nonatomic,copy) NSString *tracePark;
@property(nonatomic,copy) NSString *tracePaydate;
@property(nonatomic,copy) NSString *traceParkend;
@property(nonatomic,copy) NSString *tracePreamt;
@property(nonatomic,copy) NSString *traceCartype;
@property(nonatomic,copy) NSString *traceParkbegin;
@property(nonatomic,copy) NSNumber *traceAmt;
@property(nonatomic,copy) NSNumber *traceParkamt;
@property(nonatomic,copy) NSString *tracePayflag;
@property(nonatomic,copy) NSString *traceParkname;
@property(nonatomic,copy) NSString *traceParktime;


@end
