/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIAssetFetchResultChange.m
//  qmui
//
//  Created by QMUI Team on 20/8/29.
//

#import "QMUIAssetFetchResultChange.h"
#import <Photos/Photos.h>

@interface QMUIAssetFetchResultChangeMovePair : NSObject

@property (nonatomic, strong) NSIndexPath *fromIndexPath;

@property (nonatomic, strong) NSIndexPath *toIndexPath;

@end

@implementation QMUIAssetFetchResultChangeMovePair

@end

@interface QMUIAssetFetchResultChange ()

@property (nonatomic, strong) NSMutableArray <QMUIAssetFetchResultChangeMovePair *> *movePairs;

@end

@implementation QMUIAssetFetchResultChange

- (instancetype)initWithChangeDetails:(PHFetchResultChangeDetails<PHAsset *> *)changeDetails
                        albumSortType:(QMUIAlbumSortType)albumSortType {
    self = [super init];
    if (self) {
        _hasIncrementalChanges = changeDetails.hasIncrementalChanges;
        _hasMoves = changeDetails.hasMoves;
        const NSUInteger countAfterChanges = changeDetails.fetchResultAfterChanges.count;
        _removedIndexPaths = [self indexPathsForIndexSet:changeDetails.removedIndexes
                                           albumSortType:albumSortType
                                                   count:changeDetails.fetchResultBeforeChanges.count];
        _insertedIndexPaths = [self indexPathsForIndexSet:changeDetails.insertedIndexes
                                            albumSortType:albumSortType
                                                    count:countAfterChanges];
        _changedIndexPaths = [self indexPathsForIndexSet:changeDetails.changedIndexes
                                           albumSortType:albumSortType
                                                   count:countAfterChanges];
        NSMutableArray <QMUIAssetFetchResultChangeMovePair *> *movePairs = [[NSMutableArray alloc] init];
        [changeDetails enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
            QMUIAssetFetchResultChangeMovePair *movePair = [[QMUIAssetFetchResultChangeMovePair alloc] init];
            movePair.fromIndexPath = [NSIndexPath indexPathForItem:[self convertIndex:fromIndex
                                                                        albumSortType:albumSortType
                                                                                count:countAfterChanges]
                                                         inSection:0];
            movePair.toIndexPath = [NSIndexPath indexPathForItem:[self convertIndex:toIndex
                                                                      albumSortType:albumSortType
                                                                              count:countAfterChanges]
                                                       inSection:0];
            [movePairs addObject:movePair];
        }];
        _movePairs = movePairs;
    }
    return self;
}

- (void)enumerateMovesWithBlock:(void (^)(NSIndexPath * _Nonnull, NSIndexPath * _Nonnull))handler {
    
}

#pragma mark - Private
- (NSArray <NSIndexPath *> *)indexPathsForIndexSet:(NSIndexSet *)indexSet
                                     albumSortType:(QMUIAlbumSortType)albumSortType
                                             count:(NSUInteger)count {
    NSMutableArray <NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:[self convertIndex:idx
                                                                 albumSortType:albumSortType
                                                                         count:count]
                                                  inSection:0]];
    }];
    return indexPaths;
}

- (NSUInteger)convertIndex:(NSUInteger)index albumSortType:(QMUIAlbumSortType)albumSortType count:(NSUInteger)count {
    return albumSortType == QMUIAlbumSortTypeReverse ? count - 1 - index : index;
}

@end
