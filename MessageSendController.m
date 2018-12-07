//
//  MessageSendController.m
//  DouyinHookDylib
//
//  Created by 余孟泽 on 2018/8/24.
//  Copyright © 2018年 starymz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageSendController.h"
#import "VKMsgSend.h"
#import <objc/runtime.h>
#import "hid-support.h"


static NSString *X_AUTH_PATH = @"/var/mobile/auth_info.plist";
static NSString *X_AUTH_KEY = @"lic";

OBJC_EXTERN CFTypeRef MGCopyAnswer(CFStringRef)WEAK_IMPORT_ATTRIBUTE;


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MessageSendController()
@property (nonatomic, assign) int curStep;
@property (nonatomic, assign) BOOL runMark;
@property (nonatomic, assign) BOOL challengeModel;
@end

@implementation MessageSendController


+(instancetype)shareInstance{
    
    static MessageSendController *sharedManager;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[MessageSendController alloc] init];
    });
    return sharedManager;
}


-(instancetype)init{
    if(self= [super init]){
        self.runMark = NO;
    }
    return self;
}


- (void)startRunning{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if(self.runMark ==NO && time < 1536163200){
        self.runMark = YES;
        sleep(10);
        
        [self startTimer];
    }
}


- (void)stopRunning{
    self.runMark = NO;
}


- (void)setInChallgeModel:(BOOL)inChallengeModel{
    self.challengeModel = inChallengeModel;
}

- (void)startTimer{
        
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        while (self.runMark) {

            if(self.challengeModel == YES){
                sleep(2);
                continue;
            }
            
            if(self.curStep == 0){
                //回主界面刷新视频
                [self refreshNewViewController];
                self.curStep = 1;
            }else if(self.curStep == 1){
                //点击pinglun
                [self tapCommentButton];
                sleep(2);
                self.curStep = 0;
            }
            sleep(2);
        }
    });
    
}

- (void)refreshNewViewController{
    
    id viewCtrl = [@"BTDResponder" VKCallClassSelector:@selector(topViewController) error:nil];
    while(![viewCtrl isKindOfClass:objc_getClass("AWEFeedRootViewController")]){
        hid_inject_mouse_abs_move(1,5,SCREEN_HEIGHT -5);
        hid_inject_mouse_abs_move(0,5,SCREEN_HEIGHT -5);
        sleep(2);
        viewCtrl = [@"BTDResponder" VKCallClassSelector:@selector(topViewController) error:nil];
    }
    
    //上滑
    /*
    float maxHeight = SCREEN_HEIGHT - 100;
    //float minHeight = SCREEN_HEIGHT /3;
    float width = SCREEN_WIDTH / 2;
    
    //hid_inject_mouse_keep_alive();
    for(int i = 0; i< 3; i++){
        hid_inject_mouse_abs_move(1,width,maxHeight - 100 * i);
    }
    for(int i = 0; i< 3; i++){
        hid_inject_mouse_abs_move(0,width,maxHeight - 100 * i);
    }*/
    //hid_inject_mouse_keep_alive();
    hid_inject_mouse_abs_move(1,200,500);
    usleep(50);
    hid_inject_mouse_abs_move(1,220,450);
    hid_inject_mouse_abs_move(1,240,370);
    hid_inject_mouse_abs_move(1,250,250);
    hid_inject_mouse_abs_move(0,250,250);
    
}

- (void)tapCommentButton{
    id topViewCtrl = [@"BTDResponder" VKCallClassSelector:@selector(topViewController) error:nil];
    id contentViewController = [topViewCtrl performSelector:@selector(contentViewController)];
    id tableViewController = [contentViewController performSelector:@selector(currentViewController)];
    id tableView = [tableViewController performSelector:@selector(tableView)];
    id visibleCells = [tableView performSelector:@selector(visibleCells)];
    id feedViewCell = [visibleCells objectAtIndex:0];
    id feedCellViewController = [feedViewCell performSelector:@selector(viewController)];
    id playInteractionViewController  = [feedCellViewController performSelector:@selector(interactionController)];
    UIButton* commentButton = [playInteractionViewController performSelector:@selector(commentButton)];
    
    if(commentButton != nil){
        UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
        
        CGRect rect=[commentButton convertRect:commentButton.bounds toView:window];
        
        float centerX = CGRectGetMidX(rect);
        float centerY = CGRectGetMidY(rect);
        //点击评论按钮
        hid_inject_mouse_abs_move(1,centerX,centerY);
        hid_inject_mouse_abs_move(0,centerX,centerY);
        for(int i = 0;  i < 3; i++){
            sleep(2);
            //滑动上下
            hid_inject_mouse_abs_move(1,SCREEN_WIDTH / 2 ,500);
            hid_inject_mouse_abs_move(1,SCREEN_WIDTH / 2 ,400);
            //sleep(1);
            //hid_inject_mouse_abs_move(1,SCREEN_WIDTH / 2 ,300);
            hid_inject_mouse_abs_move(0,SCREEN_WIDTH / 2 ,400);
        }
        sleep(2);
        hid_inject_mouse_abs_move(1,SCREEN_WIDTH / 2 ,150);
        hid_inject_mouse_abs_move(0,SCREEN_WIDTH / 2 ,150);
        
    }
}

@end

