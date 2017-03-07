//
//  AlertTool.h
//  ManridyApp
//
//  Created by Faith on 2017/3/4.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//系统版本号
#define SYSTEM_VERSION      [[[UIDevice currentDevice] systemVersion] floatValue]

@class AlertAction;

/**
 *  封装自适应系统的ZCMAlert (UIAlertView和UIAlertController)
 */
@interface AlertTool : NSObject
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, assign) UIAlertControllerStyle alertStyle;

+(instancetype)alertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style;
-(void)show;
-(void)addAction:(AlertAction *)action;
-(void)dismissFromSuperview;
-(void)addSubviewToAlert:(UIView *)dateView;

@end

/**
 *  AlertToolStyle 只针对iOS 8.0及以上有效
 */
typedef NS_ENUM(NSInteger, AlertToolStyle) {
    AlertToolStyleDefault = 0,
    AlertToolStyleCancel,
    AlertToolStyleDestructive
};

typedef void(^AlertActionHandler)(AlertAction *);

/**
 *  AlertAction为alert view上的按钮动作类，一个按钮对应一个handler及一个title
 */
@interface AlertAction : NSObject
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) AlertToolStyle style;
@property (copy) AlertActionHandler handler;

+ (instancetype)actionWithTitle:(NSString *)title style:(AlertToolStyle)style handler:(void (^)(AlertAction *action))handler;

@end
