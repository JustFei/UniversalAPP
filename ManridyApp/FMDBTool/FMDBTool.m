//
//  FMDBTool.m
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FMDBTool.h"
#import "StepDataModel.h"
#import "HeartRateModel.h"
#import "UserInfoModel.h"
#import "SleepModel.h"


@implementation FMDBTool

static FMDatabase *_fmdb;

#pragma mark - init
/**
 *  创建数据库文件
 *
 *  @param path 数据库名字，以用户名+MotionData命名
 *
 */
- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self) {
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.sqlite",path]];
        _fmdb = [FMDatabase databaseWithPath:filepath];
        
        NSLog(@"数据库路径 == %@", filepath);
        
        if ([_fmdb open]) {
            NSLog(@"数据库打开成功");
        }
        
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists UserInfoData(id integer primary key, username text, gender text, age integer, height integer, weight integer, steplength integer, steptarget integer);"]];

        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists MotionData(id integer primary key, date text, step text, kCal text, mileage text);"]];
        

        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists HeartRateData(id integer primary key,date text, time text, heartRate text);"]];
        
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists SleepData(id integer primary key,date text, startTime text, endTime text, deepSleep text, lowSleep text, currentDataCount text, sumDataCount text);"]];
        
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
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO MotionData(date, step, kCal, mileage) VALUES ('%@', '%@', '%@', '%@');", model.date, model.step, model.kCal, model.mileage];
    
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
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        //这里一定不能将？用需要查询的日期代替掉
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData where date = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    
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
- (BOOL)insertHeartRateModel:(HeartRateModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO HeartRateData(date, time, heartRate) VALUES ('%@', '%@', '%@');", model.date, model.time, model.heartRate];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入HeartRate数据成功");
    }else {
        NSLog(@"插入HeartRate数据失败");
    }
    return result;
}

- (NSArray *)queryHeartRateWithDate:(NSString *)date
{
    NSString *queryString;
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM HeartRateData;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        queryString = [NSString stringWithFormat:@"SELECT * FROM HeartRateData where date = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *time = [set stringForColumn:@"time"];
        NSString *heartRate = [set stringForColumn:@"heartRate"];
        NSString *date = [set stringForColumn:@"date"];
        
        HeartRateModel *model = [[HeartRateModel alloc] init];
        
        model.time = time;
        model.heartRate = heartRate;
        model.date = date;
        
        [arrM addObject:model];
    }
    return arrM;
}

- (BOOL)deleteHeartRateData:(NSString *)deleteSql
{
    BOOL result = [_fmdb executeUpdate:@"delete from HeartRateData;"];
    
    if (result) {
        NSLog(@"删除成功");
    }else {
        NSLog(@"删除失败");
    }
    
    return result;
}

#pragma mark - TemperatureData

#pragma mark - SleepData
- (BOOL)insertSleepModel:(SleepModel *)model
{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO SleepData(date, startTime, endTime, deepSleep, lowSleep, currentDataCount, sumDataCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@');", model.date, model.startTime, model.endTime, model.deepSleep, model.lowSleep, model.currentDataCount, model.sumDataCount];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入SleepData数据成功");
    }else {
        NSLog(@"插入SleepData数据失败");
    }
    return result;
}

- (NSArray *)querySleepWithDate:(NSString *)date
{
    NSString *queryString;
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM SleepData;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        queryString = [NSString stringWithFormat:@"SELECT * FROM SleepData where date = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *startTime = [set stringForColumn:@"startTime"];
        NSString *endTime = [set stringForColumn:@"endTime"];
        NSString *deepSleep = [set stringForColumn:@"deepSleep"];
        NSString *lowSleep = [set stringForColumn:@"lowSleep"];
        NSString *currentDataCount = [set stringForColumn:@"currentDataCount"];
        NSString *sumDataCount = [set stringForColumn:@"sumDataCount"];
        
        SleepModel *model = [[SleepModel alloc] init];
        
        model.startTime = startTime;
        model.endTime = endTime;
        model.deepSleep = deepSleep;
        model.lowSleep = lowSleep;
        model.currentDataCount = currentDataCount;
        model.sumDataCount = sumDataCount;
        model.date = date;
        
        NSLog(@"current == %@, sum == %@, lowSleep == %@, deepSleep == %@",currentDataCount ,sumDataCount ,lowSleep , deepSleep);
        
        [arrM addObject:model];
    }
    
    NSLog(@"sleep查询成功");
    return arrM;
}

- (BOOL)modifySleepWithID:(NSInteger)ID model:(SleepModel *)model
{
    return YES;
}

- (BOOL)deleteSleepData:(NSString *)deleteSql
{
    BOOL result = [_fmdb executeUpdate:@"delete from SleepData"];
    
    if (result) {
        NSLog(@"Sleep表删除成功");
    }else {
        NSLog(@"Sleep表删除失败");
    }
    
    return result;
}

#pragma mark - BloodPressureData

#pragma mark - UserInfoData
- (BOOL)insertUserInfoModel:(UserInfoModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO UserInfoData(username, gender, age, height, weight, steplength) VALUES ('%@', '%@', '%ld', '%ld', '%ld', '%ld');", model.userName, model.gender, (long)model.age, model.height, model.weight, model.stepLength];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入UserInfoData数据成功");
    }else {
        NSLog(@"插入UserInfoData数据失败");
    }
    return result;
}

- (NSArray *)queryAllUserInfo {
    
    NSString *queryString;
    
    queryString = [NSString stringWithFormat:@"SELECT * FROM UserInfoData;"];
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:queryString];
    
    while ([set next]) {
        
        NSString *userName = [set stringForColumn:@"username"];
        NSString *gender = [set stringForColumn:@"gender"];
        NSInteger age = [set intForColumn:@"age"];
        NSInteger height = [set intForColumn:@"height"];
        NSInteger weight = [set intForColumn:@"weight"];
        NSInteger steplength = [set intForColumn:@"steplength"];
        NSInteger stepTarget = [set intForColumn:@"steptarget"];
        
        UserInfoModel *model = [UserInfoModel userInfoModelWithUserName:userName andGender:gender andAge:age andHeight:height andWeight:weight andStepLength:steplength andStepTarget:stepTarget];
        
        NSLog(@"%@,%@,%ld,%ld,%ld,%ld",model.userName ,model.gender ,model.age ,model.height ,model.weight ,model.stepLength);
        
        [arrM addObject:model];
    }
    
    NSLog(@"UserInfoData查询成功");
    return arrM;
}

- (BOOL)modifyUserInfoWithID:(NSInteger)ID model:(UserInfoModel *)model
{
    
    NSString *modifySql = [NSString stringWithFormat:@"update UserInfoData set username = ?, gender = ?, age = ?, height = ?, weight = ?, steplength = ? where id = ?" ];
    
    BOOL modifyResult = [_fmdb executeUpdate:modifySql, model.userName, model.gender, @(model.age), @(model.height), @(model.weight), @(model.stepLength), @(ID)];
    
    if (modifyResult) {
        NSLog(@"UserInfoData数据修改成功");
    }else {
        NSLog(@"UserInfoData数据修改失败");
    }
    
    return modifyResult;
}

- (BOOL)modifyStepTargetWithID:(NSInteger)ID model:(NSInteger)stepTarget
{
    NSString *modifySql = [NSString stringWithFormat:@"update UserInfoData set steptarget = ? where id = ?"];
    
    BOOL modifyResult = [_fmdb executeUpdate:modifySql, @(stepTarget), @(ID)];
    
    if (modifyResult) {
        NSLog(@"添加运动目标成功");
    }else {
        NSLog(@"添加运动目标失败");
    }
    
    return modifyResult;
}

#pragma mark - CloseData
- (void)CloseDataBase
{
    [_fmdb close];
}

@end
