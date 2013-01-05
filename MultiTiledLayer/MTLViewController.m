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

    float boundsWidth = 256; //powf(2, 12);
    int zoomLevels    = 10;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.showsHorizontalScrollIndicator = scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = (id <UIScrollViewDelegate>)self;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = powf(2, zoomLevels);

    [scrollView addSubview:[[MTLContentView alloc] initWithFrame:CGRectMake(0, 0, boundsWidth, boundsWidth)]];
    [self.view addSubview:scrollView];
    scrollView.contentSize = ((UIView *)[scrollView.subviews objectAtIndex:0]).bounds.size;

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomIn:)];
    doubleTap.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTap];

    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut:)];
    twoFingerTap.numberOfTapsRequired = 1;
    twoFingerTap.numberOfTouchesRequired = 2;
    [scrollView addGestureRecognizer:twoFingerTap];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Reload" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(20, self.view.bounds.size.height - 20 - 40, 100, 40)];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:button];
}

- (void)reload:(id)sender
{
//    for (MTLContentView *subview in [[self.view.subviews objectAtIndex:0] subviews])
//    {
//        subview.layer.contents = nil;
//        [subview.layer setNeedsDisplay];
//    }
}

- (void)zoomIn:(UIGestureRecognizer *)recognizer
{
    UIScrollView *scrollView = ((UIScrollView *)recognizer.view);

    [scrollView setZoomScale:powf(2, log2f(scrollView.zoomScale) + 1) animated:YES];
}

- (void)zoomOut:(UIGestureRecognizer *)recognizer
{
    UIScrollView *scrollView = ((UIScrollView *)recognizer.view);

    [scrollView setZoomScale:powf(2, log2f(scrollView.zoomScale) - 1) animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

@end