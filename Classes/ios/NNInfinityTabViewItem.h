//
//  NNInfinityTabViewItem.h
//  NNInfinityTabView
//
//  Created by Naoto Horiguchi on 2014/05/07.
//  Copyright (c) 2014年 Naoto Horiguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NNInfinityTabViewItem : UIView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL selected;

- (void)prepareForReuse;

@end
