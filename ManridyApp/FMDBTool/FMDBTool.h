//
//  FMDBTool.h
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class SportModel;
@class HeartRateModel;
@class UserInfoModel;
@class SleepModel;
@class ClockModel;

typedef enum : NSUInteger {
    SQLTypeStep = 0,
    SQLTypeHeartRate,
    SQLTypeTemperature,
    SQLTypeSleep,
    SQLTypeBloodPressure,
    SQLTypeUserInfoModel,
} SQLType;

@interface FMDBTool : NSObject

- (instancetype)initWithPath:(NSString *)path;

#pragma mark - ClockData
- (BOOL)insertClockModel:(ClockModel *)model;

- (NSMutableArray *)queryClockData;

- (BOOL)deleteClockData:(NSInteger)deleteSql;

- (BOOL)modifyClockModel:(ClockModel *)model withModifyID:(NSInteger)ID;

#pragma mark - StepData 
//插入模型数据
- (BOOL)insertStepModel:(SportModel *)model;

//查询数据,如果 传空 默认会查询表中所有数据
- (NSArray *)queryStepWithDate:(NSString *)date;

//删除数据,如果 传空 默认会删除表中所有数据
//- (BOOL)deleteData:(NSString *)deleteSql;

//修改数据
- (BOOL)modifyStepWithDate:(NSString *)date model:(SportModel *)model;

#pragma mark - HeartRateData
- (BOOL)insertHeartRateModel:(HeartRateModel *)model;

- (NSArray *)queryHeartRateWithDate:(NSString *)date;

- (BOOL)deleteHeartRateData:(NSString *)deleteSql;

#pragma mark - TemperatureData

#pragma mark - SleepData
- (BOOL)insertSleepModel:(SleepModel *)model;

- (NSArray *)querySleepWithDate:(NSString *)date;

- (BOOL)modifySleepWithID:(NSInteger)ID model:(SleepModel *)model;

- (BOOL)deleteSleepData:(NSString *)deleteSql;

#pragma mark - BloodPressureData

#pragma mark - UserInfoData
- (BOOL)insertUserInfoModel:(UserInfoModel *)model;

- (NSArray *)queryAllUserInfo;

- (BOOL)modifyUserInfoWithID:(NSInteger)ID model:(UserInfoModel *)model;

- (BOOL)modifyStepTargetWithID:(NSInteger)ID model:(NSInteger)stepTarget;

- (BOOL)modifySleepTargetWithID:(NSInteger)ID model:(NSInteger)sleepTarget;

- (BOOL)deleteUserInfoData:(NSString *)deleteSql;

#pragma mark - CloseData
- (void)CloseDataBase;

@end
