//
//  AlertTool.m
//  ManridyApp
//
//  Created by Faith on 2017/3/4.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "AlertTool.h"

@interface AlertTool ()<UIAlertViewDelegate>
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSMutableArray *mutableActions;
@property (nonatomic, strong) id holder;

@end

//做转换 AlertToolStyle ——> UIAlertActionStyle
static inline UIAlertActionStyle uistyle(AlertToolStyle style) {
    switch (style) {
        case AlertToolStyleCancel:
            return UIAlertActionStyleCancel;
            break;
        case AlertToolStyleDestructive:
            return UIAlertActionStyleDestructive;
            break;
            
        default:
            return UIAlertActionStyleDefault;
            break;
    }
}

@implementation AlertTool

-(void)dealloc {
    [self dismiss];
    self.mutableActions = nil;
    self.title = nil;
    self.message = nil;
}

-(void)dismiss {
    self.holder = nil;
}

+(instancetype)alertWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style{
    return [[AlertTool alloc] initWithTitle:title message:message style:style];
}

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(UIAlertControllerStyle)style{
    if ((self = [super init])) {
        self.title = title;
        self.message = message;
        self.alertStyle = style;
        
        if (SYSTEM_VERSION >= 8.0) {
            self.alertController = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:self.alertStyle ? UIAlertControllerStyleAlert : self.alertStyle];
        }else {
            self.holder = self; //在show之前先hold住self，以便能够正常回调action。原因是，如果不hold住当前self的话，show方法结束后self即被释放，此时UIAlertView的delegate=nil，导致不能正常回调
            
            self.alertView = [[UIAlertView alloc] initWithTitle:_title
                                                        message:_message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil, nil];
        }
    }
    
    return self;
}

/**
 *  show方法，show的时候再根据系统创建不同的alert。
 *  如果在init方法就创建alert的话，务必会声明一个id alert变量供addAction使用
 *  此时如果用户没有再调用show方法，此时UIAlertController会hold住self，导致不能跑到dealloc而内存泄漏
 */
-(void)show {
    if (SYSTEM_VERSION >= 8.0) {
        for (AlertAction *action in _mutableActions) {
            [self.alertController addAction:[UIAlertAction actionWithTitle:action.title style:uistyle(action.style) handler:^(UIAlertAction *alertAction) {
                
                [self processForClicked:action];
                
                [self dismiss];
            }]];
        }
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (!viewController) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                if (window.rootViewController) {
                    viewController = window.rootViewController;
                }
            }
        }
        
        [viewController presentViewController:self.alertController animated:YES completion:nil];
    } else {
        for (AlertAction *action in _mutableActions) {
            [self.alertView addButtonWithTitle:action.title];
        }
        [self.alertView show];
    }
}

-(void)processForClicked:(AlertAction *)action {
    AlertActionHandler block = action.handler; //此处不直接使用action.handler的原因是，如果多线程操作，刚进入if(action.handler){//此时正好被其他线程修改了action.handler=nil，那么下面调研action.handler()将会crash，因为block已经不存在了}。 ps：此处不会有多线程调用，只是为了时刻保持良好的认知
    if (block) {
        block(action);
    }
}

-(NSArray *)actions {
    return _mutableActions;
}

-(void)addAction:(AlertAction *)action {
    if (!_mutableActions) {
        self.mutableActions = [NSMutableArray array];
    }
    
    if (action) {
        [_mutableActions addObject:action];
    }
}

-(void)dismissFromSuperview
{
    if (SYSTEM_VERSION >= 8.0) {
        if (self.alertController) {
            [self.alertController dismissViewControllerAnimated:YES completion:nil];
            self.alertController = nil;
        }
    }else {
        if (self.alertView) {
            [self.alertView removeFromSuperview];
            self.alertView = nil;
        }
    }
}

-(void)addSubviewToAlert:(UIView *)dateView
{
    if (SYSTEM_VERSION >= 8.0) {
        if (self.alertController) {
            [self.alertController.view addSubview:dateView];
        }
    }else {
        if (self.alertView) {
            [self.alertView setValue:dateView forKey:@"accessoryView"];
            //[self.alertView addSubview:dateView];
        }
    }
}

#pragma mark - UIAlertView Delegate for iOS < 8.0
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= 0 && buttonIndex < _mutableActions.count) {
        AlertAction *action = [_mutableActions objectAtIndex:buttonIndex];
        [self processForClicked:action];
    }
//    [self dismiss]; //必须调用，把holder置为nil, 否则最后self释放不了，会内存泄漏
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    [self dismiss]; //必须调用，把holder置为nil, 否则最后self释放不了，会内存泄漏
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismiss]; //必须调用，把holder置为nil, 否则最后self释放不了，会内存泄漏
}

@end

#pragma mark - AlertAction

@interface AlertAction ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) AlertToolStyle style;
@end

@implementation AlertAction

-(void)dealloc {
    self.title = nil;
    self.handler = nil;
}

+ (instancetype)actionWithTitle:(NSString *)title style:(AlertToolStyle)style handler:(void (^)(AlertAction *action))handler {
    return [[AlertAction alloc] initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(AlertToolStyle)style handler:(void (^)(AlertAction *action))handler {
    if ((self = [super init])) {
        self.title = title;
        self.handler = handler;
        self.style = style;
    }
    
    return self;
}

@end
