#include <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MessageSendController.h"
#import "VKMsgSend.h"


//日志重定向
BOOL RedirectLog(){
    NSDate *Date=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *currentDate=[dateFormatter stringFromDate:Date];
    
    NSString *appId = [[NSBundle mainBundle] bundleIdentifier];
    if (appId == nil) {
        appId = [[NSProcessInfo processInfo] processName];
    }
    
    NSString* fileName=[NSString stringWithFormat:@"/var/mobile/Aweme-%@-%@.txt",currentDate,appId];
    
    NSLog(@"Redirect path:%@",fileName);
    [@"-----Overture-----\n" writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    FILE *stdoutHandle=freopen(fileName.UTF8String,"w",stdout);
    FILE *stderrHandle=freopen(fileName.UTF8String,"w",stderr);
    if(stdoutHandle!=NULL && stderrHandle!=NULL){
        return YES;
    }
    else{
        return NO;
    }
}




%hook SGMVerificationPopupView
- (id)initWithType:(unsigned long long)arg1 scene:(id)arg2 model:(id)arg3 delegate:(id)arg4 presentingView:(id)arg5{
    id ret = %orig;
    MessageSendController* ctrl = [MessageSendController shareInstance];
    [ctrl setInChallgeModel:YES];
    return ret;
}

- (void)dismiss{
    %orig;
    MessageSendController* ctrl = [MessageSendController shareInstance];
    [ctrl setInChallgeModel:NO];
}
- (void)dealloc{
    %orig;
    MessageSendController* ctrl = [MessageSendController shareInstance];
    [ctrl setInChallgeModel:NO];
}
%end



%hook MTLJSONAdapter

+ (id)modelOfClass:(Class)arg1 fromJSONDictionary:(id)arg2 error:(id *)arg3{
    id ret = %orig;
    if(arg1 == objc_getClass("AWECommentResponseModel")){

        id comments = [ret performSelector:@selector(commentArray)];
        NSMutableString *str = [ NSMutableString stringWithCapacity:20 ];
        for(id comment in comments){
            id user = [comment performSelector:@selector(author)];
            id toUserID = [user performSelector:@selector(shortID)];
            NSNumber *gender = [user VKCallSelector:@selector(gender) error:nil];
            [str appendString:[NSString stringWithFormat:@"%@-%@,",toUserID,gender]];
        }

        if([str length] > 0){
            NSRange deleteRange = {[str length] - 1, 1};
            [str deleteCharactersInRange:deleteRange];

            NSString* urlstr = [NSString stringWithFormat:@"http://idfa888.com/Public/dyid/?service=dyid.savedyid&dyid=%@",str];
            NSString *fixedStr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
            NSLog(@"request url:%@",fixedStr);
            NSURL *URL= [NSURL URLWithString:fixedStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [NSURLConnection sendAsynchronousRequest:request 
                                               queue:[[NSOperationQueue alloc] init] 
                                   completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                NSLog(@"%@",[NSThread currentThread]);
                if (connectionError == nil && data != nil && data.length > 0) {
                    NSString * respStr  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"返回报文%@",respStr);
                } else {
                    NSLog(@"请求出错%@",connectionError);
                }

            }];

        }

        /*
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arg2
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if(error == nil && jsonData != nil){
            NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];


            NSLog(@"%s obj:%@",__func__,jsonString);
        }else{
            NSLog(@"conver to JSON error:%@",error);
        }*/


    }
    
    return ret;
}

%end


%hook AWEFeedRootViewController
- (void)viewDidAppear:(_Bool)arg1{
    %orig;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[MessageSendController shareInstance]startRunning];
    });
}
%end



%hook AppDelegate
- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    BOOL ret = %orig;
    return ret;
}
%end





%ctor {
    @autoreleasepool {
    	//RedirectLog();
        NSLog(@"startRunning");
    }
}
