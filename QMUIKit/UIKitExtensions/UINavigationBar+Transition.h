//
//  QMUINavigationBar+Transition.h
//  qmui
//
//  Created by bang on 11/25/16.
//  Copyright © 2016 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Transition)

/// 用来模仿真的navBar，配合 UINavigationController+NavigationBarTransition 在转场过程中存在的一条假navBar
@property (nonatomic, strong) UINavigationBar *transitionNavigationBar;

@end
