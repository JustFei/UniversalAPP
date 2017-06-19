//
//  UserInfoModel.m
//  ManridyApp
//
//  Created by JustFei on 16/10/13.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeInteger:self.gender forKey:@"gender"];
    [aCoder encodeInteger:self.age forKey:@"age"];
    [aCoder encodeInteger:self.height forKey:@"height"];
    [aCoder encodeInteger:self.weight forKey:@"weight"];
    [aCoder encodeInteger:self.stepLength forKey:@"stepLength"];
    [aCoder encodeInteger:self.stepTarget forKey:@"stepTarget"];
    [aCoder encodeInteger:self.sleepTarget forKey:@"sleepTarget"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.gender = [aDecoder decodeIntegerForKey:@"gender"];
        self.age = [aDecoder decodeIntegerForKey:@"age"];
        self.height = [aDecoder decodeIntegerForKey:@"height"];
        self.weight = [aDecoder decodeIntegerForKey:@"weight"];
        self.stepLength = [aDecoder decodeIntegerForKey:@"stepLength"];
        self.stepTarget = [aDecoder decodeIntegerForKey:@"stepTarget"];
        self.sleepTarget = [aDecoder decodeIntegerForKey:@"sleepTarget"];
    }
    return self;
}

+ (instancetype)userInfoModelWithUserName:(NSString *)userName andGender:(NSInteger)gender andAge:(NSInteger)age andHeight:(NSInteger)height andWeight:(NSInteger)weight andStepLength:(NSInteger)stepLength andStepTarget:(NSInteger)stepTarget andSleepTarget:(NSInteger)sleepTarget
{
    UserInfoModel *model = [[UserInfoModel alloc] init];
    
    model.userName = userName;
    model.gender = gender;
    model.age = age;
    model.height = height;
    model.weight = weight;
    model.stepLength = stepLength;
    model.stepTarget = stepTarget;
    model.sleepTarget = sleepTarget;
    
    return model;
}

@end
