//
//  FunctionCell.h
//  ManridyApp
//
//  Created by JustFei on 16/9/27.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChooseViewActionBlock)(void);

@interface FunctionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *functionButton;
@property (weak, nonatomic) IBOutlet UILabel *functionLabel;

@property (nonatomic ,copy) ChooseViewActionBlock chooseViewActionBlock;

@end
