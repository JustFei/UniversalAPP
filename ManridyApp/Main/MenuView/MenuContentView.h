//
//  MenuContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/27.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GoToTargetViewBlock)(NSInteger);

@interface MenuContentView : UIView

@property (nonatomic ,copy) GoToTargetViewBlock goToTargetViewBlcok;

@end
