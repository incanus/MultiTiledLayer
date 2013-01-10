//
//  MTLTileLayer.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/8/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLTileLayer.h"

@implementation MTLTileLayer

- (id)init
{
    self = [super init];

    self.drawsAsynchronously = NO;

//    NSMutableDictionary *customActions=[NSMutableDictionary dictionaryWithDictionary:[self actions]];
//
//    [customActions setObject:[NSNull null] forKey:@"position"];
//    [customActions setObject:[NSNull null] forKey:@"bounds"];
//    [customActions setObject:[NSNull null] forKey:kCAOnOrderOut];
//    [customActions setObject:[NSNull null] forKey:kCAOnOrderIn];
//
//    CATransition *fadein = [[CATransition alloc] init];
//    fadein.duration = 0.3;
//    fadein.type = kCATransitionReveal;
//    [customActions setObject:fadein forKey:@"contents"];
//
//    self.actions=customActions;

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
//    {
//        usleep(100000);
//
//        dispatch_async(dispatch_get_main_queue(), ^(void)
//        {
////            self.contents = (id)[[UIImage imageNamed:@"tile.png"] CGImage];
            [self setNeedsDisplay];

//        });
//    });

//    [self setNeedsDisplay];

//    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];

    return self;
}

//- (void)drawInContext:(CGContextRef)c
//{
//
//}

- (NSString *)description
{
    return [NSString stringWithFormat:@"tile at %f, %f", self.frame.origin.x, self.frame.origin.y];
}

- (void)display
{
//    NSLog(@"display for %@", [NSValue valueWithCGRect:self.frame]);

    int tileZ = (int)[[self.superlayer.delegate valueForKey:@"zoomLevel"] floatValue];
    int tileX = (int)floor(self.frame.origin.x / self.bounds.size.width);
    int tileY = (int)floor(self.frame.origin.y / self.bounds.size.height);

//    NSLog(@"%i, %i, %i", tileZ, tileX, tileY);

    __block UIImage *tileImage = nil;

    NSString *cachePath = [NSString stringWithFormat:@"%@/%i_%i_%i.png", NSTemporaryDirectory(), tileZ, tileX, tileY];

    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        tileImage = [UIImage imageWithContentsOfFile:cachePath];
    }
    else
    {
        NSString *tileURLString = [NSString stringWithFormat:@"http://a.tiles.mapbox.com/v3/examples.map-z2effxa8/%i/%i/%i.png", tileZ, tileX, tileY];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
        {
            NSData *tileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tileURLString]];

            [tileData writeToFile:cachePath atomically:NO];

            dispatch_sync(dispatch_get_main_queue(), ^(void)
            {
                self.contents = (id)[[UIImage imageWithData:tileData] CGImage];
            });
        });

        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
        {
            int zoom = tileZ;
            int x    = tileX;
            int y    = tileY;

            NSInteger currentTileDepth = 1, currentZoom = zoom - currentTileDepth;

            while ( ! tileImage && currentZoom >= 0)
            {
                float nextX = x / powf(2.0, (float)currentTileDepth),
                nextY = y / powf(2.0, (float)currentTileDepth);
                float nextTileX = floor(nextX),
                nextTileY = floor(nextY);

                NSString *cachePath = [NSString stringWithFormat:@"%@/%i_%i_%i.png", NSTemporaryDirectory(), zoom, x, y];

                if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
                    tileImage = [UIImage imageWithContentsOfFile:cachePath];

                if (tileImage)
                {
                    float cropSize = 1.0 / powf(2.0, (float)currentTileDepth);

                    CGRect cropBounds = CGRectMake(tileImage.size.width * (nextX - nextTileX),
                                                   tileImage.size.height * (nextY - nextTileY),
                                                   tileImage.size.width * cropSize,
                                                   tileImage.size.height * cropSize);

                    CGImageRef imageRef = CGImageCreateWithImageInRect([tileImage CGImage], cropBounds);
                    tileImage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);

                    break;
                }
                else
                {
                    //                tileImage = [UIImage imageNamed:@"tile.png"];
                }
                
                currentTileDepth++;
                currentZoom = zoom - currentTileDepth;
            }
        });

//        tileImage = [UIImage imageNamed:@"tile.png"];
    }

    if ( ! tileImage)
        return;

    self.contents = (id)[tileImage CGImage];

//    UIGraphicsBeginImageContext(self.bounds.size);
//    UIGraphicsPushContext(UIGraphicsGetCurrentContext());
//    [tileImage drawInRect:self.bounds];
////    [[NSString stringWithFormat:@"%i, %i, %i", tileZ, tileX, tileY] drawAtPoint:CGPointMake(10, 10) withFont:[UIFont systemFontOfSize:24]];
//    UIGraphicsPopContext();
//    self.contents = (id)[UIGraphicsGetImageFromCurrentImageContext() CGImage];
//    UIGraphicsEndImageContext();
}

@end