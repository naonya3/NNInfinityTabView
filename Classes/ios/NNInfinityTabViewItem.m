//
//  NNInfinityTabViewItem.m
//  NNInfinityTabView
//
//  Created by Naoto Horiguchi on 2014/05/07.
//  Copyright (c) 2014年 Naoto Horiguchi. All rights reserved.
//

#import "NNInfinityTabViewItem.h"

@implementation NNInfinityTabViewItem
{
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)prepareForReuse
{
    [self setSelected:NO];
}

@end
