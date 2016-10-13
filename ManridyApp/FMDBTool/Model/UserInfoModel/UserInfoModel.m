//
//  UserInfoModel.m
//  ManridyApp
//
//  Created by JustFei on 16/10/13.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel

+ (instancetype)userInfoModelWithUserName:(NSString *)userName andGender:(NSString *)gender andAge:(NSInteger)age andHeight:(NSInteger)height andWeight:(NSInteger)weight andStepLength:(NSInteger)stepLength
{
    UserInfoModel *model = [[UserInfoModel alloc] init];
    
    model.userName = userName;
    model.gender = gender;
    model.age = age;
    model.height = height;
    model.weight = weight;
    model.stepLength = stepLength;
    
    return model;
}

@end
