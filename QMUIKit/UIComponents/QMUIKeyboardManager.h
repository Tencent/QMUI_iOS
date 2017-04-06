//
//  QMUIKeyboardManager.h
//  qmui
//
//  Created by zhoonchen on 2017/3/23.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUIKeyboardUserInfo;
@class QMUIKeyboardManager;


/**
 *  `QMUIKeyboardManagerDelegate`里面的方法是对应系统键盘通知的回调方法，具体请看delegate名字，`QMUIKeyboardUserInfo`是对系统的userInfo做了一个封装，可以方便的获取userInfo的属性值。
 */
@protocol QMUIKeyboardManagerDelegate <NSObject>

@optional

/**
 *  键盘即将显示
 */
- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘frame即将发生变化。
 *  这个delegate除了对应系统的willChangeFrame通知外，在iPad下还增加了监听键盘frame变化的KVO来处理浮动键盘，所以调用次数会比系统默认多。需要让界面或者某个view跟随键盘运动，建议在这个通知delegate里面实现，因为willShow和willHide在手机上是准确的，但是在iPad的浮动键盘下是不准确的。另外，如果不需要跟随浮动键盘运动，那么在逻辑代码里面可以通过判断键盘的位置来过滤这种浮动的情况。
 */
- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘已经显示
 */
- (void)keyboardDidShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘已经隐藏
 */
- (void)keyboardDidHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘frame已经发生变化。
 */
- (void)keyboardDidChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

@end


@interface QMUIKeyboardUserInfo : NSObject

/**
 *  所在的KeyboardManager
 */
@property(nonatomic, weak, readonly) QMUIKeyboardManager *keyboardManager;

/**
 *  当前键盘的notification
 */
@property(nonatomic, strong, readonly) NSNotification *notification;

/**
 *  notification自带的userInfo
 */
@property(nonatomic, strong, readonly) NSDictionary *originUserInfo;

/**
 *  触发键盘事件的UIResponder
 */
@property(nonatomic, weak, readonly) UIResponder *targetResponder;

/**
 *  获取键盘实际宽度
 */
@property(nonatomic, assign, readonly) CGFloat width;

/**
 *  获取键盘的实际高度
 */
@property(nonatomic, assign, readonly) CGFloat height;

/**
 *  获取当前键盘在view上的可见高度，也就是键盘和view重叠的高度。如果view=nil，则直接返回键盘的实际高度。
 */
- (CGFloat)heightInView:(UIView *)view;

/**
 *  获取键盘beginFrame
 */
@property(nonatomic, assign, readonly) CGRect beginFrame;

/**
 *  获取键盘endFrame
 */
@property(nonatomic, assign, readonly) CGRect endFrame;

/**
 *  获取键盘出现动画的duration，对于第三方键盘，这个值有可能为0
 */
@property(nonatomic, assign, readonly) NSTimeInterval animationDuration;

/**
 *  获取键盘动画的Curve参数
 */
@property(nonatomic, assign, readonly) UIViewAnimationCurve animationCurve;

/**
 *  获取键盘动画的Options参数
 */
@property(nonatomic, assign, readonly) UIViewAnimationOptions animationOptions;

@end


/**
 *  `QMUIKeyboardManager`提供了方便管理键盘事件的方案，使用的场景是需要跟随键盘的显示或者隐藏来更改界面的UI原生，例如键盘顶部跟随一个输入框。
 *  由于键盘通知的全局性，经常会遇到一个地方的键盘监听回调接响应了其他界面或者控件触发的键盘通知，这样的情况往往不是我们想要的，即使可以通过一些其他的方法来避免，但还是不能完美的解决问题或者有时候解决起来非常麻烦。`QMUIKeyboardManager`通过`delegateEnabled`和`targetResponder`等增强功能属性来方便的控制响应的对象，从而可以实现某个键盘监听回调方法只响应某个UIResponder或者某几个UIResponder触发的键盘通知。
 */
@interface QMUIKeyboardManager : NSObject

/**
 *  获取delegate
 */
@property(nonatomic, weak, readonly) id <QMUIKeyboardManagerDelegate> delegate;

/**
 *  是否允许触发delegate的回调，用来某些场景直接关闭某些界面或者控件里面的键盘回调来临时禁止接受键盘通知事件。默认YES
 */
@property(nonatomic, assign) BOOL delegateEnabled;

/**
 *  添加触发键盘事件的UIResponder，一般是UITextView或者UITextField，没有targetResponder则默认接受任何UIResponder产生的键盘通知。添加成功将会返回YES，否则返回NO。
 */
- (BOOL)addTargetResponder:(UIResponder *)targetResponder;

/**
 *  获取当前所有的 target UIResponder
 */
- (NSMutableArray <UIResponder *> *)targetResponders;

/**
 *  唯一初始化方法
 */
- (instancetype)initWithDelegate:(id <QMUIKeyboardManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 *  把键盘的rect转为相对于view的rect。一般用来把键盘的rect转化为相对于当前self.view的rect，然后获取y值来布局跟随在键盘上的输入框等等（这里一般不要获取键盘的高度，因为对于iPad的键盘，浮动状态下键盘的高度往往不是我们想要的）。
 *  @param rect 键盘的rect，一般拿keyboardUserInfo.endFrame
 *  @param view 一个特定的view或者window，如果传入nil则相对有当前的 mainWindow
 */
+ (CGRect)convertKeyboardRect:(CGRect)rect toView:(UIView *)view;

/**
 *  获取键盘到顶部到相对于view底部的距离，这个值在某些情况下会等于endFrame.size.height或者visiableKeyboardHeight，不过在iPad浮动键盘的时候就包括了底部的空隙。所以建议使用这个方法。
 */
+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view keyboardRect:(CGRect)rect;

/**
 *  根据键盘的动画参数自己构建一个动画，调用者只需要设置view的位置即可
 */
+ (void)animateWithAnimated:(BOOL)animated keyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/**
 *  这个方法特殊处理 iPad Pro 外接键盘的情况。使用外接键盘在完全不显示键盘的时候，不会调用willShow的通知，所以导致一些通过willShow回调来显示targetResponder的场景（例如微信朋友圈的评论输入框）无法把targetResponder正常的显示出来。通过这个方法，你只需要关心你的show和hide的状态就好了，不需要关心是否 iPad Pro 的情况。
 *  @param showBlock 键盘显示回调的block，不能把showBlock理解为系统的show通知，而是你有输入框聚焦了并且期望键盘显示出来。
 *  @param hideBlock 键盘隐藏回调的block，不能把hideBlock理解为系统的hide通知，而是键盘即将消失在界面上并且你期望跟随键盘变化的UI回到默认状态。
 */
+ (void)handleKeyboardNotificationWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo showBlock:(void (^)(QMUIKeyboardUserInfo *keyboardUserInfo))showBlock hideBlock:(void (^)(QMUIKeyboardUserInfo *keyboardUserInfo))hideBlock;

/**
 *  键盘面板的私有view，可能为nil
 */
+ (UIView *)keyboardView;

/**
 *  键盘面板所在的私有window，可能为nil
 */
+ (UIWindow *)keyboardWindow;

/**
 *  是否有键盘在显示
 */
+ (BOOL)isKeyboardVisible;

/**
 *  当期那键盘相对于屏幕的frame
 */
+ (CGRect)currentKeyboardFrame;

/**
 *  当前键盘高度键盘的可见高度
 */
+ (CGFloat)visiableKeyboardHeight;

@end
