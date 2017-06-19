//
//  UserInfoSettingModel.h
//  New_iwear
//
//  Created by Faith on 2017/5/11.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    UserGenderMan = 0,
    UserGenderWoman
} UserGender;

@interface UserInfoSettingModel : NSObject

@property (nonatomic, copy) NSString *nameText;
@property (nonatomic, copy) NSString *placeHoldText;
@property (nonatomic, copy) NSString *unitText;
@property (nonatomic, assign) UserGender *userGender;
/** 判断性别 */
@property (nonatomic, assign) BOOL isGenderCell;

@end
