//
//  GesturesUnlockView.h
//  UnlockView
//
//  Created by mac on 2019/8/27.
//  Copyright © 2019 com.beng.XX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TMGestureTypes) {
    GestureTypeSet = 0,
    GestureTypeReset,
    GestureTypeLogin,
    GestureTypeMemory
};

typedef NS_ENUM(NSUInteger, TMGestureResultTypes) {
    GestureLessInput = 0, //少于4位数
    GestureLogin,
    GestureVerify,
    GestureSet,
    GestureSetAgain
};
// 配置Model
@interface TMGesturesConfig : NSObject
@property (nonatomic, class, readonly) TMGesturesConfig *defaultConfig;
// circle半径
@property (nonatomic, assign) CGFloat circleRadius;
// circle颜色
@property (nonatomic, strong) UIColor *circleColorNormal;
// circle（选中)
@property (nonatomic, strong) UIColor *circleColorSelected;
// circle（错误)
@property (nonatomic, strong) UIColor *circleColorIncorrect;

// border宽度
@property (nonatomic, assign) CGFloat borderWidth;
// border颜色
@property (nonatomic, strong) UIColor *borderColorNormal;
// border（选中)
@property (nonatomic, strong) UIColor *borderColorSelected;
// border（错误)
@property (nonatomic, strong) UIColor *borderColorIncorrect;

// 线宽度
@property (nonatomic, assign) CGFloat lineWidth;
//线颜色
@property (nonatomic, strong) UIColor *lineColorSelected;
//线颜色（错误)
@property (nonatomic, strong) UIColor *lineColorIncorrect;

@end

@interface GesturesUnlockView : UIView
// 手势类型
@property (nonatomic, assign) TMGestureTypes type;
// 配置信息
@property (nonatomic, strong) TMGesturesConfig *config;
// 记忆手势ID
@property (nonatomic, copy) NSString *gestureIds;
/**
 手势回调
 */
@property (nonatomic, copy) void(^gestureResult)(TMGestureResultTypes type, BOOL result, NSString *gestureId);

/**
 初始化
 
 @param frame View Frame
 @param type 手势类型（登录、设置、重置、记忆）
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame gestureType:(TMGestureTypes)type;
@end

@interface NSString (Extend)

+ (NSString *)md5StringFromString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
