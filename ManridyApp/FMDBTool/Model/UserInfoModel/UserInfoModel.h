//
//  UserInfoModel.h
//  ManridyApp
//
//  Created by JustFei on 16/10/13.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject

@property (nonatomic ,copy) NSString *userName;

@property (nonatomic ,copy) NSString *gender;

@property (nonatomic ,assign) NSInteger age;

@property (nonatomic ,assign) NSInteger height;

@property (nonatomic ,assign) NSInteger weight;

@property (nonatomic ,assign) NSInteger stepLength;

@property (nonatomic ,assign) NSInteger stepTarget;

@property (nonatomic ,assign) NSInteger sleepTarget;

+ (instancetype)userInfoModelWithUserName:(NSString *)userName andGender:(NSString *)gender andAge:(NSInteger)age andHeight:(NSInteger)height andWeight:(NSInteger)weight andStepLength:(NSInteger)stepLength andStepTarget:(NSInteger)stepTarget andSleepTarget:(NSInteger)sleepTarget;

@end
