//
//  NNInfinityTabView.h
//  NNInfinityTabView
//
//  Created by Naoto Horiguchi on 2014/05/07.
//  Copyright (c) 2014年 Naoto Horiguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NNInfinityTabViewItem.h"

typedef NS_ENUM(NSUInteger, NNInfinityTabViewDirection) {
    NNInfinityTabViewDirectionHorizontal,
    NNInfinityTabViewDirectionVertical
};

typedef NS_ENUM(NSUInteger, NNInfinityTabViewScrollPosition) {
    NNInfinityTabViewScrollPositionNone,
    NNInfinityTabViewScrollPositionTop,
    NNInfinityTabViewScrollPositionMiddle,
    NNInfinityTabViewScrollPositionBottom,
    NNInfinityTabViewScrollPositionLeft,
    NNInfinityTabViewScrollPositionRight
};

@class NNInfinityTabView;
@protocol NNInfinityTabViewDelegate <UIScrollViewDelegate>

- (CGSize)infinityTabView:(NNInfinityTabView *)infinityTabView sizeOfItemAtIndex:(NSInteger)index;

@optional
- (void)infinityTabView:(NNInfinityTabView *)infinityTabView didSelectItemAtIndex:(NSInteger)index;

@end

@protocol NNInfinityTabViewDataSource;

@interface NNInfinityTabView : UIScrollView

//default NNInfinityTabViewDirectionHorizontal
@property (nonatomic, readonly) NNInfinityTabViewDirection direction;
@property (nonatomic, weak) id<NNInfinityTabViewDataSource>dataSource;
@property (nonatomic, weak) id<NNInfinityTabViewDelegate>delegate;
@property (nonatomic) BOOL infinityMode; // default YES
@property (nonatomic) NNInfinityTabViewScrollPosition scrollFinishPosition; // default NNInfinityTabViewScrollPositionNone;

- (instancetype)initWithFrame:(CGRect)frame direction:(NNInfinityTabViewDirection)direction;

- (void)reloadData;
- (NSInteger)numberOfItems;
- (CGRect)rectForItemAtIndex:(NSInteger)index;
- (NSInteger)indexForItemAtPoint:(CGPoint)point;
- (NSInteger)indexForItem:(NNInfinityTabViewItem *)item;
- (NSArray *)indexesForItemsInRect:(CGRect)rect;

- (NNInfinityTabViewItem *)itemAtIndex:(NSInteger)index;

- (NSArray *)visibleItems;
- (NSArray *)indexesForVisibleItems;

- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(NNInfinityTabViewScrollPosition)scrollPosition animated:(BOOL)animated;
//- (void)scrollToNearestSelectedItemAtScrollPosition:(NNInfinityTabViewScrollPosition)scrollPosition animated:(BOOL)animated;

// I'll be not open these methods.
//- (void)beginUpdates;
//- (void)endUpdates;
//- (void)insertItemsAtIndexes:(NSArray *)indexes withItemAnimation:(UITableViewRowAnimation)animation;
//- (void)deleteItemsAtIndexPaths:(NSArray *)indexes withItemAnimation:(UITableViewRowAnimation)animation;
//- (void)reloadItemsAtIndexPaths:(NSArray *)indexes withItemAnimation:(UITableViewRowAnimation)animation;
//- (void)moveItemAtIndexPath:(NSInteger)index toIndexPath:(NSInteger)newIndex;

- (NSInteger)indexForSelectedItem;
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(NNInfinityTabViewScrollPosition)scrollPosition;
- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier;
//- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier forIndex:(NSInteger)indexPath;
- (void)registerClass:(Class)cellClass forItemReuseIdentifier:(NSString *)identifier;

@end

@protocol NNInfinityTabViewDataSource <NSObject>

- (NNInfinityTabViewItem *)infinityTabView:(NNInfinityTabView *)infinityTabView itemAtIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInInfinityTabView:(NNInfinityTabView *)infinityTabView;

@end