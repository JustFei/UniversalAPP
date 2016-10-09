//
//  FMDBTool.h
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class StepDataModel;

typedef enum : NSUInteger {
    SQLTypeStep = 0,
    SQLTypeHeartRate,
    SQLTypeTemperature,
    SQLTypeSleep,
    SQLTypeBloodPressure,
} SQLType;

@interface FMDBTool : NSObject

- (instancetype)initWithPath:(NSString *)path withSQLType:(SQLType)sqlType;

#pragma mark - StepData 
//插入模型数据
- (BOOL)insertStepModel:(StepDataModel *)model;

//查询数据,如果 传空 默认会查询表中所有数据
- (NSArray *)queryStepWithDate:(NSString *)date;

//删除数据,如果 传空 默认会删除表中所有数据
//- (BOOL)deleteData:(NSString *)deleteSql;

//修改数据
- (BOOL)modifyStepWithDate:(NSString *)date model:(StepDataModel *)model;

#pragma mark - HeartRateData

#pragma mark - TemperatureData

#pragma mark - SleepData

#pragma mark - BloodPressureData

@end
