//
//  manridyModel.m
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "manridyModel.h"

@implementation manridyModel

- (SetTimeModel *)setTimeModel
{
    if (!_setTimeModel) {
        _setTimeModel = [[SetTimeModel alloc] init];
    }
    
    return _setTimeModel;
}

- (SportTargetModel *)sportTargetModel
{
    if (!_sportTargetModel) {
        _sportTargetModel = [[SportTargetModel alloc] init];
    }
    
    return _sportTargetModel;
}

- (SportModel *)sportModel
{
    if (!_sportModel) {
        _sportModel = [[SportModel alloc] init];
    }
    
    return  _sportModel;
}

- (UserInfoModel *)userInfoModel
{
    if (!_userInfoModel) {
        _userInfoModel = [[UserInfoModel alloc] init];
    }
    
    return _userInfoModel;
}

- (HeartRateModel *)heartRateModel
{
    if (!_heartRateModel) {
        _heartRateModel = [[HeartRateModel alloc] init];
    }
    
    return _heartRateModel;
}

- (SleepModel *)sleepModel
{
    if (!_sleepModel) {
        _sleepModel = [[SleepModel alloc] init];
    }
    
    return _sleepModel;
}

- (NSMutableArray *)clockModelArr
{
    if (!_clockModelArr) {
        _clockModelArr = [NSMutableArray array];
    }
    
    return _clockModelArr;
}

- (Remind *)remindModel
{
    if (!_remindModel) {
        _remindModel = [[Remind alloc] init];
    }
    
    return _remindModel;
}

@end
