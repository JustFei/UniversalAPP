//
//  SedentaryReminderModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/9.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "SedentaryReminderModel.h"

@implementation SedentaryReminderModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subTitle forKey:@"subTitle"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeBool:self.whetherHaveSwitch forKey:@"whetherHaveSwitch"];
    [aCoder encodeBool:self.switchIsOpen forKey:@"switchIsOpen"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.whetherHaveSwitch = [aDecoder decodeBoolForKey:@"whetherHaveSwitch"];
        self.switchIsOpen = [aDecoder decodeBoolForKey:@"switchIsOpen"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"_title == %@ _subTitle == %@, _time == %@, _whetherHaveSwitch == %d, _switchIsOpen == %d", _title, _subTitle, _time, _whetherHaveSwitch, _switchIsOpen];
}

@end
