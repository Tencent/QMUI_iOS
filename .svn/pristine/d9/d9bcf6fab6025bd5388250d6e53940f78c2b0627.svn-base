#!python

import os

# 当有文件增删时，可将此脚本添加到 Build Phases 里作为 Run Script 运行，通过它去自动更新 QMUIKit.h 的内容，然后再把 Run Script 去掉。

publicHeaderFilePath = str(os.getenv('BUILT_PRODUCTS_DIR')) + '/' + os.getenv('PUBLIC_HEADERS_FOLDER_PATH') 
print 'umbrella creator: publicHeaderFilePath = ' + publicHeaderFilePath 
umbrellaHeaderFileName = 'QMUIKit.h'
umbrellaHeaderFilePath = str(os.getenv('SRCROOT')) + '/QMUIKit/' + umbrellaHeaderFileName
print 'umbrella creator: umbrellaHeaderFilePath = ' + umbrellaHeaderFilePath
umbrellaFileContent = '''/// Automatically created by script in Build Phases

#import <UIKit/UIKit.h>

'''

onlyfiles = [ f for f in os.listdir(publicHeaderFilePath) if os.path.isfile(os.path.join(publicHeaderFilePath, f))]
for filename in onlyfiles:
  if filename != umbrellaHeaderFileName:
    umbrellaFileContent += '''#if __has_include("%s")
#import "%s"
#endif

''' % (filename, filename)

print 'umbrella creator: umbrellaFileContent = ' + umbrellaFileContent

f = open(umbrellaHeaderFilePath, 'r+')
f.seek(0)
f.write(umbrellaFileContent)
f.truncate()
f.close()

