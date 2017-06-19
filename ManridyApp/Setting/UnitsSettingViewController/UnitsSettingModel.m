//
//  UnitsSettingModel.m
//  New_iwear
//
//  Created by Faith on 2017/5/8.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "UnitsSettingModel.h"

@implementation UnitsSettingModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeBool:self.isSelect forKey:@"isSelect"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.isSelect = [aDecoder decodeBoolForKey:@"isSelect"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name == %@, isSelect == %d", _name, _isSelect];
}

@end
