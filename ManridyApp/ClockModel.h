//
//  Clocker.h
//  BaoMiWanBiao
//
//  Created by 莫福见 on 16/8/23.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ClockDataSetClock = 0,
    ClockDataGetClock,
} ClockData;

@interface ClockModel : NSObject

@property (assign, nonatomic) NSInteger ID;

@property (copy, nonatomic) NSString *time;

@property (assign, nonatomic) BOOL isOpen;

@end
