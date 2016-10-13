//
//  FMDBTool.m
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FMDBTool.h"
#import "StepDataModel.h"
#import "UserInfoModel.h"


@implementation FMDBTool

static FMDatabase *_fmdb;

#pragma mark - init
/**
 *  创建数据库文件
 *
 *  @param path 数据库名字，以用户名+MotionData命名
 *
 */
- (instancetype)initWithPath:(NSString *)path withSQLType:(SQLType)sqlType
{
    self = [super init];
    
    if (self) {
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.sqlite",path]];
        _fmdb = [FMDatabase databaseWithPath:filepath];
        
        NSLog(@"数据库路径 == %@", filepath);
        
        if ([_fmdb open]) {
            NSLog(@"数据库打开成功");
        }
        switch (sqlType) {
            case SQLTypeStep:
                [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists MotionData(id integer primary key, date text, step text, kCal text, mileage text);"]];
                break;
            case SQLTypeHeartRate:
                //心率数据库还没有建立好
                [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists GPSData(id integer primary key, );"]];
                break;
            case SQLTypeTemperature:
                
                break;
            case SQLTypeSleep:
                
                break;
            case SQLTypeBloodPressure:
                
                break;
            case SQLTypeUserInfoModel:
            {
                [_fmdb executeQuery:@"create table if not exists MotionData(id integer primary key, username text, gender text, age integer, height integer, weight integer, steplength integer);"];
            }
                break;
                
            default:
                break;
        }
    }
    
    return self;
}

#pragma mark - StepData
/**
 *  插入数据模型
 *
 *  @param model 运动数据模型
 *
 *  @return 是否成功
 */
- (BOOL)insertStepModel:(StepDataModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO MotionData(date, step, kCal, mileage, bpm) VALUES ('%@', '%@', '%@', '%@');", model.date, model.step, model.kCal, model.mileage];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入Motion数据成功");
    }else {
        NSLog(@"插入Motion数据失败");
    }
    return result;
}

/**
 *  查找数据
 *
 *  @param querySql 查找的关键字
 *
 *  @return 返回所有查找的结果
 */
- (NSArray *)queryStepWithDate:(NSString *)date {
    
    NSString *queryString;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData;"];
    }else {
        //这里一定不能将？用需要查询的日期代替掉
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData where date = ?;"];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:queryString ,date];
    
    while ([set next]) {
        
        NSString *step = [set stringForColumn:@"step"];
        NSString *kCal = [set stringForColumn:@"kCal"];
        NSString *mileage = [set stringForColumn:@"mileage"];
        
        StepDataModel *model = [[StepDataModel alloc] init];
        
        model.date = date;
        model.step = step;
        model.kCal = kCal;
        model.mileage = mileage;
        
        NSLog(@"%@的数据：步数=%@，卡路里=%@，里程=%@",date ,step ,kCal ,mileage);
        
        [arrM addObject:model];
    }
    
    NSLog(@"Motion查询成功");
    return arrM;
}

/**
 *  修改数据内容
 *
 *  @param modifySqlDate  需要修改的日期
 *  @param modifySqlModel 需要修改的模型内容
 *
 *  @return 是否修改成功
 */
- (BOOL)modifyStepWithDate:(NSString *)date model:(StepDataModel *)model
{
    if (date == nil) {
        NSLog(@"传入的日期为空，不能修改");
        
        return NO;
    }
    
    NSString *modifySql = [NSString stringWithFormat:@"update MotionData set step = ?, kCal = ?, mileage = ? where date = ?" ];
    
    BOOL modifyResult = [_fmdb executeUpdate:modifySql, model.step, model.kCal, model.mileage, date];
    
    if (modifyResult) {
        NSLog(@"Motion数据修改成功");
    }else {
        NSLog(@"Motion数据修改失败");
    }
   
    return modifyResult;
}

#pragma mark - HeartRateData

#pragma mark - TemperatureData

#pragma mark - SleepData

#pragma mark - BloodPressureData

#pragma mark - UserInfoData
- (BOOL)insertUserInfoModel:(UserInfoModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO MotionData(username, gender, age, height, weight, steplength) VALUES ('%@', '%@', '%ld', '%ld', '%ld', '%ld');", model.userName, model.gender, model.age, model.height, model.weight, model.stepLength];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入Motion数据成功");
    }else {
        NSLog(@"插入Motion数据失败");
    }
    return result;
}

@end
