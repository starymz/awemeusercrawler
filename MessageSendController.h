//
//  MessageSendController.h
//  DouyinHook
//
//  Created by 余孟泽 on 2018/8/24.
//  Copyright © 2018年 starymz. All rights reserved.
//

#ifndef MessageSendController_h
#define MessageSendController_h

#import <Foundation/Foundation.h>

@interface MessageSendController: NSObject

+ (instancetype) shareInstance;

- (void)setInChallgeModel:(BOOL)inChallengeModel;

- (void)startRunning;

- (void)stopRunning;

@end

#endif /* MessageSendController_h */
