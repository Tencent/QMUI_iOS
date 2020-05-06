/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIConsole.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//

#import "QMUIConsole.h"
#import "QMUICore.h"
#import "NSParagraphStyle+QMUI.h"
#import "UIView+QMUI.h"
#import "UIWindow+QMUI.h"
#import "UIColor+QMUI.h"
#import "QMUITextView.h"

@interface QMUIConsole ()

@property(nonatomic, strong) UIWindow *consoleWindow;
@property(nonatomic, strong) QMUIConsoleViewController *consoleViewController;
@end

@implementation QMUIConsole

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static QMUIConsole *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.canShow = IS_DEBUG;
        instance.showConsoleAutomatically = YES;
        instance.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        instance.textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12],
                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                    NSParagraphStyleAttributeName: ({
                                        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:16];
                                        paragraphStyle.paragraphSpacing = 8;
                                        paragraphStyle;
                                    }),
                                    };
        instance.timeAttributes = ({
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = instance.textAttributes.mutableCopy;
            attributes[NSForegroundColorAttributeName] = [attributes[NSForegroundColorAttributeName] qmui_colorWithAlpha:.6 backgroundColor:instance.backgroundColor];
            attributes.copy;
        });
        instance.searchResultHighlightedBackgroundColor = [UIColorBlue colorWithAlphaComponent:.8];
    });
    return instance;
}

+ (instancetype)appearance {
    return [self sharedInstance];
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

+ (void)logWithLevel:(NSString *)level name:(NSString *)name logString:(id)logString {
    QMUIConsole *console = [QMUIConsole sharedInstance];
    [console initConsoleWindowIfNeeded];
    [console.consoleViewController logWithLevel:level name:name logString:logString];
    if (console.showConsoleAutomatically) {
        [QMUIConsole show];
    }
}

+ (void)log:(id)logString {
    [self logWithLevel:nil name:nil logString:logString];
}

+ (void)clear {
    [[QMUIConsole sharedInstance].consoleViewController clear];
}

+ (void)show {
    QMUIConsole *console = [QMUIConsole sharedInstance];
    if (console.canShow) {
        
        if (!console.consoleWindow.hidden) return;
        
        // 在某些情况下 show 的时候刚好界面正在做动画，就可能会看到 consoleWindow 从左上角展开的过程（window 默认背景色是黑色的），所以这里做了一些小处理
        // https://github.com/Tencent/QMUI_iOS/issues/743
        [UIView performWithoutAnimation:^{
            [console initConsoleWindowIfNeeded];
            console.consoleWindow.alpha = 0;
            console.consoleWindow.hidden = NO;
        }];
        [UIView animateWithDuration:.25 delay:.2 options:QMUIViewAnimationOptionsCurveOut animations:^{
            console.consoleWindow.alpha = 1;
        } completion:nil];
    }
}

+ (void)hide {
    [QMUIConsole sharedInstance].consoleWindow.hidden = YES;
}

- (void)initConsoleWindowIfNeeded {
    if (!self.consoleWindow) {
        self.consoleWindow = [[UIWindow alloc] init];
        self.consoleWindow.backgroundColor = nil;
        if (QMUICMIActivated) {
            self.consoleWindow.windowLevel = UIWindowLevelQMUIConsole;
        } else {
            self.consoleWindow.windowLevel = 1;
        }
        self.consoleWindow.qmui_capturesStatusBarAppearance = NO;
        __weak __typeof(self)weakSelf = self;
        self.consoleWindow.qmui_hitTestBlock = ^__kindof UIView * _Nonnull(CGPoint point, UIEvent * _Nonnull event, __kindof UIView * _Nonnull originalView) {
            return originalView == weakSelf.consoleWindow ? nil : originalView;
        };
        
        self.consoleViewController = [[QMUIConsoleViewController alloc] init];
        self.consoleWindow.rootViewController = self.consoleViewController;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.consoleViewController.backgroundColor = backgroundColor;
}

@end
