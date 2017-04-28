//
//  SegmentedRunModel.h
//  ManridyApp
//
//  Created by Faith on 2017/4/28.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SegmentedRunModel : NSObject

/** 日期 */
@property (nonatomic, copy) NSString *date;
/** 历史数据总条数 */
@property (nonatomic, assign) NSInteger AHCount;
/** 历史数据当前编号 */
@property (nonatomic, assign) NSInteger CHCount;
/** 计步数据 */
@property (nonatomic, copy) NSString *stepNumber;
/** 卡路里数据 */
@property (nonatomic, copy) NSString *kCalNumber;
/** 里程 */
@property (nonatomic, copy) NSString *mileageNumber;
/** 开始的时间,格式为:yyyy-MM-dd hh:mm:ss */
@property (nonatomic, copy) NSString *startTime;
/** 时间间隔 */
@property (nonatomic, assign) NSInteger timeInterval;

@end
