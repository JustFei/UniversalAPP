//
//  Phone&MessageModel.h
//  ManridyApp
//
//  Created by JustFei on 2016/11/10.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Remind : NSObject

@property (nonatomic ,assign) BOOL phone;
@property (nonatomic ,assign) BOOL message;
@property (nonatomic, assign) BOOL wechat;
@property (nonatomic, assign) BOOL qq;
@property (nonatomic, assign) BOOL whatsApp;
@property (nonatomic, assign) BOOL facebook;

@end
