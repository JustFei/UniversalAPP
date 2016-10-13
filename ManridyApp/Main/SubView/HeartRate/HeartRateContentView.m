//
//  HeartRateContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "HeartRateContentView.h"

@interface HeartRateContentView ()

@end

@implementation HeartRateContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"HeartRateContentView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}



@end
