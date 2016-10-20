//
//  TitleMenuViewController.h
//  ManridyApp
//
//  Created by JustFei on 16/10/20.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DropdownMenuView;

@protocol TitleMenuDelegate <NSObject>
#pragma mark 当前选中了哪一行
@required
- (void)selectAtIndexPath:(NSIndexPath *)indexPath title:(NSString*)title;
@end

@interface TitleMenuViewController : UITableViewController

@property (nonatomic, weak) id<TitleMenuDelegate> delegate;

@property (nonatomic, weak) DropdownMenuView * dropdownMenuView;

@end
