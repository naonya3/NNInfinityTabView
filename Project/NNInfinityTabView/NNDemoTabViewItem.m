//
//  NNDemoTabViewItem.m
//  NNInfinityTabView
//
//  Created by Naoto Horiguchi on 2014/05/09.
//  Copyright (c) 2014年 Naoto Horiguchi. All rights reserved.
//

#import "NNDemoTabViewItem.h"

@implementation NNDemoTabViewItem

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont boldSystemFontOfSize:20];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    self.contentView.backgroundColor = (selected)?[UIColor blackColor]:[UIColor clearColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    self.contentView.backgroundColor = (highlighted)?[UIColor whiteColor]:[UIColor clearColor];
}


@end
