//
//  NNInfinityTabView.m
//  NNInfinityTabView
//
//  Created by Naoto Horiguchi on 2014/05/07.
//  Copyright (c) 2014年 Naoto Horiguchi. All rights reserved.
//

#import "NNInfinityTabView.h"

@implementation NNInfinityTabView
{
    NSInteger _numOfItems;
    NSArray *_itemRects;
    NSMutableArray *_itemReuseQueues;
    NSMutableArray *_visibleItems;
    NSInteger _touchedIndex;
    NSInteger _selectedIndex;
   
    CADisplayLink *_displayLink;
    NSTimeInterval _startTimestamp;
    //CGPoint _velocity;
    CGPoint _lastDistance;
    CGFloat _duration;
    CGPoint _scrollToPoint;
    CGPoint _scrollFromPoint;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero direction:NNInfinityTabViewDirectionHorizontal];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame direction:NNInfinityTabViewDirectionHorizontal];
}

- (instancetype)initWithFrame:(CGRect)frame direction:(NNInfinityTabViewDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollFinishPosition = NNInfinityTabViewScrollPositionNone;
        _infinityMode = YES;
        _selectedIndex = -1;
        _itemReuseQueues = @[].mutableCopy;
        _visibleItems    = @[].mutableCopy;

        _direction = direction;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = NO;
        self.scrollsToTop = NO;
        
        [self.panGestureRecognizer addTarget:self action:@selector(_panGestureHandler:)];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_displayUpdateHandler:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    return self;
}

- (void)setInfinityMode:(BOOL)infinityMode
{
    _infinityMode = infinityMode;
    [self reloadData];
}

- (void)reloadData
{
    NSInteger x = (_infinityMode)?2:1;
    
    _numOfItems = [self.dataSource numberOfItemsInInfinityTabView:self];
    
    CGRect lastRect = CGRectZero;
    NSMutableArray *tmpOriginalRect = @[].mutableCopy;
    for (NSInteger i = 0; i < _numOfItems * x; i++) {
        CGSize size;
        if (i < _numOfItems) {
            size = [self.delegate infinityTabView:self sizeOfItemAtIndex:i];
        } else {
            if ((_direction == NNInfinityTabViewDirectionHorizontal && CGRectGetMinX(lastRect)<=CGRectGetWidth(self.bounds)) || (_direction == NNInfinityTabViewDirectionVertical && CGRectGetMinY(lastRect)<=CGRectGetHeight(self.bounds))) {
                _infinityMode = NO;
                break;
            }
            size = [tmpOriginalRect[i%_numOfItems] CGRectValue].size;
        }
        CGRect rect;
        if (_direction == NNInfinityTabViewDirectionHorizontal) {
            rect = CGRectMake(CGRectGetMaxX(lastRect), 0, size.width, CGRectGetHeight(self.frame));
        } else {
            rect = CGRectMake(0, CGRectGetMaxY(lastRect), CGRectGetWidth(self.frame), size.height);
        }
        [tmpOriginalRect addObject:[NSValue valueWithCGRect:rect]];
        lastRect = rect;
    }
    _itemRects = [tmpOriginalRect copy];
    if (_direction == NNInfinityTabViewDirectionHorizontal) {
        self.contentSize = CGSizeMake(CGRectGetMaxX(lastRect), CGRectGetHeight(self.frame));
    } else {
        self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(lastRect));
    }
}

- (void)_selectItemAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(NNInfinityTabViewScrollPosition)scrollPosition
{
    [self deselectItemAtIndex:[self indexFromInternalIndex:_selectedIndex] animated:NO];
    
    _selectedIndex = index;
    NNInfinityTabViewItem *item = [self _itemAtIndex:_selectedIndex];
    item.selected = YES;
    
    [self scrollToItemAtIndex:index atScrollPosition:scrollPosition animated:animated];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated scrollPosition:(NNInfinityTabViewScrollPosition)scrollPosition
{
    [self deselectItemAtIndex:[self indexFromInternalIndex:_selectedIndex] animated:NO];
    
    _selectedIndex = index;
    
    NNInfinityTabViewItem *item = [self itemAtIndex:_selectedIndex];
    item.selected = YES;
    
    [self scrollToItemAtIndex:index atScrollPosition:scrollPosition animated:animated];
}

- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSArray *internalIndexes = [self internalIndexesFromIndex:index];
    for (NSNumber *internalNum in internalIndexes) {
        if ([internalNum integerValue] == _selectedIndex) {
            NNInfinityTabViewItem *item = [self itemAtIndex:index];
            item.selected = NO;
            _selectedIndex = -1;
        }
    }
}

- (NSInteger)numberOfItems
{
    return _numOfItems;
}

- (NNInfinityTabViewItem *)_itemAtIndex:(NSInteger)index
{
    NNInfinityTabViewItem *item = nil;
    for (NSNumber *indexNum in [self _indexesForVisibleItems]) {
        if ([indexNum integerValue] == index) {
            CGRect rect = [self _rectForItemAtIndex:index];
            for (NNInfinityTabViewItem *visibleItem in [self visibleItems]) {
                if (CGRectEqualToRect(rect, visibleItem.frame)) {
                    item = visibleItem;
                    break;
                }
            }
            break;
        }
    }
    return item;
}

- (NNInfinityTabViewItem *)itemAtIndex:(NSInteger)index
{
    NNInfinityTabViewItem *item = nil;
    for (NSNumber *indexNum in [self indexesForVisibleItems]) {
        if ([indexNum integerValue] == index) {
            CGRect rect = [self rectForItemAtIndex:index];
            for (NNInfinityTabViewItem *visibleItem in [self visibleItems]) {
                if (CGRectEqualToRect(rect, visibleItem.frame)) {
                    item = visibleItem;
                    break;
                }
            }
            break;
        }
    }
    return item;
}

- (NSInteger)_indexForItemAtPoint:(CGPoint)point
{
    for (NNInfinityTabViewItem *item in _visibleItems) {
        if (CGRectContainsPoint(item.frame, point)) {
            return [self _indexForItem:item];
        }
    }
    return -1;
}

- (NSInteger)indexForItemAtPoint:(CGPoint)point
{
    return [self indexFromInternalIndex:[self _indexForItemAtPoint:point]];
}

- (NSArray *)_indexesForItemsInRect:(CGRect)rect
{
    NSInteger x = (_infinityMode) ? 2 : 1;
    NSMutableArray *indexes = @[].mutableCopy;
    for (int i = 0; i < _numOfItems * x; i++) {
        CGRect targetRect = [_itemRects[i] CGRectValue];
        if (CGRectIntersectsRect(rect, targetRect)) {
            [indexes addObject:[NSNumber numberWithInt:i]];
        }
    }
    return indexes;
}

- (NSArray *)indexesForItemsInRect:(CGRect)rect
{
    NSArray *internalIndexes = [self _indexesForItemsInRect:rect];
    NSMutableArray *indexes = @[].mutableCopy;
    for (NSNumber *index in internalIndexes) {
        [indexes addObject:@([self indexFromInternalIndex:[index integerValue]])];
    }
    return indexes.copy;
}

- (NSArray *)_indexesForVisibleItems
{
    return [self _indexesForItemsInRect:self.bounds];
}

- (NSArray *)indexesForVisibleItems
{
    return [self indexesForItemsInRect:self.bounds];
}

- (NSInteger)_indexForItem:(NNInfinityTabViewItem *)item
{
    if ([[self visibleItems] containsObject:item]) {
        return [[self _indexesForItemsInRect:item.frame][0] integerValue];
    }
    return -1;
}

- (NSInteger)indexForItem:(NNInfinityTabViewItem *)item
{
    return [self indexFromInternalIndex:[self _indexForItem:item]];
}

- (NSInteger)indexFromInternalIndex:(NSInteger)internalIndex
{
    if (internalIndex < _numOfItems) {
        return internalIndex;
    } else {
        return internalIndex % _numOfItems;
    }
}

- (NSInteger)visibleInternalIndexFromIndex:(NSInteger)index
{
    for (NSNumber *internalNum in [self internalIndexesFromIndex:index]) {
        CGRect rect = [self _rectForItemAtIndex:[internalNum integerValue]];
        if (CGRectIntersectsRect(self.bounds, rect)) {
            return [internalNum integerValue];
        }
    }
    return -1;
}

- (NSArray *)internalIndexesFromIndex:(NSInteger)index
{
    if (index < _numOfItems && index >= 0) {
        if (_infinityMode) {
            return @[@(index), @(index+_numOfItems)];
        }
        return @[@(index)];
    }
    return nil;
}

- (NSArray *)visibleItems
{
    return _visibleItems;
}

- (CGRect)_rectForItemAtIndex:(NSInteger)index
{
    return [[_itemRects objectAtIndex:index] CGRectValue];
}

- (CGRect)rectForItemAtIndex:(NSInteger)index
{
    NSInteger internalIndex = [self visibleInternalIndexFromIndex:index];
    if (internalIndex < 0) {
        internalIndex = index;
    }
    return [[_itemRects objectAtIndex:internalIndex] CGRectValue];
}

- (void)scrollToItemAtIndex:(NSInteger)index atScrollPosition:(NNInfinityTabViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    if (scrollPosition == NNInfinityTabViewScrollPositionNone) return;
    
    CGRect rect = [self rectForItemAtIndex:index];
    CGPoint point;
    if (_direction == NNInfinityTabViewDirectionHorizontal) {
        if (scrollPosition == NNInfinityTabViewScrollPositionMiddle) {
            point = CGPointMake(CGRectGetMinX(rect) - CGRectGetWidth(self.bounds) / 2 + CGRectGetWidth(rect) / 2, CGRectGetMinY(rect));
        } else if (scrollPosition == NNInfinityTabViewScrollPositionRight) {
            point = CGPointMake(CGRectGetMinX(rect) - (CGRectGetWidth(self.bounds) - CGRectGetWidth(rect)), CGRectGetMinY(rect));
        } else {
            point = rect.origin;
        }
        if (!_infinityMode && self.contentSize.width - CGRectGetWidth(self.bounds) < point.x) {
            CGFloat x = self.contentSize.width - CGRectGetWidth(self.bounds);
            x = (x<=0.)?0.:x;
            point = CGPointMake(x, point.y);
        }
    } else {
        if (scrollPosition == NNInfinityTabViewScrollPositionMiddle) {
            point = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) - CGRectGetHeight(self.bounds) / 2 + CGRectGetHeight(rect) / 2);
        } else if (scrollPosition == NNInfinityTabViewScrollPositionBottom) {
            point = CGPointMake(CGRectGetMinX(rect) ,CGRectGetMinY(rect) - (CGRectGetHeight(self.bounds) - CGRectGetHeight(rect)));
        } else {
            point = rect.origin;
        }
        if (!_infinityMode && self.contentSize.height - CGRectGetHeight(self.bounds) < point.y) {
            CGFloat y = self.contentSize.height - CGRectGetHeight(self.bounds);
            y = (y<=0.)?0.:y;
            point = CGPointMake(point.x, y);
        }
    }
    [self setContentOffset:point animated:animated];
}

- (void)_queueReusebleItem:(NNInfinityTabViewItem *)item
{
    [item removeFromSuperview];
    [item prepareForReuse];
    if ([_visibleItems containsObject:item]) {
        [_visibleItems removeObject:item];
    }
    [_itemReuseQueues addObject:item];
}

- (id)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    NNInfinityTabViewItem *item;
    for (NNInfinityTabViewItem *reusableItem in _itemReuseQueues) {
        if ([reusableItem.reuseIdentifier isEqualToString:identifier]) {
            item = reusableItem;
            break;
        }
    }
    if (item) {
        [_itemReuseQueues removeObject:item];
    }
    return item;
}

- (void)layoutSubviews
{
    NSAssert(!self.delegate || [self.delegate respondsToSelector:@selector(infinityTabView:itemAtIndex:)], @"Implement infinityTabView:itemAtIndex:");
    
    if (_numOfItems <= 0) return;
    
    CGFloat min;
    CGFloat max;
    
    if (_direction == NNInfinityTabViewDirectionHorizontal && _infinityMode) {
        min = 0;
        max = CGRectGetMinX([self _rectForItemAtIndex:_numOfItems]);
        if (self.contentOffset.x > max) {
            self.contentOffset = CGPointMake(min + self.contentOffset.x - max, self.contentOffset.y) ;
        } else if (self.contentOffset.x < min) {
            self.contentOffset = CGPointMake(max - (min - self.contentOffset.x), self.contentOffset.y) ;
        }
    } else if (_direction == NNInfinityTabViewDirectionVertical && _infinityMode){
        min = 0;
        max = CGRectGetMinY([self _rectForItemAtIndex:_numOfItems]);
        if (self.contentOffset.y > max) {
            //NSLog(@"up");
            self.contentOffset = CGPointMake(self.contentOffset.x, min + self.contentOffset.y - max) ;
        } else if (self.contentOffset.y < min) {
            //NSLog(@"min");
            self.contentOffset = CGPointMake(self.contentOffset.x, max - (min - self.contentOffset.y)) ;
        } else {
            //NSLog(@"else");
        }
    }
    
    NSArray *willVisibledItemIndexes = [self _indexesForVisibleItems];
    NSMutableArray *visibleItems = @[].mutableCopy;
    for (NSNumber *indexNum in willVisibledItemIndexes) {
        NSInteger itemIndex = [indexNum integerValue];
        NNInfinityTabViewItem *item = [self _itemAtIndex:itemIndex];
        if (!item) {
            item = [self.dataSource infinityTabView:self itemAtIndex:[self indexFromInternalIndex:itemIndex]];
        }
        item.frame = [self _rectForItemAtIndex:itemIndex];
        if ([[self internalIndexesFromIndex:[self indexFromInternalIndex:_selectedIndex]] containsObject:@(itemIndex)]) {
            item.selected = YES;
        }
        [visibleItems addObject:item];
        [self addSubview:item];
    }
    
    NSMutableSet *deleteItemSet = [NSMutableSet setWithArray:_visibleItems];
    [deleteItemSet minusSet:[NSSet setWithArray:visibleItems]];
    for (NNInfinityTabViewItem *deleteItem in deleteItemSet) {
        [self _queueReusebleItem:deleteItem];
    }
    
    _visibleItems = visibleItems;
}

#pragma mark - Touch Handler
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    NSInteger index = [self _indexForItemAtPoint:point];
    if (index >= 0) {
        _touchedIndex = index;
        NNInfinityTabViewItem *item = [self _itemAtIndex:_touchedIndex];
        item.highlighted = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    NSInteger index = [self _indexForItemAtPoint:point];
    if (_touchedIndex >= 0 && _touchedIndex == index) {
        NNInfinityTabViewItem *item = [self _itemAtIndex:_touchedIndex];
        item.highlighted = NO;
        [self _selectItemAtIndex:index animated:NO scrollPosition:NNInfinityTabViewScrollPositionNone];
        if (self.delegate && [self.delegate respondsToSelector:@selector(infinityTabView:didSelectItemAtIndex:)]) {
            [self.delegate infinityTabView:self didSelectItemAtIndex:[self indexFromInternalIndex:index]];
        }
    } else {
        NNInfinityTabViewItem *item = [self _itemAtIndex:_touchedIndex];
        item.highlighted = NO;
    }
    
    _touchedIndex = -1;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (_touchedIndex >= 0) {
        NNInfinityTabViewItem *item = [self _itemAtIndex:_touchedIndex];
        item.highlighted = NO;
    }
    _touchedIndex = -1;
}

- (void)dealloc
{
    [_displayLink invalidate];
}

#pragma mark - Gesture Handler

- (void)_panGestureHandler:(UIPanGestureRecognizer *)recognizer
{
    if (_scrollFinishPosition == NNInfinityTabViewScrollPositionNone) return;
    
    _displayLink.paused = YES;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        if (_direction == NNInfinityTabViewDirectionHorizontal) {
            CGFloat d = velocity.x * 0.08;
            _scrollToPoint = CGPointMake(self.bounds.origin.x - d, self.bounds.origin.y);
        } else {
            CGFloat d = velocity.y * 0.08;
            _scrollToPoint = CGPointMake(self.bounds.origin.x, self.bounds.origin.y + d);
        }
        _scrollFromPoint = self.bounds.origin;
        _lastDistance = CGPointZero;
        _startTimestamp = CACurrentMediaTime();
        _duration = 0.24;
        _displayLink.paused = NO;
        [self setContentOffset:self.bounds.origin animated:NO];
    }
}

#pragma mark - CADisplayLink Handler

- (void)_displayUpdateHandler:(CADisplayLink *)link
{
    if (_duration > link.timestamp-_startTimestamp) {
        CGFloat y = [self easeOutWithT:link.timestamp-_startTimestamp b:0 c:_scrollToPoint.y - _scrollFromPoint.y d:_duration];
        CGFloat x = [self easeOutWithT:link.timestamp-_startTimestamp b:0 c:_scrollToPoint.x - _scrollFromPoint.x d:_duration];
        self.contentOffset = CGRectMake(self.bounds.origin.x + (x-_lastDistance.x), self.bounds.origin.y + (_lastDistance.y-y), self.bounds.size.width, self.bounds.size.height).origin;
        _lastDistance = CGPointMake(x, y);
    } else {
        NSInteger index;
        if (_scrollFinishPosition == NNInfinityTabViewScrollPositionLeft || _scrollFinishPosition == NNInfinityTabViewScrollPositionTop) {
            index = [self _indexForItemAtPoint:self.bounds.origin];
        } else if (_scrollFinishPosition == NNInfinityTabViewScrollPositionMiddle){
            index = [self _indexForItemAtPoint:CGPointMake(self.bounds.origin.x + (self.bounds.size.width /2), self.bounds.origin.y + (self.bounds.size.height/2))];
        } else if (_scrollFinishPosition == NNInfinityTabViewScrollPositionBottom || _scrollFinishPosition == NNInfinityTabViewScrollPositionRight){
            index = [self _indexForItemAtPoint:CGPointMake(self.bounds.origin.x + self.frame.size.width - 1, self.bounds.origin.y + self.frame.size.height - 1)];
        }
        [self scrollToItemAtIndex:index atScrollPosition:_scrollFinishPosition animated:YES];
        _displayLink.paused = YES;
    }
}

- (CGFloat)easeOutWithT:(CGFloat)t b:(CGFloat)b c:(CGFloat)c d:(CGFloat)d
{
    t /= d;
    t = t - 1.;
    return c * ( t * t * t + 1.) + b;
//    return c * (-(pow(2.0,(-10.0 * t/d))) + 1) + b;
}


@end
