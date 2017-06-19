//
//  UserInfoModel.h
//  ManridyApp
//
//  Created by JustFei on 16/10/13.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, Gender) {
    GenderMan = 0,
    GenderWoman
};

@interface UserInfoModel : NSObject < NSCoding >

@property (nonatomic ,copy) NSString *userName;
@property (nonatomic ,assign) Gender gender;
@property (nonatomic ,assign) NSInteger age;
@property (nonatomic ,assign) NSInteger height;
@property (nonatomic ,assign) NSInteger weight;
@property (nonatomic ,assign) NSInteger stepLength;
@property (nonatomic ,assign) NSInteger stepTarget;
@property (nonatomic ,assign) NSInteger sleepTarget;

+ (instancetype)userInfoModelWithUserName:(NSString *)userName andGender:(NSInteger)gender andAge:(NSInteger)age andHeight:(NSInteger)height andWeight:(NSInteger)weight andStepLength:(NSInteger)stepLength andStepTarget:(NSInteger)stepTarget andSleepTarget:(NSInteger)sleepTarget;

@end
