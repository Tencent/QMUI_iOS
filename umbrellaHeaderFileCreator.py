#!/usr/bin/python
#coding:utf-8

import os
try:
  import xml.etree.cElementTree as ET
except ImportError:
  import xml.etree.ElementTree as ET

# 从 Info.plist 中读取 QMUIKit 的版本号，将其定义为一个 static const 常量以便代码里获取
infoFilePath = str(os.getenv('SRCROOT')) + '/QMUIKit/Info.plist'
infoTree = ET.parse(infoFilePath)
infoDictList = list(infoTree.find('dict'))
versionString = ''
for index in range(len(infoDictList)):
  element = infoDictList[index]
  if element.text == 'CFBundleShortVersionString':
    versionString = infoDictList[index + 1].text
    break
if versionString.startswith('$'):
  versionEnvName = versionString[2:-1]
  versionString = os.getenv(versionEnvName)
  print 'umbrella creator: bundle versions string is %s, env name is %s' % (versionString, versionEnvName)

# 读取头文件准备生成 umbrella file
publicHeaderFilePath = str(os.getenv('BUILT_PRODUCTS_DIR')) + '/' + os.getenv('PUBLIC_HEADERS_FOLDER_PATH') 
print 'umbrella creator: publicHeaderFilePath = ' + publicHeaderFilePath 
umbrellaHeaderFileName = 'QMUIKit.h'
umbrellaHeaderFilePath = str(os.getenv('SRCROOT')) + '/QMUIKit/' + umbrellaHeaderFileName
print 'umbrella creator: umbrellaHeaderFilePath = ' + umbrellaHeaderFilePath
umbrellaFileContent = '''/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

/// Automatically created by script in Build Phases

#import <UIKit/UIKit.h>

#ifndef QMUIKit_h
#define QMUIKit_h

static NSString * const QMUI_VERSION = @"%s";

''' % (versionString)

onlyfiles = [ f for f in os.listdir(publicHeaderFilePath) if os.path.isfile(os.path.join(publicHeaderFilePath, f))]
onlyfiles.sort()
for filename in onlyfiles:
  if filename != umbrellaHeaderFileName:
    umbrellaFileContent += '''#if __has_include("%s")
#import "%s"
#endif

''' % (filename, filename)

umbrellaFileContent += '#endif /* QMUIKit_h */'

umbrellaFileContent = umbrellaFileContent.strip()

f = open(umbrellaHeaderFilePath, 'r+')
f.seek(0)
oldFileContent = f.read().strip()
if oldFileContent == umbrellaFileContent:
  print 'umbrella creator: ' + umbrellaHeaderFileName + '的内容没有变化，不需要重写'
else:
  print 'umbrella creator: ' + umbrellaHeaderFileName + '的内容发生变化，开始重写'
  print 'umbrella creator: umbrellaFileContent = ' + umbrellaFileContent

  f.seek(0)
  f.write(umbrellaFileContent)
  f.truncate()

f.close()

