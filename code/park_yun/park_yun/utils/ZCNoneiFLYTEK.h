
/*
 需要添加系统的库
 AdSupport
 AddressBook
 QuartzCore
 SystemCOnfiguration
 AudioToolBox
 libz
 讯飞提供的库
 添加iflyMSC的时候需要注意，不要拖入工程，应该采用addfiles添加文件
 iflyMSC.frameWork
 
 注 讯飞语音当前并不支持arm64 所以需要删除arm64的支持
 
 代码示例
 //读取
 ZCNoneiFLYTEK*manager = [ZCNoneiFLYTEK shareManager];
 [manager playVoice:@"我老婆最漂亮"];
 
 //识别
 ZCNoneiFLYTEK*manager = [ZCNoneiFLYTEK shareManager];
 [manager discernBlock:^(NSString *str) {
 NSLog(@"~~~~%@",str);
 }];

 */

#import <Foundation/Foundation.h>
////语音读取
//#import "iflyMSC/IFlySpeechSynthesizer.h"
////语音识别
//#import "iflyMSC/IFlySpeechRecognizer.h"

#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"


@interface ZCNoneiFLYTEK : NSObject<IFlyRecognizerViewDelegate,IFlySpeechSynthesizerDelegate>
{
    IFlyRecognizerView *_iflyRecognizerView;
//    IFlySpeechSynthesizer *iFlySpeechSynthesizer;
//    IFlySpeechRecognizer *iflySpeechRecognizer;
    
}

@property(nonatomic,copy)void(^onResult)(NSString *);

+(id)shareManager;

//播放
-(void)playVoice:(NSString *)str;

//识别
-(void)discernBlock:(void(^)(NSString *))a;


@end
