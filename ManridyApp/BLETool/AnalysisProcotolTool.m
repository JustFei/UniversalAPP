//
//  AnalysisProcotolTool.m
//  ManridyBleDemo
//
//  Created by 莫福见 on 16/9/14.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AnalysisProcotolTool.h"
#import "manridyModel.h"
#import "NSStringTool.h"
#import "AppDelegate.h"

@interface AnalysisProcotolTool ()<CLLocationManagerDelegate>


@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation AnalysisProcotolTool

#pragma mark - Singleton
static AnalysisProcotolTool *analysisProcotolTool = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.locationManager = [[CLLocationManager alloc] init];
//        self.locationManager.delegate = self;
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        
//        /** 由于IOS8中定位的授权机制改变 需要进行手动授权
//         * 获取授权认证，两个方法：
//         */
//        [self.locationManager requestWhenInUseAuthorization];
////        [self.locationManager requestAlwaysAuthorization];
//        
//        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//            DLog(@"requestAlwaysAuthorization");
//            [self.locationManager requestAlwaysAuthorization];
//        }
//        
//        //开始定位，不断调用其代理方法
//        [self.locationManager startUpdatingLocation];
//        DLog(@"start gps");
    }
    return self;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analysisProcotolTool = [[self alloc] init];
    });
    
    return analysisProcotolTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        analysisProcotolTool = [super allocWithZone:zone];
    });
    
    return analysisProcotolTool;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 1.获取用户位置的对象
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
//    DLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
    self.staticLat = coordinate.latitude;
    self.staticLon = coordinate.longitude;
    
    // 2.停止定位
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}

#pragma mark - 解析协议数据
#pragma mark 解析设置时间数据（00|80）
- (manridyModel *)analysisSetTimeData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSetTimeModel;
    
    if ([head isEqualToString:@"00"]) {
        NSData *timeData = [data subdataWithRange:NSMakeRange(1, 7)];
        NSString *timeStr = [NSStringTool convertToNSStringWithNSData:timeData];
        model.setTimeModel.time = timeStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        //        DLog(@"设定了时间为：%@\n%@",timeStr,model.setTimeModel.time);
    }else if ([head isEqualToString:@"80"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}


#pragma mark 解析闹钟数据 (01|81)
- (manridyModel *)analysisClockData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeClockModel;
    
    if ([head isEqualToString:@"01"]) {
        const unsigned char *hexBytes = [data bytes];
        
        for (int index = 1; index <= 5; index ++) {
            //第一个闹钟
            NSString *clock = [NSString stringWithFormat:@"%02x", hexBytes[index + 1]];
            if ([clock isEqualToString:@"01"] || [clock isEqualToString:@"02"]) {
                NSData *timeData = [data subdataWithRange:NSMakeRange(5 + index * 2, 2)];
                NSString *timeStr = [NSStringTool convertToNSStringWithNSData:timeData];
                NSMutableString *mutTimeStr = [NSMutableString stringWithString:timeStr];
                [mutTimeStr insertString:@":" atIndex:2];
                
//                NSDictionary *dic = @{clock:timeStr};
                ClockModel *clockModel = [[ClockModel alloc] init];
                clockModel.ID = index;
                clockModel.time = mutTimeStr;
                if ([clock isEqualToString:@"01"]) {
                    clockModel.isOpen = 1;
                }else if ([clock isEqualToString:@"02"]) {
                    clockModel.isOpen = 0;
                }
                [model.clockModelArr addObject:clockModel];
            }
        }
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"81"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

#pragma mark 解析获取运动信息的数据（03|83）
- (manridyModel *)analysisGetSportData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSportModel;
    
    const unsigned char *hexBytes = [data bytes];
    NSString *ENStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
    NSString *historyDataCount = [NSString stringWithFormat:@"%02x", hexBytes[2]];
    NSString *currentDataCount = [NSString stringWithFormat:@"%02x", hexBytes[3]];
    
    if ([head isEqualToString:@"03"]) {
        
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        if ([ENStr isEqualToString:@"01"]) {
            //这里不做单纯获取step的数据的操作
            model.sportModel.motionType = MotionTypeStep;
        }else if ([ENStr isEqualToString:@"07"]) {
            NSData *stepData = [data subdataWithRange:NSMakeRange(2, 3)];
            int stepValue = [NSStringTool parseIntFromData:stepData];
            //        DLog(@"今日步数 = %d",stepValue);
            NSString *stepStr = [NSString stringWithFormat:@"%d",stepValue];
            
            NSData *mileageData = [data subdataWithRange:NSMakeRange(5, 3)];
            int mileageValue = [NSStringTool parseIntFromData:mileageData];
            //        DLog(@"今日里程数 = %d",mileageValue);
            NSString *mileageStr = [NSString stringWithFormat:@"%d",mileageValue];
            
            NSData *kcalData = [data subdataWithRange:NSMakeRange(8, 3)];
            int kcalValue = [NSStringTool parseIntFromData:kcalData];
            //        DLog(@"卡路里 = %d",kcalValue);
            NSString *kCalStr = [NSString stringWithFormat:@"%d",kcalValue];
            
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyy/MM/dd"];
            NSDate *currentDate = [NSDate date];
            NSString *currentDateString = [dateformatter stringFromDate:currentDate];
            
            model.sportModel.date = currentDateString;
            model.sportModel.stepNumber = stepStr;
            model.sportModel.mileageNumber = mileageStr;
            model.sportModel.kCalNumber = kCalStr;
            model.sportModel.motionType = MotionTypeStepAndkCal;
        }else if ([ENStr isEqualToString:@"80"]) {
            model.sportModel.sumDataCount = historyDataCount.integerValue;
            model.sportModel.motionType = MotionTypeCountOfData;
        }else if ([ENStr isEqualToString:@"C0"] || [ENStr isEqualToString:@"c0"]) {
            model.sportModel.sumDataCount = historyDataCount.integerValue;
            model.sportModel.currentDataCount = currentDataCount.integerValue;
            
            NSData *time = [data subdataWithRange:NSMakeRange(4, 3)];
            NSString *timeStr = [NSString stringWithFormat:@"%@",time];
            
            NSString *yearStr = [timeStr substringWithRange:NSMakeRange(1, 2)];
            NSString *monthStr = [timeStr substringWithRange:NSMakeRange(3, 2)];
            NSString *dayStr = [timeStr substringWithRange:NSMakeRange(5, 2)];
            
            NSData *stepData = [data subdataWithRange:NSMakeRange(9, 3)];
            int stepValue = [NSStringTool parseIntFromData:stepData];
            NSString *stepStr = [NSString stringWithFormat:@"%d",stepValue];
            NSString *dateStr = [NSString stringWithFormat:@"20%@/%@/%@",yearStr ,monthStr ,dayStr];
            
            DLog(@"yy == %@ , mm == %@ , dd == %@ , date == %@",yearStr ,monthStr ,dayStr ,dateStr );
            DLog(@"step = %@",stepStr);
    
            model.sportModel.stepNumber = stepStr;
            model.sportModel.date = dateStr;
            model.sportModel.motionType = MotionTypeDataInPeripheral;
        }
    }else if ([head isEqualToString:@"83"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

#pragma mark 解析获取运动信息清零的数据（04|84）
- (manridyModel *)analysisSportZeroData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType =  ReturnModelTypeSportZeroModel;
    
    if ([head isEqualToString:@"04"]) {
        model.sportZero = SportZeroSuccess;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"84"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
        model.sportZero = SportZeroFail;
    }
    
    return model;
}
#if 0
#pragma mark 解析获取GPS历史的数据（05|85）
- (manridyModel *)analysisHistoryGPSData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeGPSHistoryModel;
    
    if ([head isEqualToString:@"05"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        //解析经纬度数据:11,12,13,14|15,16,17,18
        NSData *a = [data subdataWithRange:NSMakeRange(11, 4)];
        NSData *c = [data subdataWithRange:NSMakeRange(15, 4)];
        int index = 0;
        Byte *b = (Byte *)[a bytes];
        Byte *d = (Byte *)[c bytes];
        lat.c[0]=b[index + 3];
        lat.c[1]=b[index + 2];
        lat.c[2]=b[index + 1];
        lat.c[3]=b[index + 0];
        DLog(@"lat = %f %x\n",lat.v,lat.i);
        lon.c[0]=d[index + 3];
        lon.c[1]=d[index + 2];
        lon.c[2]=d[index + 1];
        lon.c[3]=d[index + 0];
        DLog(@"lon = %f %x\n",lon.v,lon.i);
        model.gpsDailyModel.lon = lon.v;
        model.gpsDailyModel.lat = lat.v;
        
        //解析当前包和总包数:1,2|3,4
        NSData *sum = [data subdataWithRange:NSMakeRange(1, 2)];
        NSData *current = [data subdataWithRange:NSMakeRange(3, 2)];
        NSInteger currentPackage = [NSStringTool parseIntFromData:current];
        NSInteger sumPackage = [NSStringTool parseIntFromData:sum];
        model.gpsDailyModel.currentPackage = currentPackage;
        model.gpsDailyModel.sumPackage = sumPackage;
        
        //解析gps时间数据:6,7,8,9,10 和日期数据
        NSString *MMTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(6, 1)]];
        NSString *DDTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(7, 1)]];
        NSString *hhTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(8, 1)]];
        NSString *mmTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(9, 1)]];
        NSString *ssTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(10, 1)]];
        model.gpsDailyModel.gpsTime = [NSString stringWithFormat:@"%@/%@ %@:%@:%@",MMTime ,DDTime ,hhTime ,mmTime ,ssTime];
        model.gpsDailyModel.dayTime = [NSString stringWithFormat:@"%@/%@",MMTime ,DDTime];
        
        //解析当前位置的状态:5
        NSInteger locationState = [NSStringTool parseIntFromData:[data subdataWithRange:NSMakeRange(5, 1)]];
        model.gpsDailyModel.locationState = locationState;
        
        //筛选正确数据，当前位置为纬度:22.663294 经度:113.994034
        if (sumPackage != 0) {
            if (self.staticLon && self.staticLat) {
                if ((self.staticLat - lat.v > 0.1 || self.staticLat - lat.v < -0.1) || (self.staticLon -lon.v > 0.1 || self.staticLon - lon.v < -0.1)) {
//                    DLog(@"错误的经纬度为 == lon:%f, lat:%f",lon.v ,lat.v);
                    return nil;
                }else {
                    
//                    DLog(@"当前GPS = lon:%f,lat:%f \n上一个GPS = lon:%f,lat:%f",lon.v ,lat.v ,self.staticLon ,self.staticLat);
                    self.staticLon = lon.v;
                    self.staticLat = lat.v;
                }
            }
        }else {
//            DLog(@"没有历史数据");
        }
        
        //还有个经纬度方向的数据没有解析，暂时没想到怎么解析
    }else {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}
#endif
#pragma mark 解析用户信息的数据（06|86）
- (manridyModel *)analysisUserInfoData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeUserInfoModel;
    
    if ([head isEqualToString:@"06"]) {
        NSData *weight = [data subdataWithRange:NSMakeRange(1, 1)];
        int weightValue = [NSStringTool parseIntFromData:weight];
        NSString *weightStr = [NSString stringWithFormat:@"%d",weightValue];
        
        NSData *height = [data subdataWithRange:NSMakeRange(2, 1)];
        int heightValue = [NSStringTool parseIntFromData:height];
        NSString *heightStr = [NSString stringWithFormat:@"%d",heightValue];
        
        model.userInfoModel.weight = weightStr.integerValue;
        model.userInfoModel.height = heightStr.integerValue;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
    }else if ([head isEqualToString:@"86"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

#pragma mark 解析运动目标的数据（07|87）
- (manridyModel *)analysisSportTargetData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSportTargetModel;
    
    if ([head isEqualToString:@"07"]) {
        NSData *target = [data subdataWithRange:NSMakeRange(2, 3)];
        int targetValue = [NSStringTool parseIntFromData:target];
        NSString *targetStr = [NSString stringWithFormat:@"%d",targetValue];
        
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        model.sportTargetModel.sportTargetNumber = targetStr;
        
    }else if ([head isEqualToString:@"87"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

#pragma mark 解析心率开关的数据（09|89）
- (manridyModel *)analysisHeartStateData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeHeartRateStateModel;
    
    if ([head isEqualToString:@"09"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"89"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

#pragma mark 解析查找设备的数据 (10|90)
- (BOOL)analysisSearchRequest:(NSData *)data withHeadStr:(NSString *)head
{
    const unsigned char *hexBytes = [data bytes];
    NSString *TyStr = [NSString stringWithFormat:@"%02x", hexBytes[2]];
        //接受到停止寻找的协议
    if ([TyStr isEqualToString:@"00"]) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark 解析心率的数据（0A|8A）
- (manridyModel *)analysisHeartData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeHeartRateModel;
    
    if ([head isEqualToString:@"0a"] || [head isEqualToString:@"0A"]) {
        
        const unsigned char *hexBytes = [data bytes];
        
        NSString *TyStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
        
        if ([TyStr isEqualToString:@"00"]) {
            model.heartRateModel.heartRateState = HeartRateDataLastData;
            
        }else if ([TyStr isEqualToString:@"01"]) {
            NSData *sum = [data subdataWithRange:NSMakeRange(2, 2)];
            int sumVale = [NSStringTool parseIntFromData:sum];
            NSString *sumStr = [NSString stringWithFormat:@"%d",sumVale];
            
            NSData *current = [data subdataWithRange:NSMakeRange(4, 2)];
            int currentVale = [NSStringTool parseIntFromData:current];
            NSString *currentStr = [NSString stringWithFormat:@"%d",currentVale];
            model.heartRateModel.sumDataCount = sumStr;
            model.heartRateModel.currentDataCount = currentStr;
            model.heartRateModel.heartRateState = HeartRateDataHistoryData;
        }
        
        NSData *time = [data subdataWithRange:NSMakeRange(6, 6)];
        NSString *timeStr = [NSString stringWithFormat:@"%@",time];
        
        NSData *Hr = [data subdataWithRange:NSMakeRange(12, 1)];
        int HrVale = [NSStringTool parseIntFromData:Hr];
        NSString *HrStr = [NSString stringWithFormat:@"%d",HrVale];
        
        NSData *date = [data subdataWithRange:NSMakeRange(6, 3)];
        NSString *dateStr = [NSString stringWithFormat:@"20%@",date];
        
        NSString *monthStr = [timeStr substringWithRange:NSMakeRange(3, 2)];
        NSString *dayStr = [timeStr substringWithRange:NSMakeRange(5, 2)];
        
        NSString *hourStr = [timeStr substringWithRange:NSMakeRange(7, 2)];
        NSString *minStr = [timeStr substringWithRange:NSMakeRange(10, 2)];
        
        NSString *dateString = [NSString stringWithFormat:@"%@/%@-%@:%@",monthStr ,dayStr ,hourStr ,minStr];
        
        model.heartRateModel.time = dateString;
        model.heartRateModel.heartRate = HrStr;
        model.heartRateModel.date = dateStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
    }else if ([head isEqualToString:@"8a"] || [head isEqualToString:@"8A"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

#pragma mark 解析睡眠的数据（0C|8C）
- (manridyModel *)analysisSleepData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeSleepModel;
    
    if ([head isEqualToString:@"0c"] || [head isEqualToString:@"0C"]) {
        
        const unsigned char *hexBytes = [data bytes];
        
        NSString *TyStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
        
        if ([TyStr isEqualToString:@"00"]) {
            model.sleepModel.sleepState = SleepDataLastData;
            
        }else if ([TyStr isEqualToString:@"01"]) {
            NSData *sum = [data subdataWithRange:NSMakeRange(2, 1)];
            int sumVale = [NSStringTool parseIntFromData:sum];
//            NSString *sumStr = [NSString stringWithFormat:@"%d",sumVale];
            
            NSData *current = [data subdataWithRange:NSMakeRange(3, 1)];
            int currentVale = [NSStringTool parseIntFromData:current];
//            NSString *currentStr = [NSString stringWithFormat:@"%d",currentVale];
            model.sleepModel.sumDataCount = sumVale;
            model.sleepModel.currentDataCount = currentVale;
            model.sleepModel.sleepState = SleepDataHistoryData;
            DLog(@"analysis : sumCount == %d,currentCount == %d",sumVale ,currentVale);
        }
//        0c010100 16113020 30161201 090602a4 00500000
        NSData *startTime = [data subdataWithRange:NSMakeRange(4, 5)];
        NSString *startTimeStr = [NSString stringWithFormat:@"%@",startTime];
        NSString *yy = [startTimeStr substringWithRange:NSMakeRange(1, 2)];
        NSString *MM = [startTimeStr substringWithRange:NSMakeRange(3, 2)];
        NSString *dd = [startTimeStr substringWithRange:NSMakeRange(5, 2)];
        NSString *hh = [startTimeStr substringWithRange:NSMakeRange(7, 2)];
        NSString *mm = [startTimeStr substringWithRange:NSMakeRange(10, 2)];
        startTimeStr = [NSString stringWithFormat:@"20%@/%@/%@ %02ld:%02ld",yy ,MM ,dd ,hh.integerValue ,mm.integerValue];
        
        NSData *endTime = [data subdataWithRange:NSMakeRange(9, 5)];
        NSString *endTimeStr = [NSString stringWithFormat:@"%@",endTime];
        NSString *endyy = [endTimeStr substringWithRange:NSMakeRange(1, 2)];
        NSString *endMM = [endTimeStr substringWithRange:NSMakeRange(3, 2)];
        NSString *enddd = [endTimeStr substringWithRange:NSMakeRange(5, 2)];
        NSString *endhh = [endTimeStr substringWithRange:NSMakeRange(7, 2)];
        NSString *endmm = [endTimeStr substringWithRange:NSMakeRange(10, 2)];
        endTimeStr = [NSString stringWithFormat:@"20%@/%@/%@ %02ld:%02ld",endyy ,endMM ,enddd ,endhh.integerValue ,endmm.integerValue];
        NSString *endDateStr = [NSString stringWithFormat:@"20%@/%@/%@",endyy ,endMM ,enddd];
        
        NSData *deepSleep = [data subdataWithRange:NSMakeRange(14, 2)];
        int deepSleepVale = [NSStringTool parseIntFromData:deepSleep];
        NSString *deepSleepStr = [NSString stringWithFormat:@"%d",deepSleepVale];
        
        NSData *lowSleep = [data subdataWithRange:NSMakeRange(16, 2)];
        int lowSleepVale = [NSStringTool parseIntFromData:lowSleep];
        NSString *lowSleepStr = [NSString stringWithFormat:@"%d",lowSleepVale];
        
        int sumSleepVale = deepSleepVale + lowSleepVale;
        NSString *sumSleepStr = [NSString stringWithFormat:@"%d",sumSleepVale];
        
        model.sleepModel.startTime = startTimeStr;
        model.sleepModel.endTime = endTimeStr;
        model.sleepModel.deepSleep = deepSleepStr;
        model.sleepModel.lowSleep = lowSleepStr;
        model.sleepModel.sumSleep = sumSleepStr;
        model.sleepModel.date = endDateStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
    }else if ([head isEqualToString:@"8c"] || [head isEqualToString:@"8C"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//经度
union LON{
    float v;
    unsigned char c[4];
    unsigned int i;
}lon;

//纬度
union LAT{
    float v;
    unsigned char c[4];
    unsigned int i;
}lat;
#if 0
#pragma mark 解析自动上报GPS的数据（0D|8D）
- (manridyModel *)analysisGPSData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeGPSCurrentModel;
    
    if ([head isEqualToString:@"0d"] || [head isEqualToString:@"0D"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
        
        //解析经纬度数据:11,12,13,14|15,16,17,18
        NSData *a = [data subdataWithRange:NSMakeRange(11, 4)];
        NSData *c = [data subdataWithRange:NSMakeRange(15, 4)];
        int index = 0;
        Byte *b = (Byte *)[a bytes];
        Byte *d = (Byte *)[c bytes];
        lat.c[0]=b[index + 3];
        lat.c[1]=b[index + 2];
        lat.c[2]=b[index + 1];
        lat.c[3]=b[index + 0];
        DLog(@"lat = %f %x\n",lat.v,lat.i);
        lon.c[0]=d[index + 3];
        lon.c[1]=d[index + 2];
        lon.c[2]=d[index + 1];
        lon.c[3]=d[index + 0];
        DLog(@"lon = %f %x\n",lon.v,lon.i);
        model.gpsDailyModel.lon = lon.v;
        model.gpsDailyModel.lat = lat.v;
        
        //解析当前包和总包数:1,2|3,4
//        NSData *current = [data subdataWithRange:NSMakeRange(1, 2)];
//        NSData *sum = [data subdataWithRange:NSMakeRange(3, 2)];
//        NSInteger currentPackage = [NSStringTool parseIntFromData:current];
//        NSInteger sumPackage = [NSStringTool parseIntFromData:sum];
//        model.gpsDailyModel.currentPackage = currentPackage;
//        model.gpsDailyModel.sumPackage = sumPackage;
        
        //解析gps时间数据:6,7,8,9,10 和日期数据
        NSString *MMTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(6, 1)]];
        NSString *DDTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(7, 1)]];
        NSString *hhTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(8, 1)]];
        NSString *mmTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(9, 1)]];
        NSString *ssTime = [NSStringTool convertToNSStringWithNSData:[data subdataWithRange:NSMakeRange(10, 1)]];
        model.gpsDailyModel.gpsTime = [NSString stringWithFormat:@"%@/%@ %@:%@:%@",MMTime ,DDTime ,hhTime ,mmTime ,ssTime];
        model.gpsDailyModel.dayTime = [NSString stringWithFormat:@"%@/%@",MMTime ,DDTime];
        
        //解析当前位置的状态:5
        NSInteger locationState = [NSStringTool parseIntFromData:[data subdataWithRange:NSMakeRange(5, 1)]];
        model.gpsDailyModel.locationState = locationState;
        
        //筛选正确数据，当前位置为纬度:22.663294 经度:113.994034
        if (self.staticLon && self.staticLat) {
            if ((self.staticLat - lat.v > 0.1 || self.staticLat - lat.v < -0.1) || (self.staticLon -lon.v > 0.1 || self.staticLon - lon.v < -0.1)) {
                DLog(@"错误的经纬度为 == lon:%f, lat:%f",lon.v ,lat.v);
                return nil;
            }else {
                
                DLog(@"当前GPS = lon:%f,lat:%f \n上一个GPS = lon:%f,lat:%f",lon.v ,lat.v ,self.staticLon ,self.staticLat);
                self.staticLon = lon.v;
                self.staticLat = lat.v;
            }
        }
        
        //还有个经纬度方向的数据没有解析，暂时没想到怎么解析
    }else {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}
#endif

#pragma mark 解析血压的数据（11|91）
//解析血压数据（11|91）
- (manridyModel *)analysisBloodData:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeBloodModel;
    
    if ([head isEqualToString:@"11"]) {
        const unsigned char *hexBytes = [data bytes];
        
        NSString *TyStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
        
        if ([TyStr isEqualToString:@"00"]) {
            model.bloodModel.bloodState = BloodDataLastData;
            
        }else if ([TyStr isEqualToString:@"01"]) {
            NSData *sum = [data subdataWithRange:NSMakeRange(2, 2)];
            int sumVale = [NSStringTool parseIntFromData:sum];
            NSString *sumStr = [NSString stringWithFormat:@"%d",sumVale];
            
            NSData *current = [data subdataWithRange:NSMakeRange(4, 2)];
            int currentVale = [NSStringTool parseIntFromData:current];
            NSString *currentStr = [NSString stringWithFormat:@"%d",currentVale];
            model.bloodModel.sumCount = sumStr;
            model.bloodModel.currentCount = currentStr;
            model.bloodModel.bloodState = BloodDataHistoryData;
        }
        NSData *year = [data subdataWithRange:NSMakeRange(6, 1)];
        NSString *yearStr = [NSStringTool convertToNSStringWithNSData:year];
        NSData *month = [data subdataWithRange:NSMakeRange(7, 1)];
        NSString *monthStr = [NSStringTool convertToNSStringWithNSData:month];
        NSData *day = [data subdataWithRange:NSMakeRange(8, 1)];
        NSString *dayStr = [NSStringTool convertToNSStringWithNSData:day];
        NSData *hour = [data subdataWithRange:NSMakeRange(9, 1)];
        NSString *hourStr = [NSStringTool convertToNSStringWithNSData:hour];
        NSData *min = [data subdataWithRange:NSMakeRange(10, 1)];
        NSString *minStr = [NSStringTool convertToNSStringWithNSData:min];
        NSData *sencond = [data subdataWithRange:NSMakeRange(11, 1)];
        NSString *sencondStr = [NSStringTool convertToNSStringWithNSData:sencond];
        
        NSData *highBlood = [data subdataWithRange:NSMakeRange(12, 1)];
        int highBloodinteger = [NSStringTool parseIntFromData:highBlood];
        NSString *hbStr = [NSString stringWithFormat:@"%d",highBloodinteger];
        
        NSData *lowBlood = [data subdataWithRange:NSMakeRange(13, 1)];
        int lowBloodinteger = [NSStringTool parseIntFromData:lowBlood];
        NSString *lbStr = [NSString stringWithFormat:@"%d",lowBloodinteger];
        
        NSData *bpm = [data subdataWithRange:NSMakeRange(14, 1)];
        int bpminteger = [NSStringTool parseIntFromData:bpm];
        NSString *bpmStr = [NSString stringWithFormat:@"%d",bpminteger];
        
        NSString *dayString = [NSString stringWithFormat:@"20%@/%@/%@", yearStr,monthStr ,dayStr];
        NSString *timeString = [NSString stringWithFormat:@"%@:%@:%@",hourStr ,minStr ,sencondStr];
        
        model.bloodModel.dayString = dayString;
        model.bloodModel.timeString = timeString;
        model.bloodModel.highBloodString = hbStr;
        model.bloodModel.lowBloodString = lbStr;
        model.bloodModel.bpmString = bpmStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"91"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

//解析血氧数据（12|92）
- (manridyModel *)analysisBloodO2Data:(NSData *)data WithHeadStr:(NSString *)head
{
    manridyModel *model = [[manridyModel alloc] init];
    model.receiveDataType = ReturnModelTypeBloodO2Model;
    
    if ([head isEqualToString:@"12"]) {
        const unsigned char *hexBytes = [data bytes];
        
        NSString *TyStr = [NSString stringWithFormat:@"%02x", hexBytes[1]];
        
        if ([TyStr isEqualToString:@"00"]) {
            model.bloodO2Model.bloodO2State = BloodO2DataLastData;
            
        }else if ([TyStr isEqualToString:@"01"]) {
            NSData *sum = [data subdataWithRange:NSMakeRange(2, 2)];
            int sumVale = [NSStringTool parseIntFromData:sum];
            NSString *sumStr = [NSString stringWithFormat:@"%d",sumVale];
            
            NSData *current = [data subdataWithRange:NSMakeRange(4, 2)];
            int currentVale = [NSStringTool parseIntFromData:current];
            NSString *currentStr = [NSString stringWithFormat:@"%d",currentVale];
            model.bloodO2Model.sumCount = sumStr;
            model.bloodO2Model.currentCount = currentStr;
            model.bloodO2Model.bloodO2State = BloodO2DataHistoryData;
        }
        NSData *year = [data subdataWithRange:NSMakeRange(6, 1)];
        NSString *yearStr = [NSStringTool convertToNSStringWithNSData:year];
        NSData *month = [data subdataWithRange:NSMakeRange(7, 1)];
        NSString *monthStr = [NSStringTool convertToNSStringWithNSData:month];
        NSData *day = [data subdataWithRange:NSMakeRange(8, 1)];
        NSString *dayStr = [NSStringTool convertToNSStringWithNSData:day];
        NSData *hour = [data subdataWithRange:NSMakeRange(9, 1)];
        NSString *hourStr = [NSStringTool convertToNSStringWithNSData:hour];
        NSData *min = [data subdataWithRange:NSMakeRange(10, 1)];
        NSString *minStr = [NSStringTool convertToNSStringWithNSData:min];
        NSData *sencond = [data subdataWithRange:NSMakeRange(11, 1)];
        NSString *sencondStr = [NSStringTool convertToNSStringWithNSData:sencond];
        
        NSData *inte = [data subdataWithRange:NSMakeRange(12, 1)];
        int inteinteger = [NSStringTool parseIntFromData:inte];
        NSString *integerStr = [NSString stringWithFormat:@"%d",inteinteger];
        
        NSData *flo = [data subdataWithRange:NSMakeRange(13, 1)];
        int flofloat = [NSStringTool parseIntFromData:flo];
        NSString *floatStr = [NSString stringWithFormat:@"%d",flofloat];
        
        NSString *dayString = [NSString stringWithFormat:@"20%@/%@/%@", yearStr,monthStr ,dayStr];
        NSString *timeString = [NSString stringWithFormat:@"%@:%@:%@",hourStr ,minStr ,sencondStr];
        
        model.bloodO2Model.dayString = dayString;
        model.bloodO2Model.timeString = timeString;
        model.bloodO2Model.integerString = integerStr;
        model.bloodO2Model.floatString = floatStr;
        model.isReciveDataRight = ResponsEcorrectnessDataRgith;
    }else if ([head isEqualToString:@"92"]) {
        model.isReciveDataRight = ResponsEcorrectnessDataFail;
    }
    
    return model;
}

@end
