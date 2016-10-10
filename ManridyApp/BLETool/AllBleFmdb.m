//
//  AllBleFmdb.m
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/9/18.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "AllBleFmdb.h"
#import "manridyModel.h"

#import "FMDBTool.h"

//#import "SleepDailyDataModel.h"

@interface AllBleFmdb ()
#if 0
@property (nonatomic ,strong) MotionFmdbTool *motionFmTool;

@property (nonatomic ,strong) MotionDailyDataModel *MotionModel;

@property (strong, nonatomic) SleepFmdbTool *sleepFmTool;

@property (strong, nonatomic) SleepDailyDataModel *SleepModel;

@property (nonatomic ,copy) NSString *currentDateStr;
#endif
@end

@implementation AllBleFmdb
#if 0
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *currentDate = [NSDate date];
        self.currentDateStr = [dateformatter stringFromDate:currentDate];
    }
    return self;
}

//离线保存运动信息数据
- (void)saveMotionToDataBase:(manridyModel *)manridyModel
{
    self.MotionModel = [MotionDailyDataModel modelWith:self.currentDateStr step:manridyModel.sportModel.stepNumber kCal:manridyModel.sportModel.kCalNumber mileage:manridyModel.sportModel.mileageNumber bpm:nil];
    
    //查询数据库
    NSArray *dataArr = [self.motionFmTool queryDate:self.currentDateStr];
    if (dataArr.count == 0) {
        //插入数据
        [self.motionFmTool insertModel:self.MotionModel];
    }else {
        [self.motionFmTool modifyData:self.currentDateStr model:self.MotionModel];
    }
}

//离线保存睡眠信息
- (void)saveSleepToDataBase:(manridyModel *)manridyModel
{
    self.SleepModel = [SleepDailyDataModel modelWithDate:self.currentDateStr sumSleepTime:[NSString stringWithFormat:@"%d",(manridyModel.sleepModel.deepSleep.intValue + manridyModel.sleepModel.lowSleep.intValue)] deepSleepTime:manridyModel.sleepModel.deepSleep lowSleepTime:manridyModel.sleepModel.lowSleep];
    
    //查询数据库
    NSArray *dataArr = [self.sleepFmTool queryDate:self.currentDateStr];
    if (dataArr.count == 0) {
        //插入数据
        [self.sleepFmTool insertModel:self.SleepModel];
    }else {
        [self.sleepFmTool modifyData:self.currentDateStr model:self.SleepModel];
    }
}

//离线保存GPS数据
- (void)saveGPSToDataBase:(manridyModel *)manridyModel
{
    if (manridyModel.isReciveDataRight == ResponsEcorrectnessDataRgith) {
        if (manridyModel.receiveDataType == ReturnModelTypeGPSHistoryModel) {
            if (manridyModel.gpsDailyModel.sumPackage != 0) {
                [self.motionFmTool insertGPSModel:manridyModel.gpsDailyModel];
            }
            
        }else if (manridyModel.receiveDataType == ReturnModelTypeGPSCurrentModel){
            [self.motionFmTool insertGPSModel:manridyModel.gpsDailyModel];
        }
    }
}


#pragma mark - 懒加载
//运动数据库操作工具
- (MotionFmdbTool *)motionFmTool
{
    if (!_motionFmTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        MotionFmdbTool *tool = [[MotionFmdbTool alloc] initWithPath:userPhone withSQLType:SQLTypeMotion];
        
        _motionFmTool = tool;
    }
    
    return _motionFmTool;
}

//睡眠数据库操作工具
- (SleepFmdbTool *)sleepFmTool
{
    if (!_sleepFmTool) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
        _sleepFmTool = [[SleepFmdbTool alloc] initWithPath:userPhone];
    }
    
    return _sleepFmTool;
}

//运动数据模型
- (MotionDailyDataModel *)MotionModel
{
    if (!_MotionModel) {
        _MotionModel = [[MotionDailyDataModel alloc] init];
    }
    
    return _MotionModel;
}
#endif
@end
