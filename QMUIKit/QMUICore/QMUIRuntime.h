/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIRuntime.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/8/14.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/// 以高级语言的方式描述一个 objc_property_t 的各种属性，请使用 `+descriptorWithProperty` 生成对象后直接读取对象的各种值。
@interface QMUIPropertyDescriptor : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) SEL getter;
@property(nonatomic, assign) SEL setter;

@property(nonatomic, assign) BOOL isAtomic;
@property(nonatomic, assign) BOOL isNonatomic;

@property(nonatomic, assign) BOOL isAssign;
@property(nonatomic, assign) BOOL isWeak;
@property(nonatomic, assign) BOOL isStrong;
@property(nonatomic, assign) BOOL isCopy;

@property(nonatomic, assign) BOOL isReadonly;
@property(nonatomic, assign) BOOL isReadwrite;

@property(nonatomic, copy) NSString *type;

+ (instancetype)descriptorWithProperty:(objc_property_t)property;

@end

#pragma mark - Method

/**
 *  如果 fromClass 里存在 originSelector，则这个函数会将 fromClass 里的 originSelector 与 toClass 里的 newSelector 交换实现。
 *  如果 fromClass 里不存在 originSelecotr，则这个函数会为 fromClass 增加方法 originSelector，并且该方法会使用 toClass 的 newSelector 方法的实现，而 toClass 的 newSelector 方法的实现则会被替换为空内容
 *  @warning 注意如果 fromClass 里的 originSelector 是继承自父类并且 fromClass 也没有重写这个方法，这会导致实际上被替换的是父类，然后父类及父类的所有子类（也即 fromClass 的兄弟类）也受影响，因此使用时请谨记这一点。
 *  @param _fromClass 要被替换的 class，不能为空
 *  @param _originSelector 要被替换的 class 的 selector，可为空，为空则相当于为 fromClass 新增这个方法
 *  @param _toClass 要拿这个 class 的方法来替换
 *  @param _newSelector 要拿 toClass 里的这个方法来替换 originSelector
 *  @return 是否成功替换（或增加）
 */
CG_INLINE BOOL
ExchangeImplementationsInTwoClasses(Class _fromClass, SEL _originSelector, Class _toClass, SEL _newSelector) {
    if (!_fromClass || !_toClass) {
        return NO;
    }
    
    Method oriMethod = class_getInstanceMethod(_fromClass, _originSelector);
    Method newMethod = class_getInstanceMethod(_toClass, _newSelector);
    if (!newMethod) {
        return NO;
    }
    
    BOOL isAddedMethod = class_addMethod(_fromClass, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        // 如果 class_addMethod 成功了，说明之前 fromClass 里并不存在 originSelector，所以要用一个空的方法代替它，以避免 class_replaceMethod 后，后续 toClass 的这个方法被调用时可能会 crash
        IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
        const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
        class_replaceMethod(_toClass, _newSelector, oriMethodIMP, oriMethodTypeEncoding);
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
    return YES;
}

/// 交换同一个 class 里的 originSelector 和 newSelector 的实现，如果原本不存在 originSelector，则相当于给 class 新增一个叫做 originSelector 的方法
CG_INLINE BOOL
ExchangeImplementations(Class _class, SEL _originSelector, SEL _newSelector) {
    return ExchangeImplementationsInTwoClasses(_class, _originSelector, _class, _newSelector);
}

/**
 *  用 block 重写某个 class 的指定方法
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做
 *  @param implementationBlock 该 block 必须返回一个 block，返回的 block 将被当成 targetSelector 的新实现，所以要在内部自己处理对 super 的调用，以及对当前调用方法的 self 的 class 的保护判断（因为如果 targetClass 的 targetSelector 是继承自父类的，targetClass 内部并没有重写这个方法，则我们这个函数最终重写的其实是父类的 targetSelector，所以会产生预期之外的 class 的影响，例如 targetClass 传进来  UIButton.class，则最终可能会影响到 UIView.class），implementationBlock 的参数里第一个为你要修改的 class，也即等同于 targetClass，第二个参数为你要修改的 selector，也即等同于 targetSelector，第三个参数是 targetSelector 原本的实现，由于 IMP 可以直接当成 C 函数调用，所以可利用它来实现“调用 super”的效果，但由于 targetSelector 的参数个数、参数类型、返回值类型，都会影响 IMP 的调用写法，所以这个调用只能由业务自己写。
 */
CG_INLINE BOOL
OverrideImplementation(Class targetClass, SEL targetSelector, id (^implementationBlock)(Class originClass, SEL originCMD, IMP originIMP)) {
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    if (!originMethod) {
        return NO;
    }
    IMP originIMP = method_getImplementation(originMethod);
    method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originIMP)));
    return YES;
}

/**
 *  用 block 重写某个 class 的某个无参数且返回值为 void 的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须无参数，返回值为 void
 *  @param implementationBlock targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针。
 */
CG_INLINE BOOL
ExtendImplementationOfVoidMethodWithoutArguments(Class targetClass, SEL targetSelector, void (^implementationBlock)(__kindof NSObject *selfObject)) {
    return OverrideImplementation(targetClass, targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {
        return ^(__kindof NSObject *selfObject) {
            
            void (*originSelectorIMP)(id, SEL);
            originSelectorIMP = (void (*)(id, SEL))originIMP;
            originSelectorIMP(selfObject, originCMD);
            
            if (![selfObject isKindOfClass:originClass]) return;
            
            implementationBlock(selfObject);
        };
    });
}

/**
 *  用 block 重写某个 class 的某个无参数且带返回值的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param _targetClass 要重写的 class
 *  @param _targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值不为空
 *  @param _returnType 返回值的数据类型
 *  @param _implementationBlock 格式为 ^_returnType(NSObject *selfObject, _returnType originReturnValue) {}，内容即为 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 originReturnValue 代表 super 的返回值，具体类型请自行填写
 */
#define ExtendImplementationOfNonVoidMethodWithoutArguments(_targetClass, _targetSelector, _returnType, _implementationBlock) OverrideImplementation(_targetClass, _targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {\
            return ^_returnType (__kindof NSObject *selfObject) {\
                \
                _returnType (*originSelectorIMP)(id, SEL);\
                originSelectorIMP = (_returnType (*)(id, SEL))originIMP;\
                _returnType result = originSelectorIMP(selfObject, originCMD);\
                \
                if ([selfObject isKindOfClass:originClass]) {\
                    return _implementationBlock(selfObject, result);\
                }\
                \
                return result;\
            };\
        });

/**
 *  用 block 重写某个 class 的带一个参数且返回值为 void 的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param _targetClass 要重写的 class
 *  @param _targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值为 void
 *  @param _argumentType targetSelector 的参数类型
 *  @param _implementationBlock 格式为 ^(NSObject *selfObject, _argumentType firstArgv) {}，内容即为 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 firstArgv 代表 targetSelector 被调用时传进来的第一个参数，具体的类型请自行填写
 */
#define ExtendImplementationOfVoidMethodWithSingleArgument(_targetClass, _targetSelector, _argumentType, _implementationBlock) OverrideImplementation(_targetClass, _targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {\
        return ^(__kindof NSObject *selfObject, _argumentType firstArgv) {\
            \
            void (*originSelectorIMP)(id, SEL, _argumentType);\
            originSelectorIMP = (void (*)(id, SEL, _argumentType))originIMP;\
            originSelectorIMP(selfObject, originCMD, firstArgv);\
            \
            if (![selfObject isKindOfClass:originClass]) return;\
            \
            _implementationBlock(selfObject, firstArgv);\
        };\
    });

/**
 *  用 block 重写某个 class 的带一个参数且带返回值的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值不为空
 *  @param implementationBlock，格式为 ^_returnType (NSObject *selfObject, _argumentType firstArgv, _returnType originReturnValue){}，内容也即 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 firstArgv 代表 targetSelector 被调用时传进来的第一个参数，具体的类型请自行填写；第三个参数 originReturnValue 代表 super 的返回值，具体类型请自行填写
 */
#define ExtendImplementationOfNonVoidMethodWithSingleArgument(_targetClass, _targetSelector, _argumentType, _returnType, _implementationBlock) OverrideImplementation(_targetClass, _targetSelector, ^id(Class originClass, SEL originCMD, IMP originIMP) {\
        return ^_returnType (__kindof NSObject *selfObject, _argumentType firstArgv) {\
            \
            _returnType (*originSelectorIMP)(id, SEL, _argumentType);\
            originSelectorIMP = (_returnType (*)(id, SEL, _argumentType))originIMP;\
            _returnType result = originSelectorIMP(selfObject, originCMD, firstArgv);\
            \
            if ([selfObject isKindOfClass:originClass]) {\
                return _implementationBlock(selfObject, firstArgv, result);\
            }\
            \
            return result;\
        };\
    });

#pragma mark - Ivar

/**
 用于判断一个给定的 type encoding（const char *）或者 Ivar 是哪种类型的系列函数。
 
 为了节省代码量，函数由宏展开生成，一个宏会展开为两个函数定义：
 
 1. isXxxTypeEncoding(const char *)，例如判断是否为 BOOL 类型的函数名为：isBOOLTypeEncoding()
 2. isXxxIvar(Ivar)，例如判断是否为 BOOL 的 Ivar 的函数名为：isBOOLIvar()
 
 @see https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 */
#define _QMUITypeEncodingDetectorGenerator(_TypeInFunctionName, _typeForEncode) \
    CG_INLINE BOOL is##_TypeInFunctionName##TypeEncoding(const char *typeEncoding) {\
        return strncmp(@encode(_typeForEncode), typeEncoding, strlen(@encode(_typeForEncode))) == 0;\
    }\
    CG_INLINE BOOL is##_TypeInFunctionName##Ivar(Ivar ivar) {\
        return is##_TypeInFunctionName##TypeEncoding(ivar_getTypeEncoding(ivar));\
    }

_QMUITypeEncodingDetectorGenerator(Char, char)
_QMUITypeEncodingDetectorGenerator(Int, int)
_QMUITypeEncodingDetectorGenerator(Short, short)
_QMUITypeEncodingDetectorGenerator(Long, long)
_QMUITypeEncodingDetectorGenerator(LongLong, long long)
_QMUITypeEncodingDetectorGenerator(UnsignedChar, unsigned char)
_QMUITypeEncodingDetectorGenerator(UnsignedInt, unsigned int)
_QMUITypeEncodingDetectorGenerator(UnsignedShort, unsigned short)
_QMUITypeEncodingDetectorGenerator(UnsignedLong, unsigned long)
_QMUITypeEncodingDetectorGenerator(UnsignedLongLong, unsigned long long)
_QMUITypeEncodingDetectorGenerator(Float, float)
_QMUITypeEncodingDetectorGenerator(Double, double)
_QMUITypeEncodingDetectorGenerator(BOOL, BOOL)
_QMUITypeEncodingDetectorGenerator(Void, void)
_QMUITypeEncodingDetectorGenerator(Character, char *)
_QMUITypeEncodingDetectorGenerator(Object, id)
_QMUITypeEncodingDetectorGenerator(Class, Class)
_QMUITypeEncodingDetectorGenerator(Selector, SEL)

//CG_INLINE char getCharIvarValue(id object, Ivar ivar) {
//    ptrdiff_t ivarOffset = ivar_getOffset(ivar);
//    unsigned char * bytes = (unsigned char *)(__bridge void *)object;
//    char value = *((char *)(bytes + ivarOffset));
//    return value;
//}

#define _QMUIGetIvarValueGenerator(_TypeInFunctionName, _typeForEncode) \
    CG_INLINE _typeForEncode get##_TypeInFunctionName##IvarValue(id object, Ivar ivar) {\
        ptrdiff_t ivarOffset = ivar_getOffset(ivar);\
        unsigned char * bytes = (unsigned char *)(__bridge void *)object;\
        _typeForEncode value = *((_typeForEncode *)(bytes + ivarOffset));\
        return value;\
    }

_QMUIGetIvarValueGenerator(Char, char)
_QMUIGetIvarValueGenerator(Int, int)
_QMUIGetIvarValueGenerator(Short, short)
_QMUIGetIvarValueGenerator(Long, long)
_QMUIGetIvarValueGenerator(LongLong, long long)
_QMUIGetIvarValueGenerator(UnsignedChar, unsigned char)
_QMUIGetIvarValueGenerator(UnsignedInt, unsigned int)
_QMUIGetIvarValueGenerator(UnsignedShort, unsigned short)
_QMUIGetIvarValueGenerator(UnsignedLong, unsigned long)
_QMUIGetIvarValueGenerator(UnsignedLongLong, unsigned long long)
_QMUIGetIvarValueGenerator(Float, float)
_QMUIGetIvarValueGenerator(Double, double)
_QMUIGetIvarValueGenerator(BOOL, BOOL)
_QMUIGetIvarValueGenerator(Character, char *)
_QMUIGetIvarValueGenerator(Selector, SEL)

CG_INLINE id getObjectIvarValue(id object, Ivar ivar) {
    return object_getIvar(object, ivar);
}
