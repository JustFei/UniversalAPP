//
//  MenuContentView.m
//  ManridyApp
//
//  Created by JustFei on 16/9/27.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "MenuContentView.h"
#import "FunctionCell.h"

@interface MenuContentView () <UICollectionViewDelegate ,UICollectionViewDataSource >
{
    NSArray *_dataArr;
    NSArray *_imageNameArr;
}
@property (nonatomic ,weak) UIButton *stepButton;

@property (nonatomic ,weak) UIButton *heartRateButton;

@property (nonatomic ,weak) UIButton *temperatureButton;

@property (nonatomic ,weak) UIButton *sleepButton;

@property (nonatomic ,weak) UIButton *bloodPressureButton;

@property (nonatomic ,weak) UICollectionView *collectionView;

@end

@implementation MenuContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataArr = @[@"计步",@"心率",@"体温",@"睡眠",@"血压"];
        _imageNameArr = @[@"list_walk_icon",@"list_heart_icon",@"list_temper_icon",@"list_sleep_icon",@"list_blood_icon"];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}

- (void)chooseView:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
            
            break;
        case 101:
            
            break;
        case 102:
            
            break;
        case 103:
            
            break;
        case 104:
            
            break;
            
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FunctionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"functioncell" forIndexPath:indexPath];
    
    cell.functionLabel.text = _dataArr[indexPath.row];
    [cell.functionButton setImage:[UIImage imageNamed:_imageNameArr[indexPath.row]] forState:UIControlStateNormal];
    
    return cell;
}

-(void)modifyButton:(UIButton*)btn{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0, -btn.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize=CGSizeMake(73,100);
        
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [view registerNib:[UINib nibWithNibName:@"FunctionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"functioncell"];
        view.backgroundColor = [UIColor colorWithRed:77 / 255.0 green:170 / 255.0 blue:225.0 / 255.0 alpha:1];
        
        view.delegate = self;
        view.dataSource = self;
        
        [self addSubview:view];
        _collectionView = view;
    }
    
    return _collectionView;
}


//- (UIButton *)stepButton
//{
//    if (!_stepButton) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:@"计步" forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        
//        [button addTarget:self action:@selector(chooseView:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = 100;
//        
//        [self addSubview:button];
//        _stepButton = button;
//    }
//    
//    return _stepButton;
//}
//
//- (UIButton *)heartRateButton
//{
//    if (!_heartRateButton) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:@"心率" forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        
//        [button addTarget:self action:@selector(chooseView:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = 101;
//        
//        [self addSubview:button];
//        _heartRateButton = button;
//    }
//    
//    return _heartRateButton;
//}
//
//- (UIButton *)temperatureButton
//{
//    if (!_temperatureButton) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:@"体温" forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        
//        [button addTarget:self action:@selector(chooseView:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = 102;
//        
//        [self addSubview:button];
//        _temperatureButton = button;
//    }
//    
//    return _temperatureButton;
//}
//
//- (UIButton *)sleepButton
//{
//    if (!_sleepButton) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:@"睡眠" forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        
//        [button addTarget:self action:@selector(chooseView:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = 103;
//        
//        [self addSubview:button];
//        _sleepButton = button;
//    }
//    
//    return _sleepButton;
//}
//
//- (UIButton *)bloodPressureButton
//{
//    if (!_bloodPressureButton) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:@"血压" forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        
//        [button addTarget:self action:@selector(chooseView:) forControlEvents:UIControlEventTouchUpInside];
//        button.tag = 104;
//        
//        [self addSubview:button];
//        _bloodPressureButton = button;
//    }
//    
//    return _bloodPressureButton;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
