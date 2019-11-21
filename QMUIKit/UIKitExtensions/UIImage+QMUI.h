/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIImage+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define CGContextInspectSize(size) [QMUIHelper inspectContextSize:size]

#ifdef DEBUG
    #define CGContextInspectContext(context) [QMUIHelper inspectContextIfInvalidatedInDebugMode:context]
#else
    #define CGContextInspectContext(context) if(![QMUIHelper inspectContextIfInvalidatedInReleaseMode:context]){return nil;}
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QMUIImageShape) {
    QMUIImageShapeOval,                 // 椭圆
    QMUIImageShapeTriangle,             // 三角形
    QMUIImageShapeDisclosureIndicator,  // 列表 cell 右边的箭头
    QMUIImageShapeCheckmark,            // 列表 cell 右边的checkmark
    QMUIImageShapeDetailButtonImage,    // 列表 cell 右边的 i 按钮图片
    QMUIImageShapeNavBack,              // 返回按钮的箭头
    QMUIImageShapeNavClose              // 导航栏的关闭icon
};

typedef NS_OPTIONS(NSInteger, QMUIImageBorderPosition) {
    QMUIImageBorderPositionAll      = 0,
    QMUIImageBorderPositionTop      = 1 << 0,
    QMUIImageBorderPositionLeft     = 1 << 1,
    QMUIImageBorderPositionBottom   = 1 << 2,
    QMUIImageBorderPositionRight    = 1 << 3,
};

typedef NS_ENUM(NSInteger, QMUIImageResizingMode) {
    QMUIImageResizingModeScaleToFill            = 0,    // 将图片缩放到给定的大小，不考虑宽高比例
    QMUIImageResizingModeScaleAspectFit         = 10,   // 默认的缩放方式，将图片保持宽高比例不变的情况下缩放到不超过给定的大小（但缩放后的大小不一定与给定大小相等），不会产生空白也不会产生裁剪
    QMUIImageResizingModeScaleAspectFill        = 20,   // 将图片保持宽高比例不变的情况下缩放到不超过给定的大小（但缩放后的大小不一定与给定大小相等），若有内容超出则会被裁剪。若裁剪则上下居中裁剪。
    QMUIImageResizingModeScaleAspectFillTop,            // 将图片保持宽高比例不变的情况下缩放到不超过给定的大小（但缩放后的大小不一定与给定大小相等），若有内容超出则会被裁剪。若裁剪则水平居中、垂直居上裁剪。
    QMUIImageResizingModeScaleAspectFillBottom          // 将图片保持宽高比例不变的情况下缩放到不超过给定的大小（但缩放后的大小不一定与给定大小相等），若有内容超出则会被裁剪。若裁剪则水平居中、垂直居下裁剪。
};

@interface UIImage (QMUI)

/**
 用于绘制一张图并以 UIImage 的形式返回

 @param size 要绘制的图片的 size，宽或高均不能为 0
 @param opaque 图片是否不透明，YES 表示不透明，NO 表示半透明
 @param scale 图片的倍数，0 表示取当前屏幕的倍数
 @param actionBlock 实际的图片绘制操作，在这里只管绘制就行，不用手动生成 image
 @return 返回绘制完的图片
 */
+ (nullable UIImage *)qmui_imageWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale actions:(void (^)(CGContextRef contextRef))actionBlock;

/// 获取当前图片的像素大小，如果是多倍图，会被放大到一倍来算
@property(nonatomic, assign, readonly) CGSize qmui_sizeInPixel;

/**
 *  判断一张图是否不存在 alpha 通道，注意 “不存在 alpha 通道” 不等价于 “不透明”。一张不透明的图有可能是存在 alpha 通道但 alpha 值为 1。
 */
- (BOOL)qmui_opaque;

/**
 *  获取当前图片的均色，原理是将图片绘制到1px*1px的矩形内，再从当前区域取色，得到图片的均色。
 *  @link http://www.bobbygeorgescu.com/2011/08/finding-average-color-of-uiimage/ @/link
 *
 *  @return 代表图片平均颜色的UIColor对象
 */
- (UIColor *)qmui_averageColor;

/**
 *  置灰当前图片
 *
 *  @return 已经置灰的图片
 */
- (nullable UIImage *)qmui_grayImage;

/**
 *  设置一张图片的透明度
 *
 *  @param alpha 要用于渲染透明度
 *
 *  @return 设置了透明度之后的图片
 */
- (nullable UIImage *)qmui_imageWithAlpha:(CGFloat)alpha;

/**
 *  保持当前图片的形状不变，使用指定的颜色去重新渲染它，生成一张新图片并返回
 *
 *  @param tintColor 要用于渲染的新颜色
 *
 *  @return 与当前图片形状一致但颜色与参数tintColor相同的新图片
 */
- (nullable UIImage *)qmui_imageWithTintColor:(nullable UIColor *)tintColor;

/**
 *  以 CIColorBlendMode 的模式为当前图片叠加一个颜色，生成一张新图片并返回，在叠加过程中会保留图片内的纹理。
 *
 *  @param blendColor 要叠加的颜色
 *
 *  @return 基于当前图片纹理保持不变的情况下颜色变为指定的叠加颜色的新图片
 *
 *  @warning 这个方法可能比较慢，会卡住主线程，建议异步使用
 */
- (nullable UIImage *)qmui_imageWithBlendColor:(nullable UIColor *)blendColor;

/**
 *  在当前图片的基础上叠加一张图片，并指定绘制叠加图片的起始位置
 *
 *  叠加上去的图片将保持原图片的大小不变，不被压缩、拉伸
 *
 *  @param image 要叠加的图片
 *  @param point 所叠加图片的绘制的起始位置
 *
 *  @return 返回一张与原图大小一致的图片，所叠加的图片若超出原图大小，则超出部分被截掉
 */
- (nullable UIImage *)qmui_imageWithImageAbove:(UIImage *)image atPoint:(CGPoint)point;

/**
 *  在当前图片的上下左右增加一些空白（不支持负值），通常用于调节NSAttributedString里的图片与文字的间距
 *  @param extension 要拓展的大小
 *  @return 拓展后的图片
 */
- (nullable UIImage *)qmui_imageWithSpacingExtensionInsets:(UIEdgeInsets)extension;

/**
 *  切割出在指定位置中的图片
 *
 *  @param rect 要切割的rect
 *
 *  @return 切割后的新图片
 */
- (nullable UIImage *)qmui_imageWithClippedRect:(CGRect)rect;


/**
 *  切割出在指定圆角的图片
 *
 *  @param cornerRadius 要切割的圆角值
 *
 *  @return 切割后的新图片
 */
- (nullable UIImage *)qmui_imageWithClippedCornerRadius:(CGFloat)cornerRadius;

/**
 *  同上，可以设置 scale
 */

- (nullable UIImage *)qmui_imageWithClippedCornerRadius:(CGFloat)cornerRadius scale:(CGFloat)scale;

/**
 *  将原图以 QMUIImageResizingModeScaleAspectFit 的策略缩放，使其缩放后的大小不超过指定的大小，并返回缩放后的图片。缩放后的图片的倍数保持与原图一致。
 *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 resizingMode 不同而不同，但必定不会超过 size。
 *
 *  @return 处理完的图片
 *  @see qmui_imageResizedInLimitedSize:resizingMode:scale:
 */
- (nullable UIImage *)qmui_imageResizedInLimitedSize:(CGSize)size;

/**
 *  将原图按指定的 QMUIImageResizingMode 缩放，使其缩放后的大小不超过指定的大小，并返回缩放后的图片，缩放后的图片的倍数保持与原图一致。
 *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 resizingMode 不同而不同，但必定不会超过 size。
 *  @param resizingMode 希望使用的缩放模式
 *
 *  @return 处理完的图片
 *  @see qmui_imageResizedInLimitedSize:resizingMode:scale:
 */
- (nullable UIImage *)qmui_imageResizedInLimitedSize:(CGSize)size resizingMode:(QMUIImageResizingMode)resizingMode;

/**
 *  将原图按指定的 QMUIImageResizingMode 缩放，使其缩放后的大小不超过指定的大小，并返回缩放后的图片。
 *  @param size 在这个约束的 size 内进行缩放后的大小，处理后返回的图片的 size 会根据 resizingMode 不同而不同，但必定不会超过 size。
 *  @param resizingMode 希望使用的缩放模式
 *  @param scale 用于指定缩放后的图片的倍数
 *
 *  @return 处理完的图片
 */
- (nullable UIImage *)qmui_imageResizedInLimitedSize:(CGSize)size resizingMode:(QMUIImageResizingMode)resizingMode scale:(CGFloat)scale;

/**
 *  将原图进行旋转，只能选择上下左右四个方向
 *
 *  @param  direction 旋转的方向
 *
 *  @return 处理完的图片
 */
- (nullable UIImage *)qmui_imageWithOrientation:(UIImageOrientation)direction;

/**
 *  为图片加上一个border，border的路径为path
 *
 *  @param borderColor  border的颜色
 *  @param path         border的路径
 *
 *  @return 带border的UIImage
 *  @warning 注意通过`path.lineWidth`设置边框大小，同时注意路径要考虑像素对齐（`path.lineWidth / 2.0`）
 */
- (nullable UIImage *)qmui_imageWithBorderColor:(nullable UIColor *)borderColor path:(nullable UIBezierPath *)path;

/**
 *  为图片加上一个border，border的路径为borderColor、cornerRadius和borderWidth所创建的path
 *
 *  @param borderColor   border的颜色
 *  @param borderWidth    border的宽度
 *  @param cornerRadius  border的圆角
 *
 *  @param dashedLengths 一个CGFloat的数组，例如`CGFloat dashedLengths[] = {2, 4}`。如果不需要虚线，则传0即可
 *
 *  @return 带border的UIImage
 */
- (nullable UIImage *)qmui_imageWithBorderColor:(nullable UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius dashedLengths:(nullable const CGFloat *)dashedLengths;
- (nullable UIImage *)qmui_imageWithBorderColor:(nullable UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius;


/**
 *  为图片加上一个border（可以是任意一条边，也可以是多条组合；只能创建矩形的border，不能添加圆角）
 *
 *  @param borderColor       border的颜色
 *  @param borderWidth        border的宽度
 *  @param borderPosition    border的位置
 *
 *  @return 带border的UIImage
 */
- (nullable UIImage *)qmui_imageWithBorderColor:(nullable UIColor *)borderColor borderWidth:(CGFloat)borderWidth borderPosition:(QMUIImageBorderPosition)borderPosition;

/**
 *  返回一个被mask的图片
 *
 *  @param maskImage             mask图片
 *  @param usingMaskImageMode    是否使用“mask image”的方式，若为 YES，则黑色部分显示，白色部分消失，透明部分显示，其他颜色会按照颜色的灰色度对图片做透明处理。若为 NO，则 maskImage 要求必须为灰度颜色空间的图片（黑白图），白色部分显示，黑色部分消失，透明部分消失，其他灰色度对图片做透明处理。
 *
 *  @return 被mask的图片
 */
- (nullable UIImage *)qmui_imageWithMaskImage:(UIImage *)maskImage usingMaskImageMode:(BOOL)usingMaskImageMode;

/**
 将 data 转换成 animated UIImage（如果非 animated 则转换成普通 UIImage），image 倍数为 1（与系统的 [UIImage imageWithData:] 接口一致）

 @param data 图片文件的 data
 @return 转换成的 UIImage
 */
+ (nullable UIImage *)qmui_animatedImageWithData:(NSData *)data;

/**
 将 data 转换成 animated UIImage（如果非 animated 则转换成普通 UIImage）

 @param data 图片文件的 data
 @param scale 图片的倍数，0 表示获取当前设备的屏幕倍数
 @return 转换成的 UIImage
 @see http://www.jianshu.com/p/767af9c690a3
 @see https://github.com/rs/SDWebImage
 */
+ (nullable UIImage *)qmui_animatedImageWithData:(NSData *)data scale:(CGFloat)scale;

/**
 在 mainBundle 里找到对应名字的图片， 注意图片 scale 为 1，与系统的 [UIImage imageWithData:] 接口一致，若需要修改倍数，请使用 -qmui_animatedImageNamed:scale:

 @param name 图片名，可指定后缀，若不写后缀，默认为“gif”。不写后缀的情况下会先找“gif”后缀的图片，不存在再找无后缀的文件，仍不存在则返回 nil
 @return  转换成的 UIImage
 */
+ (nullable UIImage *)qmui_animatedImageNamed:(NSString *)name;

/**
 在 mainBundle 里找到对应名字的图片
 
 @param name 图片名，可指定后缀，若不写后缀，默认为“gif”。不写后缀的情况下会先找“gif”后缀的图片，不存在再找无后缀的文件，仍不存在则返回 nil
 @param scale 图片的倍数，0 表示获取当前设备的屏幕倍数
 @return  转换成的 UIImage
 */
+ (nullable UIImage *)qmui_animatedImageNamed:(NSString *)name scale:(CGFloat)scale;

/**
 *  创建一个size为(4, 4)的纯色的UIImage
 *
 *  @param color 图片的颜色
 *
 *  @return 纯色的UIImage
 */
+ (nullable UIImage *)qmui_imageWithColor:(nullable UIColor *)color;

/**
 *  创建一个纯色的UIImage
 *
 *  @param  color           图片的颜色
 *  @param  size            图片的大小
 *  @param  cornerRadius    图片的圆角
 *
 * @return 纯色的UIImage
 */
+ (nullable UIImage *)qmui_imageWithColor:(nullable UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

/**
 *  创建一个纯色的UIImage，支持为四个角设置不同的圆角
 *  @param  color               图片的颜色
 *  @param  size                图片的大小
 *  @param  cornerRadius   四个角的圆角值的数组，长度必须为4，顺序分别为[左上角、左下角、右下角、右上角]
 */
+ (nullable UIImage *)qmui_imageWithColor:(nullable UIColor *)color size:(CGSize)size cornerRadiusArray:(nullable NSArray<NSNumber *> *)cornerRadius;

/**
 *  创建一个带边框路径，没有背景色的路径图片，border的路径为path
 *
 *  @param strokeColor  border的颜色
 *  @param path         border的路径
 *  @param addClip      是否要调path的addClip
 *
 *  @return 带border的UIImage
 */
+ (nullable UIImage *)qmui_imageWithStrokeColor:(nullable UIColor *)strokeColor size:(CGSize)size path:(nullable UIBezierPath *)path addClip:(BOOL)addClip;

/**
 *  创建一个带边框路径，没有背景色的路径图片，border的路径为strokeColor、cornerRadius和lineWidth所创建的path
 *
 *  @param strokeColor  border的颜色
 *  @param lineWidth    border的宽度
 *  @param cornerRadius border的圆角
 *
 *  @return 带border的UIImage
 */
+ (nullable UIImage *)qmui_imageWithStrokeColor:(nullable UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth cornerRadius:(CGFloat)cornerRadius;

/**
 *  创建一个带边框路径，没有背景色的路径图片（可以是任意一条边，也可以是多条组合；只能创建矩形的border，不能添加圆角）
 *
 *  @param strokeColor        路径的颜色
 *  @param size               图片的大小
 *  @param lineWidth          路径的大小
 *  @param borderPosition     图片的路径位置，上左下右
 *
 *  @return 带路径，没有背景色的UIImage
 */
+ (nullable UIImage *)qmui_imageWithStrokeColor:(nullable UIColor *)strokeColor size:(CGSize)size lineWidth:(CGFloat)lineWidth borderPosition:(QMUIImageBorderPosition)borderPosition;
/**
 *  创建一个指定大小和颜色的形状图片
 *  @param shape 图片形状
 *  @param size 图片大小
 *  @param tintColor 图片颜色
 */
+ (nullable UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size tintColor:(nullable UIColor *)tintColor;

/**
 *  创建一个指定大小和颜色的形状图片
 *  @param shape 图片形状
 *  @param size 图片大小
 *  @param lineWidth 路径大小，不会影响最终size
 *  @param tintColor 图片颜色
 */
+ (nullable UIImage *)qmui_imageWithShape:(QMUIImageShape)shape size:(CGSize)size lineWidth:(CGFloat)lineWidth tintColor:(nullable UIColor *)tintColor;

/**
 *  将文字渲染成图片，最终图片和文字一样大
 */
+ (nullable UIImage *)qmui_imageWithAttributedString:(NSAttributedString *)attributedString;

/**
 对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回。注意这里使用的是 view.layer 来渲染图片内容。

 @param view 要截图的 `UIView`

 @return `UIView` 的截图
 
 @warning UIView 的 transform 并不会在截图里生效
 */
+ (nullable UIImage *)qmui_imageWithView:(UIView *)view;

/**
 对传进来的 `UIView` 截图，生成一个 `UIImage` 并返回。注意这里使用的是 iOS 7的系统截图接口。

 @param view         要截图的 `UIView`
 @param afterUpdates 是否要在界面更新完成后才截图

 @return `UIView` 的截图
 
 @warning UIView 的 transform 并不会在截图里生效
 */
+ (nullable UIImage *)qmui_imageWithView:(UIView *)view afterScreenUpdates:(BOOL)afterUpdates;

@end

NS_ASSUME_NONNULL_END
