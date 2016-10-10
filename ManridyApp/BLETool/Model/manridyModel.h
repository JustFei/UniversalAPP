//
//  manridyModel.h
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/12.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SetTimeModel.h"
#import "SportModel.h"
#import "UserInfoModel.h"
#import "HeartRateModel.h"
#import "SleepModel.h"
#import "SportTargetModel.h"

typedef enum : NSUInteger {
    ResponsEcorrectnessDataFail = 0,
    ResponsEcorrectnessDataRgith,
} ResponsEcorrectnessData;

typedef enum : NSUInteger {
    ReturnModelTypeSetTimeModel = 0,
    ReturnModelTypeClockModel,
    ReturnModelTypeSportTargetModel,
    ReturnModelTypeSportModel,
    ReturnModelTypeUserInfoModel,
    ReturnModelTypeHeartRateModel,
    ReturnModelTypeSleepModel,
    ReturnModelTypeSportZeroModel,
    ReturnModelTypeHeartRateStateModel,
} ReturnModelType;

typedef enum : NSUInteger {
    SportZeroFail = 0,
    SportZeroSuccess,
} SportZero;


@interface manridyModel : NSObject

//判断返回数据是否成功
@property (nonatomic ,assign) ResponsEcorrectnessData isReciveDataRight;

//返回信息的类型
@property (nonatomic ,assign) ReturnModelType receiveDataType;

//判断运动信息清零是否成功
@property (nonatomic ,assign) SportZero sportZero;

//返回设置时间数据
@property (nonatomic ,strong) SetTimeModel *setTimeModel;

//返回运动目标数据
@property (nonatomic ,strong) SportTargetModel *sportTargetModel;

//返回运动信息数据
@property (nonatomic ,strong) SportModel *sportModel;

//返回用户信息数据
@property (nonatomic ,strong) UserInfoModel *userInfoModel;

//返回心率数据
@property (nonatomic ,strong) HeartRateModel *heartRateModel;

//返回睡眠数据
@property (nonatomic ,strong) SleepModel *sleepModel;

//闹钟数据模型
@property (nonatomic ,strong) NSMutableArray *clockModelArr;

@end



