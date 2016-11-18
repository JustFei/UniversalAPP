//
//  FMDBTool.m
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FMDBTool.h"
#import "ClockModel.h"
#import "SportModel.h"
#import "HeartRateModel.h"
#import "UserInfoModel.h"
#import "SleepModel.h"
#import "BloodModel.h"
#import "BloodO2Model.h"


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
        
        //UserInfoData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists UserInfoData(id integer primary key, username text, gender text, age integer, height integer, weight integer, steplength integer, steptarget integer, sleeptarget integer);"]];
        
        //ClockData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists ClockData(id integer primary key, time text, isopen bool);"]];

        //MotionData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists MotionData(id integer primary key, date text, step text, kCal text, mileage text, currentDataCount integer, sumDataCount integer);"]];
        
        //HeartRateData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists HeartRateData(id integer primary key,date text, time text, heartRate text);"]];
        
        //BloodData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists BloodData(id integer primary key, day text, time text, highBlood text, lowBlood text, currentCount text, sumCount text);"]];
        
        //BloodO2Data
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists BloodO2Data(id integer primary key, day text, time text, bloodO2integer text, bloodO2float text, currentCount text, sumCount text);"]];
        
        //SleepData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists SleepData(id integer primary key,date text, startTime text, endTime text, deepSleep text, lowSleep text, sumSleep text, currentDataCount integer, sumDataCount integer);"]];
        
    }
    
    return self;
}

#pragma mark - ClockData
- (BOOL)insertClockModel:(ClockModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO ClockData(time, isopen) VALUES ('%@', '%d');", model.time, model.isOpen];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入clockData成功");
    }else {
        NSLog(@"插入clockData失败");
    }
    return result;
}

- (NSMutableArray *)queryClockData
{
    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM ClockData;"];
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:queryString];
    
    while ([set next]) {
        
        ClockModel *model = [[ClockModel alloc] init];
        
        model.time = [set stringForColumn:@"time"];
        model.isOpen = [set boolForColumn:@"isopen"];
        model.ID = [set intForColumn:@"id"];
        
        NSLog(@"闹钟时间 == %@，是否打开 == %d, id == %ld",model.time , model.isOpen , (long)model.ID);
        
        [arrM addObject:model];
    }
    
    NSLog(@"查询成功");
    return arrM;
}

- (BOOL)deleteClockData:(NSInteger)deleteSql
{
    BOOL result;
    
    if (deleteSql == 4) {
        result =  [_fmdb executeUpdate:@"DELETE FROM ClockData"];
    }else {
        NSString *deleteSqlStr = [NSString stringWithFormat:@"DELETE FROM ClockData WHERE id = ?"];
        
        result = [_fmdb executeUpdate:deleteSqlStr,[NSNumber numberWithInteger:deleteSql]];
    }
    if (result) {
        NSLog(@"删除clockData成功");
    }else {
        NSLog(@"删除clockData失败");
    }
    
    return result;
}

- (BOOL)modifyClockModel:(ClockModel *)model withModifyID:(NSInteger)ID
{
    NSString *modifySqlTime = [NSString stringWithFormat:@"update ClockData set time = ? , isopen = ? where id = ?" ];
    BOOL result = result = [_fmdb executeUpdate:modifySqlTime, model.time, [NSNumber numberWithBool:model.isOpen], [NSNumber numberWithInteger:ID]];
    
    if (result) {
        NSLog(@"修改clockData成功");
    }else {
        NSLog(@"修改clockData失败");
    }
    
    return result;
}

#pragma mark - StepData
/**
 *  插入数据模型
 *
 *  @param model 运动数据模型
 *
 *  @return 是否成功
 */
- (BOOL)insertStepModel:(SportModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO MotionData(date, step, kCal, mileage, currentDataCount, sumDataCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@');", model.date, model.stepNumber, model.kCalNumber, model.mileageNumber, [NSNumber numberWithInteger: model.currentDataCount],[NSNumber numberWithInteger:model.sumDataCount]];
    
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
        NSInteger currentDataCount = [set stringForColumn:@"currentDataCount"].integerValue;
        NSInteger sumDataCount = [set stringForColumn:@"sumDataCount"].integerValue;
        
        SportModel *model = [[SportModel alloc] init];
        
        model.date = date;
        model.stepNumber = step;
        model.kCalNumber = kCal;
        model.mileageNumber = mileage;
        model.currentDataCount = currentDataCount;
        model.sumDataCount = sumDataCount;
        
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
- (BOOL)modifyStepWithDate:(NSString *)date model:(SportModel *)model
{
    if (date == nil) {
        NSLog(@"传入的日期为空，不能修改");
        
        return NO;
    }
    
    NSString *modifySql = [NSString stringWithFormat:@"update MotionData set step = ?, kCal = ?, mileage = ? where date = ?" ];
    
    BOOL modifyResult = [_fmdb executeUpdate:modifySql, model.stepNumber, model.kCalNumber, model.mileageNumber, date];
    
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
    NSLog(@"heartRate查询成功");
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
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO SleepData(date, startTime, endTime, deepSleep, lowSleep, sumSleep, currentDataCount, sumDataCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');", model.date, model.startTime, model.endTime, model.deepSleep, model.lowSleep, model.sumSleep, [NSNumber numberWithInteger:model.currentDataCount],[NSNumber numberWithInteger:model.sumDataCount]];
    
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
        NSString *sumSleep = [set stringForColumn:@"sumSleep"];
        NSInteger currentDataCount = [set intForColumn:@"currentDataCount"];
        NSInteger sumDataCount = [set intForColumn:@"sumDataCount"];
        
        SleepModel *model = [[SleepModel alloc] init];
        
        model.startTime = startTime;
        model.endTime = endTime;
        model.deepSleep = deepSleep;
        model.lowSleep = lowSleep;
        model.sumSleep = sumSleep;
        model.currentDataCount = currentDataCount;
        model.sumDataCount = sumDataCount;
        model.date = date;
        
        NSLog(@"currentDataCount == %ld, sumDataCount == %ld, lowSleep == %@, deepSleep == %@, sumSleep == %@",currentDataCount ,sumDataCount ,lowSleep , deepSleep ,sumSleep);
        
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
- (BOOL)insertBloodModel:(BloodModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO BloodData(day, time, highBlood, lowBlood, currentCount, sumCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@');", model.dayString, model.timeString, model.highBloodString, model.lowBloodString, model.currentCount, model.sumCount];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入BloodData数据成功");
    }else {
        NSLog(@"插入BloodData数据失败");
    }
    return result;
}

- (NSArray *)queryBloodWithDate:(NSString *)date
{
    NSString *queryString;
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData where day = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *day = [set stringForColumn:@"day"];
        NSString *time = [set stringForColumn:@"time"];
        NSString *highBlood = [set stringForColumn:@"highBlood"];
        NSString *lowBlood = [set stringForColumn:@"lowBlood"];
        NSString *currentCount = [set stringForColumn:@"currentCount"];
        NSString *sumCount = [set stringForColumn:@"sumCount"];
        
        BloodModel *model = [[BloodModel alloc] init];
        
        model.dayString = day;
        model.timeString = time;
        model.highBloodString = highBlood;
        model.lowBloodString = lowBlood;
        model.currentCount = currentCount;
        model.sumCount = sumCount;
        
        [arrM addObject:model];
    }
    NSLog(@"Blood查询成功");
    return arrM;
}

#pragma mark - BloodO2Data
- (BOOL)insertBloodO2Model:(BloodO2Model *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO BloodO2Data(day, time, bloodO2integer, bloodO2float, currentCount, sumCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@');", model.dayString, model.timeString, model.integerString, model.floatString, model.currentCount, model.sumCount];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入BloodO2Data数据成功");
    }else {
        NSLog(@"插入BloodO2Data数据失败");
    }
    return result;
}

- (NSArray *)queryBloodO2WithDate:(NSString *)date
{
    NSString *queryString;
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM BloodO2Data;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        queryString = [NSString stringWithFormat:@"SELECT * FROM BloodO2Data where day = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *day = [set stringForColumn:@"day"];
        NSString *time = [set stringForColumn:@"time"];
        NSString *bloodO2integer = [set stringForColumn:@"bloodO2integer"];
        NSString *bloodO2float = [set stringForColumn:@"bloodO2float"];
        NSString *currentCount = [set stringForColumn:@"currentCount"];
        NSString *sumCount = [set stringForColumn:@"sumCount"];
        
        BloodO2Model *model = [[BloodO2Model alloc] init];
        
        model.dayString = day;
        model.timeString = time;
        model.integerString = bloodO2integer;
        model.floatString = bloodO2float;
        model.currentCount = currentCount;
        model.sumCount = sumCount;
        
        [arrM addObject:model];
    }
    NSLog(@"Blood查询成功");
    return arrM;
}

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
        NSInteger sleepTarget = [set intForColumn:@"sleeptarget"];
        
        UserInfoModel *model = [UserInfoModel userInfoModelWithUserName:userName andGender:gender andAge:age andHeight:height andWeight:weight andStepLength:steplength andStepTarget:stepTarget andSleepTarget:sleepTarget];
        
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

- (BOOL)modifySleepTargetWithID:(NSInteger)ID model:(NSInteger)sleepTarget
{
    NSString *modifySql = [NSString stringWithFormat:@"update UserInfoData set sleeptarget = ? where id = ?"];
    
    BOOL modifyResult = [_fmdb executeUpdate:modifySql, @(sleepTarget), @(ID)];
    
    if (modifyResult) {
        NSLog(@"修改睡眠目标成功");
    }else {
        NSLog(@"修改睡眠目标失败");
    }
    
    return modifyResult;
}

- (BOOL)deleteUserInfoData:(NSString *)deleteSql
{
    BOOL result = [_fmdb executeUpdate:@"drop table UserInfoData"];
    
    if (result) {
        NSLog(@"UserInfo表删除成功");
    }else {
        NSLog(@"UserInfo表删除失败");
    }
    
    return result;
}

#pragma mark - CloseData
- (void)CloseDataBase
{
    [_fmdb close];
}

@end
