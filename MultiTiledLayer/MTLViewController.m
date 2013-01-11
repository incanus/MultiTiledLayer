//
//  MTLViewController.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLViewController.h"

#import "MTLContentView.h"

#import "RMLoadingTileView.h"

#import <QuartzCore/QuartzCore.h>

#define MTL_TILE_SIZE 128.0f

@implementation MTLViewController
{
    int _lastZoomLevel;
    MTLContentView *_contentView;
//    UIView *_backgroundView;
    RMLoadingTileView *_loadingTileView;
    CGPoint _lastContentOffset;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LoadingTileZoom.png"]];

    float boundsWidth = MTL_TILE_SIZE; //powf(2, 12);
    int zoomLevels    = 10;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.showsHorizontalScrollIndicator = scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = (id <UIScrollViewDelegate>)self;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = powf(2, zoomLevels);
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;

    _contentView = [[MTLContentView alloc] initWithFrame:CGRectMake(0, 0, boundsWidth, boundsWidth)];
    [scrollView addSubview:_contentView];
    [self.view addSubview:scrollView];
    scrollView.contentSize = _contentView.bounds.size;

//    _backgroundView = [[UIView alloc] initWithFrame:_contentView.bounds];
//    _backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LoadingTile.png"]];
//    [scrollView insertSubview:_backgroundView belowSubview:_contentView];

    _loadingTileView = [[RMLoadingTileView alloc] initWithFrame:scrollView.frame];
    [self.view insertSubview:_loadingTileView belowSubview:scrollView];

    [scrollView addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomIn:)];
    doubleTap.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTap];

    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut:)];
    twoFingerTap.numberOfTapsRequired = 1;
    twoFingerTap.numberOfTouchesRequired = 2;
    [scrollView addGestureRecognizer:twoFingerTap];

    UITapGestureRecognizer *debugTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(debugTap:)];
    [scrollView addGestureRecognizer:debugTap];

//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button setTitle:@"Reload" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
//    [button setFrame:CGRectMake(20, self.view.bounds.size.height - 20 - 40, 100, 40)];
//    [button setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
//    [self.view addSubview:button];

    _lastZoomLevel = _contentView.zoomLevel;
}

//- (void)reload:(id)sender
//{
//    for (MTLContentView *subview in [_contentView subviews])
//    {
//        [subview.layer performSelector:@selector(reload) withObject:nil];
//    }
//}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject change:(NSDictionary *)change context:(void *)context
{
    _lastContentOffset = [[anObject valueForKey:@"contentOffset"] CGPointValue];
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
    CALayer *hit = [recognizer.view.layer hitTest:[recognizer locationInView:_contentView]];

    if (hit)
    {
//        NSLog(@"%@ (%@)", hit, [NSValue valueWithCGRect:hit.frame]);

//        hit.borderColor = [[UIColor redColor] CGColor];
//        hit.borderWidth = 5;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _contentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    _loadingTileView.mapZooming = NO;

//    _backgroundView.frame = CGRectMake(scrollView.contentOffset.x - scrollView.bounds.size.width, scrollView.contentOffset.y - scrollView.bounds.size.height, scrollView.bounds.size.width * 3, scrollView.bounds.size.height * 3);
//    _backgroundView.frame = CGRectMake(scrollView.contentOffset.x * scrollView.zoomScale - scrollView.bounds.size.width,
//                                       scrollView.contentOffset.y * scrollView.zoomScale - scrollView.bounds.size.height,
//                                       _contentView.bounds.size.width  * 3 * scrollView.zoomScale,
//                                       _contentView.bounds.size.height * 3 * scrollView.zoomScale);
//    _backgroundView.hidden = NO;
//    _contentView.hidden = YES;

    //    [_contentView performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0.1];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    _backgroundView.center = scrollView.center;
//    _backgroundView.hidden = NO;
    //    [NSObject cancelPreviousPerformRequestsWithTarget:_contentView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    _backgroundView.center = scrollView.center;
//    _backgroundView.hidden = NO;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    _loadingTileView.mapZooming = YES;

//    _backgroundView.hidden = YES;

//    [NSObject cancelPreviousPerformRequestsWithTarget:_contentView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [_contentView performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0.1];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGSize delta = CGSizeMake(scrollView.contentOffset.x - _lastContentOffset.x, scrollView.contentOffset.y - _lastContentOffset.y);
    CGPoint newOffset = CGPointMake(_loadingTileView.contentOffset.x + delta.width, _loadingTileView.contentOffset.y + delta.height);
    _loadingTileView.contentOffset = newOffset;

//    _lastContentOffset = scrollView.contentOffset;

//    _backgroundView.hidden = NO;

//    NSLog(@"%@", [NSValue valueWithCGPoint:scrollView.contentOffset]);

    UIView *contentView = _contentView;

//    contentView.clearsContextBeforeDrawing = NO;

//    contentView.layer.drawsAsynchronously = YES;

//    [NSObject cancelPreviousPerformRequestsWithTarget:contentView];

//    CGRect visibleRect;
//
//    visibleRect = CGRectMake(scrollView.contentOffset.x,
//                             scrollView.contentOffset.y,
//                             scrollView.bounds.size.width,
//                             scrollView.bounds.size.height);

    [contentView performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0.1];

//    _backgroundView.frame = CGRectMake(scrollView.contentOffset.x - scrollView.bounds.size.width, scrollView.contentOffset.y - scrollView.bounds.size.height, scrollView.bounds.size.width * 3, scrollView.bounds.size.height * 3);
//    _backgroundView.frame = CGRectMake(scrollView.contentOffset.x * scrollView.zoomScale - scrollView.bounds.size.width,
//                                       scrollView.contentOffset.y * scrollView.zoomScale - scrollView.bounds.size.height,
//                                       _contentView.bounds.size.width  * 3 * scrollView.zoomScale,
//                                       _contentView.bounds.size.height * 3 * scrollView.zoomScale);
//    _backgroundView.hidden = NO;

//    NSLog(@"%@", _backgroundView);

//    [contentView setNeedsDisplay];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//    _backgroundView.hidden = YES;

    UIView *contentView = _contentView;

//    [NSObject cancelPreviousPerformRequestsWithTarget:contentView];

//    CGRect visibleRect;
//
//    visibleRect = CGRectMake(floor(scrollView.contentOffset.x    / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                             floor(scrollView.contentOffset.y    / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                             (floor(scrollView.bounds.size.width  / MTL_TILE_SIZE) + 1) * MTL_TILE_SIZE,
//                             (floor(scrollView.bounds.size.height / MTL_TILE_SIZE) + 1) * MTL_TILE_SIZE);

//    [contentView performSelector:@selector(setNeedsDisplay/*InRect:*/) withObject:nil/*[NSValue valueWithCGRect:visibleRect]*/ afterDelay:0];

//    if (((MTLContentView *)contentView).zoomLevel != _lastZoomLevel)
//    {
//        _lastZoomLevel = ((MTLContentView *)contentView).zoomLevel;
//
//        [contentView setNeedsDisplay];
//    }
}

@end