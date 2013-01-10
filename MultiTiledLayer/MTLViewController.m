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

#define MTL_TILE_SIZE 256.0f

@implementation MTLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];

    float boundsWidth = MTL_TILE_SIZE; //powf(2, 12);
    int zoomLevels    = 10;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.showsHorizontalScrollIndicator = scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = (id <UIScrollViewDelegate>)self;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = powf(2, zoomLevels);
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;

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

    UITapGestureRecognizer *debugTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(debugTap:)];
    [scrollView addGestureRecognizer:debugTap];

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

- (void)debugTap:(UIGestureRecognizer *)recognizer
{
    CALayer *hit = [recognizer.view.layer hitTest:[recognizer locationInView:[recognizer.view.subviews objectAtIndex:0]]];

    if (hit)
    {
//        NSLog(@"%@ (%@)", hit, [NSValue valueWithCGRect:hit.frame]);

//        hit.borderColor = [[UIColor redColor] CGColor];
//        hit.borderWidth = 5;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [[scrollView.subviews objectAtIndex:0] performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0.1];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:[scrollView.subviews objectAtIndex:0]];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:[scrollView.subviews objectAtIndex:0]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [[scrollView.subviews objectAtIndex:0] performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0.1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%@", [NSValue valueWithCGPoint:scrollView.contentOffset]);

    UIView *contentView = [scrollView.subviews objectAtIndex:0];

//    contentView.clearsContextBeforeDrawing = NO;

//    contentView.layer.drawsAsynchronously = YES;

    [NSObject cancelPreviousPerformRequestsWithTarget:contentView];

//    CGRect visibleRect;
//
//    visibleRect = CGRectMake(scrollView.contentOffset.x,
//                             scrollView.contentOffset.y,
//                             scrollView.bounds.size.width,
//                             scrollView.bounds.size.height);

    [contentView performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0.1];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *contentView = [scrollView.subviews objectAtIndex:0];

    [NSObject cancelPreviousPerformRequestsWithTarget:contentView];

//    CGRect visibleRect;
//
//    visibleRect = CGRectMake(floor(scrollView.contentOffset.x    / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                             floor(scrollView.contentOffset.y    / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                             (floor(scrollView.bounds.size.width  / MTL_TILE_SIZE) + 1) * MTL_TILE_SIZE,
//                             (floor(scrollView.bounds.size.height / MTL_TILE_SIZE) + 1) * MTL_TILE_SIZE);

//    [contentView performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0.1];
}

@end