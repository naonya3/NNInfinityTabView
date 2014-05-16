//
//  NNRootViewController.m
//  NNInfinityTabView
//
//  Created by Naoto Horiguchi on 2014/05/07.
//  Copyright (c) 2014年 Naoto Horiguchi. All rights reserved.
//

#import "NNRootViewController.h"

#import "NNInfinityTabView.h"
#import "NNDemoTabViewItem.h"

#define NUM_OF_ITEM 7

@interface NNRootViewController ()<NNInfinityTabViewDataSource, NNInfinityTabViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_randomColors;
}

@end

@implementation NNRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _randomColors = @[].mutableCopy;
    for (int i = 0; i < NUM_OF_ITEM; i++) {
        [_randomColors addObject:[self _randomColor]];
    }
    
    NNInfinityTabView *tabView = [[NNInfinityTabView alloc] initWithFrame:self.view.bounds direction:NNInfinityTabViewDirectionVertical];
    tabView.dataSource = self;
    tabView.delegate = self;
    tabView.infinityMode = YES;
    [tabView reloadData];
    [self.view addSubview:tabView];
}

- (UIColor *)_randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
}

- (void)infinityTabView:(NNInfinityTabView *)infinityTabView didSelectItemAtIndex:(NSInteger)index
{
    //[infinityTabView deselectItemAtIndex:index animated:YES];
    [infinityTabView scrollToItemAtIndex:index atScrollPosition:NNInfinityTabViewScrollPositionNone animated:YES];
}


#pragma mark - NNInfinityTabViewDataSource

- (NNInfinityTabViewItem *)infinityTabView:(NNInfinityTabView *)infinityTabView itemAtIndex:(NSInteger)index
{
    NNDemoTabViewItem *item = [infinityTabView dequeueReusableItemWithIdentifier:@"item"];
    if (!item) {
        item = [[NNDemoTabViewItem alloc] initWithReuseIdentifier:@"item"];
    }
    item.backgroundColor = _randomColors[index];
    item.label.text = [NSString stringWithFormat:@"%ld", (long)index];
    return item;
}

- (NSInteger)numberOfItemsInInfinityTabView:(NNInfinityTabView *)infinityTabView
{
    return NUM_OF_ITEM;
}

#pragma mark - NNInfinityTabViewDelegate

- (CGSize)infinityTabView:(NNInfinityTabView *)infinityTabView sizeOfItemAtIndex:(NSInteger)index
{
    return CGSizeMake(100, 100);
}

@end
