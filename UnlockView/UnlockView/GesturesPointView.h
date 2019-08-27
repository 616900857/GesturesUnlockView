//
//  GesturesPointView.h
//  UnlockView
//
//  Created by mac on 2019/8/27.
//  Copyright © 2019 com.beng.XX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TMGesturesConfig;
typedef NS_ENUM(NSUInteger, TMGesturePointViewState) {
    GesturePointViewStateNormal = 0,
    GesturePointViewSelected,
    GesturePointViewIncorrect
};

@interface GesturesPointView : UIView

@property (assign, nonatomic) TMGesturePointViewState state;

@property (nonatomic, strong) TMGesturesConfig *config;
@end

NS_ASSUME_NONNULL_END
