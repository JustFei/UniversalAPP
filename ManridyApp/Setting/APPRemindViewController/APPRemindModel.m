//
//  APPRemindModel.m
//  New_iwear
//
//  Created by JustFei on 2017/6/20.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "APPRemindModel.h"

@implementation APPRemindModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.imageName forKey:@"imageName"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeBool:self.isSelect forKey:@"isSelect"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.imageName = [aDecoder decodeObjectForKey:@"imageName"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.isSelect = [aDecoder decodeBoolForKey:@"isSelect"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"imageName == %@; name == %@; select = %d", _imageName, _name, _isSelect];
}

@end
