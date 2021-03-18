/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUISegmentedControl.m
//  qmui
//
//  Created by QMUI Team on 14/11/3.
//

#import "QMUISegmentedControl.h"

@implementation QMUISegmentedControl {
    NSMutableArray *_items;
    UIImage *_preSelectedImage;
    NSUInteger _preSegmentIndex;
}

- (instancetype)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        _items = [[NSMutableArray alloc] initWithArray:items];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updateSegmentedUIWithTintColor:(UIColor *)tintColor selectedTextColor:(UIColor *)selectedTextColor fontSize:(UIFont *)fontSize {
    [self setTintColor:tintColor];
    [self setTitleTextAttributesWithTextColor:tintColor selectedTextColor:selectedTextColor fontSize:fontSize];
}

- (void)setBackgroundWithNormalImage:(UIImage *)normalImage
                       selectedImage:(UIImage *)selectedImage
                       devideImage00:(UIImage *)devideImage00
                       devideImage01:(UIImage *)devideImage01
                       devideImage10:(UIImage *)devideImage10
                           textColor:(UIColor *)textColor
                   selectedTextColor:(UIColor *)selectedTextColor
                            fontSize:(UIFont *)fontSize;
{
    [self setTitleTextAttributesWithTextColor:textColor selectedTextColor:selectedTextColor fontSize:fontSize];
    [self setBackgroundWithNormalImage:normalImage selectedImage:selectedImage devideImage00:devideImage00 devideImage01:devideImage01 devideImage10:devideImage10];
}

- (void)setTitleTextAttributesWithTextColor:(UIColor *)textColor selectedTextColor:(UIColor *)selectedTextColor fontSize:(UIFont *)fontSize {
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  textColor, NSForegroundColorAttributeName,
                                  fontSize, NSFontAttributeName,
                                  nil]
                        forState:UIControlStateNormal];
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  selectedTextColor, NSForegroundColorAttributeName,
                                  fontSize, NSFontAttributeName,
                                  nil]
                        forState:UIControlStateSelected];
}

- (void)setBackgroundWithNormalImage:(UIImage *)normalImage
                         selectedImage:(UIImage *)selectedImage
                         devideImage00:(UIImage *)devideImage00
                         devideImage01:(UIImage *)devideImage01
                         devideImage10:(UIImage *)devideImage10
{
    CGFloat devideImageWidth = devideImage00.size.width;
    [self setBackgroundImage:[normalImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 20, 12, 20)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[selectedImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 20, 12, 20)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setDividerImage:[devideImage00 resizableImageWithCapInsets:UIEdgeInsetsMake(12, devideImageWidth/2, 12, devideImageWidth/2)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setDividerImage:[devideImage10 resizableImageWithCapInsets:UIEdgeInsetsMake(12, devideImageWidth/2, 12, devideImageWidth/2)] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setDividerImage:[devideImage01 resizableImageWithCapInsets:UIEdgeInsetsMake(12, devideImageWidth/2, 12, devideImageWidth/2)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [self setContentPositionAdjustment:UIOffsetMake(- (12 - devideImageWidth) / 2, 0)
                        forSegmentType:UISegmentedControlSegmentLeft
                            barMetrics:UIBarMetricsDefault];
    [self setContentPositionAdjustment:UIOffsetMake((12 - devideImageWidth) / 2, 0)
                        forSegmentType:UISegmentedControlSegmentRight
                            barMetrics:UIBarMetricsDefault];
}

#pragma mark - Copy Items

- (void)insertSegmentWithTitle:(nullable NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated {
    [super insertSegmentWithTitle:title atIndex:segment animated:animated];
    [_items insertObject:title atIndex:segment];
}

- (void)insertSegmentWithImage:(nullable UIImage *)image  atIndex:(NSUInteger)segment animated:(BOOL)animated {
    [super insertSegmentWithImage:image atIndex:segment animated:animated];
    [_items insertObject:image atIndex:segment];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated {
    [super removeSegmentAtIndex:segment animated:animated];
    [_items removeObjectAtIndex:segment];
}

- (void)removeAllSegments {
    [super removeAllSegments];
    [_items removeAllObjects];
}

- (NSArray *)segmentItems {
    return [NSArray arrayWithArray:_items];
}

@end
