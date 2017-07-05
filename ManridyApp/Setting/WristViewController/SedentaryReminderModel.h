//
//  SedentaryReminderModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/9.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SedentaryReminderModel : NSObject < NSCoding >

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) BOOL whetherHaveSwitch;
@property (nonatomic, assign) BOOL switchIsOpen;

@end
