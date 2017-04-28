//
//  SegmentedRunModel.m
//  ManridyApp
//
//  Created by Faith on 2017/4/28.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "SegmentedRunModel.h"

@implementation SegmentedRunModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"date = %@ AHCount = %ld CHCount = %ld stepNumber = %@ kCalNumber = %@ mileageNumber = %@ startTime = %@ timeInterval = %ld ", _date, _AHCount,  _CHCount, _stepNumber, _kCalNumber, _mileageNumber, _startTime, _timeInterval];
}

@end
