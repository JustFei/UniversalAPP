//
//  StepDataModel.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/22.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepDataModel : NSObject

/**
 *  今日日期
 */
@property (nonatomic , copy) NSString *date;

/**
 *  今日步数
 */
@property (nonatomic , copy) NSString *step;

/**
 *  今日卡路里
 */
@property (nonatomic , copy) NSString *kCal;

/**
 *  今日里程
 */
@property (nonatomic , copy) NSString *mileage;


+ (instancetype)modelWith: (NSString *)date step:(NSString *)step kCal:(NSString *)kCal mileage:(NSString *)mileage bpm:(NSString *)bpm;

@end
