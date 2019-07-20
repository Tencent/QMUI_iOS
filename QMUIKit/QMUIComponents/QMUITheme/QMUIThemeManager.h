//
//  QMUIThemeManager.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/20.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 当主题发生变化时发出这个通知，会先于 UIViewController/UIView 的 qmui_themeDidChangeByManager:identifier:theme:
extern NSNotificationName const QMUIThemeDidChangeNotification;

/**
 主题管理组件，可添加自定义的主题对象，并为每个对象指定一个专门的 identifier，当主题发生变化时，会遍历 UIViewController 和 UIView，调用每个 viewController 和每个可视 view 的 qmui_themeDidChangeByManager:identifier:theme: 方法，在里面由业务去自行根据当前主题设置不同的外观（color、image 等）。
 
 关于 theme 的概念：
 1. 一个主题包含两个元素：identifier 表示主题的标志/名字，不允许重复；theme 代表主题对象本身，可以是任意的 NSObject 类型，只要业务自行规定即可。对于任意主题而言，identifier 和 theme 都不能为空，也不能重复。
 2. 主题的增删需要通过 QMUIThemeManager 的 addThemeIdentifier:theme:、removeThemeIdentifier:/removeTheme: 来实现。
 3. 可通过 QMUIThemeManager 的 themeIdentifiers、themes 属性来获取当前已注册的所有主题。
 4. 可通过修改 QMUIThemeManager 的 currentThemeIdentifier、currentTheme 属性来切换当前 App 的主题，修改这两个属性的其中一个属性，内部都会同时自动修改另外一个属性，以保证两者匹配。
 
 关于 iOS 13 新增的 Dark Mode：
 1. 如果 App 只需要在 iOS 13 里才切换深色的主题，直接使用系统的方式去实现即可，无需用到 QMUIThemeManager 的任何功能，QMUIThemeManager 适用于 App 需要在全 iOS 版本里都支持相同的皮肤切换（也即 iOS 13 下系统的 Dark Mode 也只是被视为你业务的某个皮肤）。在 iOS 13 下，QMUIThemeManager 的作用只是帮你监听系统 Dark Mode 的切换，并将系统的样式转换成业务对应的主题名，后续的实际工作其实跟 iOS 12 下切换主题是一样的。
 2. 如果要令 QMUIThemeManager 自动响应 iOS 13 的 Dark Mode，请先为 identifierForTrait 赋值，在内部根据 trait.userInterfaceStyle 的值返回对应的主题 identifier，再把 respondsSystemStyleAutomatically 改为 YES 即可。
 
 关于 App 界面响应主题变化的方式：
 组件支持三种层面来响应主题变化：
 1. UIView 层面，如果是颜色（UIColor/CGColor）变化，请改为使用 [UIColor qmui_colorWithThemeProvider:] 方法来创建 UIColor，以及获取该 color 对应的 CGColor，建议每个颜色对应一个 @property，然后使用 [UIView qmui_registerThemeColorProperties:] 来注册这些需要在主题变化时自动刷新样式的 property，这样的好处是对设置颜色的时机没有要求，在 init 时就设置也没问题，不需要因为实现换肤而大量修改业务原有代码。如果是非颜色变化（例如 UIImage 或者代码逻辑），可重写 [UIView qmui_themeDidChangeByManager:identifier:theme:]，在里面根据当前主题做代码逻辑上的区分。
 2. UIViewController 层面，仅支持重写 [UIViewController qmui_themeDidChangeByManager:identifier:theme:] 方法来实现换肤。
 3. NSObject 层面，可通过监听 QMUIThemeDidChangeNotification 通知，在回调里处理主题切换事件（例如将当前选择的主题持久化记录下来，下次 App 启动直接应用）。
 
 标准场景下的使用流程：
 1. App 启动时，按需初始化 theme 对象并注册到 QMUIThemeManager 里。
 2. 根据当前用户的选择记录（例如 NSUserDefaults），通过 currentThemeIdentifier/currentTheme 指定当前的主题。
 3. 对需要响应主题变化的界面，检查其中的所有 UIColor、CGColor 的代码，将颜色换成使用 [UIColor qmui_colorWithThemeProvider:] 创建，如果该颜色对应一个 property，则使用 [UIView qmui_registerThemeColorProperties:] 注册这个 property，如果不对应 property，则请在 qmui_themeDidChangeByManager:identifier:theme: 里重新设置该颜色。
 4. 通过 QMUIThemeDidChangeNotification 监听主题的变化，将其持久化存储以便下次启动时应用。
 5. 若需要响应 iOS 13 的 Dark Mode，参考 respondsSystemStyleAutomatically、identifierForTrait 的注释。
 */
@interface QMUIThemeManager : NSObject

+ (instancetype)sharedInstance;

/// 自动响应 iOS 13 里的 Dark Mode 切换，默认为 NO。当为 YES 时，能自动监听系统 Dark Mode 的切换，并通过询问 identifierForTrait 来将当前的系统界面样式转换成业务定义的主题，剩下的事情就跟 iOS 12 及以下的系统相同了。
/// @warning 当设置这个属性为 YES 之前，请先为 identifierForTrait 赋值。
@property(nonatomic, assign) BOOL respondsSystemStyleAutomatically API_AVAILABLE(ios(13.0));

/// 当 respondsSystemStyleAutomatically 为 YES 并且系统样式发生变化时，会通过这个 block 将当前的 UITraitCollection.userInterfaceStyle 转换成对应的业务主题 identifier
@property(nonatomic, copy, nullable) __kindof NSObject<NSCopying> *(^identifierForTrait)(UITraitCollection *trait) API_AVAILABLE(ios(13.0));

/// 获取所有主题的 identifier
@property(nonatomic, copy, readonly, nullable) NSArray<__kindof NSObject<NSCopying> *> *themeIdentifiers;

/// 获取所有主题的对象
@property(nonatomic, copy, readonly, nullable) NSArray<__kindof NSObject *> *themes;

/// 获取当前主题的 identifier
@property(nonatomic, copy, nullable) __kindof NSObject<NSCopying> *currentThemeIdentifier;

/// 获取当前主题的对象
@property(nonatomic, strong, nullable) __kindof NSObject *currentTheme;

/// 当切换 currentThemeIdentifier 时如果遇到该 identifier 尚未被注册，则会尝试通过这个 block 来获取对应的主题对象并添加到 QMUIThemeManager 里
@property(nonatomic, copy, nullable) __kindof NSObject * _Nullable (^themeGenerator)(__kindof NSObject<NSCopying> *identifier);

/// 当切换 currentTheme 时如果遇到该 theme 尚未被注册，则会尝试通过这个 block 来获取对应的 identifier 并添加到 QMUIThemeManager 里
@property(nonatomic, copy, nullable) __kindof NSObject<NSCopying> * _Nullable (^themeIdentifierGenerator)(__kindof NSObject *theme);

/**
 添加主题，不允许重复添加
 @param identifier 主题的 identifier，一般用 NSString 即可，不允许重复
 @param theme 主题的对象，允许任意 class 类型
 */
- (void)addThemeIdentifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme;

/**
 移除指定 identifier 的主题
 @param identifier 要移除的 identifier
 */
- (void)removeThemeIdentifier:(__kindof NSObject<NSCopying> *)identifier;

/**
 移除指定的主题对象
 @param theme 要移除的主题对象
 */
- (void)removeTheme:(__kindof NSObject *)theme;

/**
 根据指定的 identifier 获取对应的主题对象
 @param identifier 主题的 identifier
 @return identifier 对应的主题对象
 */
- (nullable __kindof NSObject *)themeForIdentifier:(__kindof NSObject<NSCopying> *)identifier;

/**
 获取主题对应的 identifier
 @param theme 主题对象
 @return 主题的 identifier
 */
- (nullable __kindof NSObject<NSCopying> *)identifierForTheme:(__kindof NSObject *)theme;

@end

NS_ASSUME_NONNULL_END
