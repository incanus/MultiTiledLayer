//
//  MTLViewController.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLViewController.h"

#import "MTLContentView.h"

#import <QuartzCore/QuartzCore.h>

@implementation MTLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];

    float boundsWidth = 1024; //powf(2, 12);
    int subviewCount  = 4;
    int zoomLevels    = 10;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.showsHorizontalScrollIndicator = scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = (id <UIScrollViewDelegate>)self;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = powf(2, zoomLevels);

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boundsWidth, boundsWidth)];
    containerView.backgroundColor = [UIColor clearColor];

    NSArray *colors = @[@"red", @"blue", @"green", @"yellow", @"orange", @"cyan", @"magenta", @"white", @"purple"];

    for (int x = 0; x < sqrt(subviewCount); x++)
    {
        for (int y = 0; y < sqrt(subviewCount); y++)
        {
            float size = boundsWidth / sqrt(subviewCount);

            MTLContentView *contentView = [[MTLContentView alloc] initWithFrame:CGRectMake(x * size, y * size, size, size)];

            static int colorIndex = 0;

            contentView.tileColor  = [[UIColor class] performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@Color", [colors objectAtIndex:colorIndex]])];
            contentView.zoomLevels = zoomLevels;

            [containerView addSubview:contentView];

            colorIndex++;
        }
    }

    scrollView.contentSize = containerView.bounds.size;
    [scrollView addSubview:containerView];
    [self.view addSubview:scrollView];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Reload" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(20, self.view.bounds.size.height - 20 - 40, 100, 40)];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:button];
}

- (void)reload:(id)sender
{
    for (MTLContentView *subview in [[[[self.view.subviews objectAtIndex:0] subviews] objectAtIndex:0] subviews])
    {
        subview.layer.contents = nil;
        [subview.layer setNeedsDisplay];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

@end