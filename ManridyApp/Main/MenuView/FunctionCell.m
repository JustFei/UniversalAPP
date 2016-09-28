//
//  FunctionCell.m
//  ManridyApp
//
//  Created by JustFei on 16/9/27.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FunctionCell.h"

@implementation FunctionCell

- (IBAction)chooseViewAction:(UIButton *)sender
{
    if (self.chooseViewActionBlock) {
        self.chooseViewActionBlock();
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
