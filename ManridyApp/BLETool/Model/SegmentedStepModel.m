//
//  SegmentedStepModel.m
//  ManridyApp
//
//  Created by Faith on 2017/4/28.
//  Copyright © 2017年 Manridy.Bobo.com. All rights reserved.
//

#import "SegmentedStepModel.h"

@implementation SegmentedStepModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"date = %@ AHCount = %ld CHCount = %ld stepNumber = %@ kCalNumber = %@ mileageNumber = %@ startTime = %@ timeInterval = %ld ", _date, (long)_AHCount,  (long)_CHCount, _stepNumber, _kCalNumber, _mileageNumber, _startTime, (long)_timeInterval];
}

@end
