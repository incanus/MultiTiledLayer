//
//  MTLContentView.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLContentView.h"

#import "MTLTileLayer.h"

#import <QuartzCore/QuartzCore.h>

#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

#define MTL_TILE_SIZE 128.0f

@interface MTLLayer : CALayer

//@property (nonatomic, strong) NSMutableDictionary *memoryCache;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation MTLLayer

- (id)init
{
    self = [super init];

//    self.memoryCache = [NSMutableDictionary dictionary];

    NSString *path = [NSString stringWithFormat:@"%@/cache.db", NSTemporaryDirectory()];

    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"cache" ofType:@"db"] toPath:path error:nil];

    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];

//    NSLog(@"%@", path);

    return self;
}

//- (void)reload
//{
//    [self.dbQueue inDatabase:^(FMDatabase *db)
//    {
//        [db executeUpdate:@"delete from tiles"];
//        [db executeUpdate:@"delete from fragments"];
//        self.contents = nil;
//        [self setNeedsDisplay];
//    }];
//}

- (void)dealloc
{
    [self.dbQueue close];
}

- (void)display
{
    CGRect visibleRect = CGRectIntersection([self.delegate visibleRect], self.bounds);

    if ( ! CGRectIntersectsRect(visibleRect, self.bounds))
        return;

//    NSLog(@"zoom %i display for %@", ((MTLContentView *)self.delegate).zoomLevel, [NSValue valueWithCGRect:visibleRect]);

    visibleRect = CGRectMake(floor(visibleRect.origin.x / MTL_TILE_SIZE)   * MTL_TILE_SIZE,
                             floor(visibleRect.origin.y / MTL_TILE_SIZE)   * MTL_TILE_SIZE,
                             ceil(visibleRect.size.width  / MTL_TILE_SIZE) * MTL_TILE_SIZE,
                             ceil(visibleRect.size.height / MTL_TILE_SIZE) * MTL_TILE_SIZE);

//    [self.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    for (int x = visibleRect.origin.x; x < visibleRect.origin.x + visibleRect.size.width; x += MTL_TILE_SIZE)
    {
        for (int y = visibleRect.origin.y; y < visibleRect.origin.y + visibleRect.size.height; y += MTL_TILE_SIZE)
        {
            CGRect rect = CGRectMake(x, y, MTL_TILE_SIZE, MTL_TILE_SIZE);

            for (MTLTileLayer *existingSublayer in self.sublayers)
            {
                if (CGRectEqualToRect(existingSublayer.frame, rect))
                {
                    existingSublayer.touchDate = [NSDate date];
                    continue;
                }
            }

//            CALayer *hit = [self hitTest:CGPointMake(x, y)];
//
//            if ( ! [hit isKindOfClass:[MTLTileLayer class]])
//            {
//                NSLog(@"=== adding %i, %i", x, y);

                MTLTileLayer *sublayer = [MTLTileLayer layer];

//                sublayer.anchorPoint = CGPointMake(0, 0);
                sublayer.frame = CGRectMake(x, y, MTL_TILE_SIZE, MTL_TILE_SIZE);

                sublayer.dbQueue = self.dbQueue;

//                NSLog(@"=== adding %@", [NSValue valueWithCGRect:sublayer.frame]);

//                sublayer.needsDisplayOnBoundsChange = YES;

                [self addSublayer:sublayer];

//                NSLog(@"=== sublayer count: %i", [self.sublayers count]);
//            }
//            else
//            {
//                NSLog(@"=== skipping %i, %i", x, y);
//
////                [hit setNeedsDisplay];
//
//                [hit displayIfNeeded];
//            }
        }
    }
}

@end

#pragma mark -

@implementation MTLContentView

+ (Class)layerClass
{
    return [MTLLayer class];
}

- (void)didMoveToWindow
{
//    self.layer.contentsScale = 1;
//    self.clearsContextBeforeDrawing = NO;
}

- (void)drawRect:(CGRect)rect
{
    // no-op
}

- (CGRect)visibleRect
{
//    return self.layer.visibleRect;

    UIScrollView *scrollView = (UIScrollView *)self.superview;

//    NSLog(@"%f", scrollView.zoomScale);

//    return CGRectMake(floor(scrollView.contentOffset.x   / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                      floor(scrollView.contentOffset.y   / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                      ceil(scrollView.bounds.size.width  / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                      ceil(scrollView.bounds.size.height / MTL_TILE_SIZE) * MTL_TILE_SIZE);

    return CGRectMake(scrollView.contentOffset.x    / scrollView.zoomScale,
                      scrollView.contentOffset.y    / scrollView.zoomScale,
                      scrollView.bounds.size.width  / scrollView.zoomScale,
                      scrollView.bounds.size.height / scrollView.zoomScale);


//    CGRect visibleRect;
//    visibleRect.origin = scrollView.contentOffset;
//    visibleRect.size = scrollView.bounds.size;
//
//    float theScale = 1.0 / scrollView.zoomScale;
//    visibleRect.origin.x *= theScale;
//    visibleRect.origin.y *= theScale;
//    visibleRect.size.width *= theScale;
//    visibleRect.size.height *= theScale;
//
//    visibleRect = CGRectMake(floor(visibleRect.origin.x / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                             floor(visibleRect.origin.y / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                             ceil(visibleRect.size.width / MTL_TILE_SIZE) * MTL_TILE_SIZE,
//                             ceil(visibleRect.size.height / MTL_TILE_SIZE) * MTL_TILE_SIZE);
//
//
//
//
//    return visibleRect;
}

- (void)setBounds:(CGRect)bounds
{
    super.bounds = bounds;

//    NSLog(@"bounds now %@", [NSValue valueWithCGRect:bounds]);
}

- (void)cleanupTiles
{
//    return;
//    NSLog(@"=== entering cleanup with %i tiles", [self.layer.sublayers count]);

//    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//
//    return;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
    {
        NSArray *layers = [self.layer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.touchDate < %@", [NSDate dateWithTimeIntervalSinceNow:-15]]];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

//            NSLog(@"=== leaving cleanup with %i tiles", [self.layer.sublayers count]);
        });
    });
}

- (void)setTransform:(CGAffineTransform)transform
{
    float newZoomScale = transform.a;

    if (newZoomScale > 2 && self.bounds.size.width < (MTL_TILE_SIZE * powf(2, self.zoomLevel + 1)) && self.zoomLevel < 17)
    {
        [super setTransform:CGAffineTransformIdentity];

        ((UIScrollView *)self.superview).zoomScale = 1;

        self.zoomLevel++;

//        [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

        [self cleanupTiles];

        float newEdge = MTL_TILE_SIZE * powf(2, self.zoomLevel);

        self.bounds = CGRectMake(0, 0, newEdge, newEdge);

//        [self.layer setNeedsDisplayInRect:[self visibleRect]];
//        [self.layer performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0];
    }
    else if (newZoomScale < 1 && self.bounds.size.width > (MTL_TILE_SIZE * powf(2, self.zoomLevel - 1)) && self.zoomLevel > 0)
    {
        [super setTransform:CGAffineTransformIdentity];

        ((UIScrollView *)self.superview).zoomScale = 2;

        self.zoomLevel--;

//        [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

        [self cleanupTiles];

        float newEdge = MTL_TILE_SIZE * powf(2, self.zoomLevel);

        self.bounds = CGRectMake(0, 0, newEdge, newEdge);
        
//        [self.layer setNeedsDisplayInRect:[self visibleRect]];
//        [self.layer performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0];
    }
    else
    {
        [super setTransform:transform];

//        NSLog(@"scale: %f", newZoomScale);
    }
}

@end