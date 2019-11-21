/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  QMUIEasings.h
//  WeRead
//
//  Created by zhoonchen on 2018/9/3.
//

#import <UIKit/UIKit.h>

/// https://easings.net
/// http://cubic-bezier.com

CG_INLINE CGFloat
QMUI_Linear(CGFloat t) {
    return t;
}

CG_INLINE CGFloat
QMUI_EaseInSine(CGFloat t) {
    return 1 - cos(t * M_PI_2);
}

CG_INLINE CGFloat
QMUI_EaseOutSine(CGFloat t) {
    return sin(t * M_PI_2);
}

CG_INLINE CGFloat
QMUI_EaseInOutSine(CGFloat t) {
    return - (cos(M_PI * t) - 1) / 2;
}

CG_INLINE CGFloat
QMUI_EaseInQuad(CGFloat t) {
    return pow(t, 2);
}

CG_INLINE CGFloat
QMUI_EaseOutQuad(CGFloat t) {
    return 1 - pow(1 - t, 2);
}

CG_INLINE CGFloat
QMUI_EaseInOutQuad(CGFloat t) {
    return t < 0.5 ? (2 * pow(t, 2)) : (1 - pow(-2 * t + 2, 2) / 2);
}

CG_INLINE CGFloat
QMUI_EaseInCubic(CGFloat t) {
    return pow(t, 3);
}

CG_INLINE CGFloat
QMUI_EaseOutCubic(CGFloat t) {
    return 1 - pow(1 - t, 3);
}

CG_INLINE CGFloat
QMUI_EaseInOutCubic(CGFloat t) {
    return t < 0.5 ? (4 * pow(t, 3)) : (1 - pow(-2 * t + 2, 3) / 2);
}

CG_INLINE CGFloat
QMUI_EaseInQuart(CGFloat t) {
    return pow(t, 4);
}

CG_INLINE CGFloat
QMUI_EaseOutQuart(CGFloat t) {
    return 1 - pow(1 - t, 4);
}

CG_INLINE CGFloat
QMUI_EaseInOutQuart(CGFloat t) {
    return t < 0.5 ? (8 * pow(t, 4)) : (1 - pow(-2 * t + 2, 4) / 2);
}

CG_INLINE CGFloat
QMUI_EaseInQuint(CGFloat t) {
    return pow(t, 5);
}

CG_INLINE CGFloat
QMUI_EaseOutQuint(CGFloat t) {
    return 1 - pow(1 - t, 5);
}

CG_INLINE CGFloat
QMUI_EaseInOutQuint(CGFloat t) {
    return t < 0.5 ? (16 * pow(t, 5)) : (1 - pow(-2 * t + 2, 5) / 2);
}

CG_INLINE CGFloat
QMUI_EaseInExpo(CGFloat t) {
    return t == 0 ? 0 : pow(2, 10 * t - 10);
}

CG_INLINE CGFloat
QMUI_EaseOutExpo(CGFloat t) {
    return t == 1 ? 1 : 1 - pow(2, -10 * t);
}

CG_INLINE CGFloat
QMUI_EaseInOutExpo(CGFloat t) {
    return t == 0 ? 0 : t == 1 ? 1 : t < 0.5 ? pow(2, 20 * t - 10 ) / 2 : (2 - pow(2, -20 * t + 10 )) / 2;
}

CG_INLINE CGFloat
QMUI_EaseInCirc(CGFloat t) {
    return 1 - sqrt(1 - pow(t, 2));
}

CG_INLINE CGFloat
QMUI_EaseOutCirc(CGFloat t) {
    return sqrt(1 - pow(t - 1, 2));
}

CG_INLINE CGFloat
QMUI_EaseInOutCirc(CGFloat t) {
    return t < 0.5 ? (1 - sqrt(1 - pow(2 * t, 2))) / 2 : (sqrt(1 - pow(-2 * t + 2, 2)) + 1) / 2;
}

CG_INLINE CGFloat
QMUI_EaseInBack(CGFloat t) {
    return pow(t, 3) - t * sin(t * M_PI);
}

CG_INLINE CGFloat
QMUI_EaseOutBack(CGFloat t) {
    CGFloat f = (1 - t);
    return 1 - (pow(f, 3) - f * sin(f * M_PI));
}

CG_INLINE CGFloat
QMUI_EaseInOutBack(CGFloat t) {
    if (t < 0.5) {
        CGFloat f = 2 * t;
        return 0.5 * (pow(f, 3) - f * sin(f * M_PI));
    } else {
        CGFloat f = (1 - (2 * t - 1));
        return 0.5 * (1 - (pow(f, 3) - f * sin(f * M_PI))) + 0.5;
    }
}

CG_INLINE CGFloat
QMUI_EaseInElastic(CGFloat t) {
    return sin(13 * M_PI_2 * t) * pow(2, 10 * (t - 1));
}

CG_INLINE CGFloat
QMUI_EaseOutElastic(CGFloat t) {
    return sin(-13 * M_PI_2 * (t + 1)) * pow(2, -10 * t) + 1;
}

CG_INLINE CGFloat
QMUI_EaseInOutElastic(CGFloat t) {
    if (t < 0.5) {
        return 0.5 * sin(13 * M_PI_2 * (2 * t)) * pow(2, 10 * ((2 * t) - 1));
    } else {
        return 0.5 * (sin(-13 * M_PI_2 * ((2 * t - 1) + 1)) * pow(2, -10 * (2 * t - 1)) + 2);
    }
}

CG_INLINE CGFloat
QMUI_EaseOutBounce(CGFloat t) {
    if (t < 4.0 / 11.0) {
        return (121.0 * t * t) / 16.0;
    } else if (t < 8.0 / 11.0) {
        return (363.0 / 40.0 * t * t) - (99.0 / 10.0 * t) + 17.0 / 5.0;
    } else if(t < 9.0 / 10.0) {
        return (4356.0 / 361.0 * t * t) - (35442.0 / 1805.0 * t) + 16061.0 / 1805.0;
    } else {
        return (54.0 / 5.0 * t * t) - (513.0 / 25.0 * t) + 268.0 / 25.0;
    }
}

CG_INLINE CGFloat
QMUI_EaseInBounce(CGFloat t) {
    return 1 - QMUI_EaseOutBounce(1 - t);
}

CG_INLINE CGFloat
QMUI_EaseInOutBounce(CGFloat t) {
    if (t < 0.5) {
        return 0.5 * QMUI_EaseInBounce(t * 2);
    } else {
        return 0.5 * QMUI_EaseOutBounce(t * 2 - 1) + 0.5;
    }
}

CG_INLINE CGFloat
QMUI_EaseSpring(CGFloat t, CGFloat mass, CGFloat damping, CGFloat stiffness, CGFloat initialVelocity) {
    
    // https://webkit.org/demos/spring/spring.js
    // https://webkit.org/demos/spring
    
    CGFloat m_w0 = sqrt(stiffness / mass);
    CGFloat m_zeta = damping / (2 * sqrt(stiffness * mass));
    
    CGFloat m_wd = 0;
    CGFloat m_A = 0;
    CGFloat m_B = 0;
    
    if (m_zeta < 1) {
        // Under-damped.
        m_wd = m_w0 * sqrt(1 - m_zeta * m_zeta);
        m_A = 1;
        m_B = (m_zeta * m_w0 + -initialVelocity) / m_wd;
    } else {
        // Critically damped (ignoring over-damped case for now).
        m_wd = 0;
        m_A = 1;
        m_B = -initialVelocity + m_w0;
    }
    
    if (m_zeta < 1) {
        // Under-damped
        t = exp(-t * m_zeta * m_w0) * (m_A * cos(m_wd * t) + m_B * sin(m_wd * t));
    } else {
        // Critically damped (ignoring over-damped case for now).
        t = (m_A + m_B * t) * exp(-t * m_w0);
    }
    
    // Map range from [1..0] to [0..1].
    return 1 - t;
}
