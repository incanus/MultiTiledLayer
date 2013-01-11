//
//  MTLTileLayer.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/8/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLTileLayer.h"

#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

//@interface MTLLayer : CALayer
//
//@property (nonatomic, strong) NSMutableDictionary *memoryCache;
//
//@end

typedef struct {
	int x, y, z;
} MTLKey;

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
//    fadein.duration = 0.5;
//    fadein.type = kCATransitionFade;
//    [customActions setObject:fadein forKey:@"contents"];
//
//    self.actions=customActions;

    [self enableFade:NO];

//    NSLog(@"%@", self.actions);

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
//    {
//        usleep(100000);
//
//        dispatch_async(dispatch_get_main_queue(), ^(void)
//        {
////            self.contents = (id)[[UIImage imageNamed:@"tile.png"] CGImage];
            [self setNeedsDisplay];
//    [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.1];

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

- (void)enableFade:(BOOL)flag
{
    NSMutableDictionary *customActions=[NSMutableDictionary dictionaryWithDictionary:[self actions]];

    [customActions setObject:[NSNull null] forKey:@"position"];
    [customActions setObject:[NSNull null] forKey:@"bounds"];
    [customActions setObject:[NSNull null] forKey:kCAOnOrderOut];
    [customActions setObject:[NSNull null] forKey:kCAOnOrderIn];

    if (flag)
    {
        CATransition *fadein = [[CATransition alloc] init];
        fadein.duration = 0.5;
        fadein.type = kCATransitionFade;
        [customActions setObject:fadein forKey:@"contents"];
    }
    else
    {
        [customActions setObject:[NSNull null] forKey:@"contents"];
    }

    self.actions=customActions;
}

- (void)setTouchDate:(NSDate *)touchDate
{
//    NSLog(@"touching %@", self);

    _touchDate = touchDate;
}

- (NSData *)tileDataForKey:(MTLKey)key
{
    __block NSData *data = nil;

    [self.dbQueue inDatabase:^(FMDatabase *db)
    {
        FMResultSet *results = [db executeQueryWithFormat:@"select data from tiles where x = %i and y = %i and z = %i", key.x, key.y, key.z];

        if ([results next])
            data = [results objectForColumnName:@"data"];

        [results close];
    }];
    
    return data;
}

- (NSData *)fragmentDataForKey:(MTLKey)key
{
    __block NSData *data = nil;

    [self.dbQueue inDatabase:^(FMDatabase *db)
    {
        FMResultSet *results = [db executeQueryWithFormat:@"select data from fragments where x = %i and y = %i and z = %i", key.x, key.y, key.z];

        if ([results next])
            data = [results objectForColumnName:@"data"];

        [results close];
    }];

    return data;
}

- (void)storeTileData:(NSData *)data forKey:(MTLKey)key
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
    {
        [db executeUpdateWithFormat:@"replace into tiles (x, y, z, data) values (%i, %i, %i, %@)", key.x, key.y, key.z, data];
    }];
}

- (void)storeFragmentData:(NSData *)data forKey:(MTLKey)key
{
    [self.dbQueue inDatabase:^(FMDatabase *db)
    {
        [db executeUpdate:@"insert into fragments (x, y, z, data) values (%i, %i, %i, %@)", key.x, key.y, key.z, data];
    }];
}

- (void)display
{
//    NSLog(@"%@", self.dbQueue);

//    NSLog(@"display for %@", [NSValue valueWithCGRect:self.frame]);

    int tileZ = (int)[[self.superlayer.delegate valueForKey:@"zoomLevel"] floatValue];
    int tileX = (int)floor(self.frame.origin.x / self.bounds.size.width);
    int tileY = (int)floor(self.frame.origin.y / self.bounds.size.height);

//    NSLog(@"%i, %i, %i", tileZ, tileX, tileY);

    __block UIImage *tileImage = nil;

    __block BOOL isFinal = NO;

//    NSString *tileKey = [NSString stringWithFormat:@"%i_%i_%i", tileZ, tileX, tileY];

    MTLKey tileKey = {
        .x = tileX,
        .y = tileY,
        .z = tileZ,
    };

//    NSString *cachePath = [NSString stringWithFormat:@"%@/%@.png", NSTemporaryDirectory(), tileKey];
//    NSString *tmpPath   = [cachePath stringByReplacingOccurrencesOfString:@".png" withString:@"_tmp.png"];

//    NSMutableDictionary *memoryCache = ((MTLLayer *)self.superlayer).memoryCache;

    if ( /*(tileImage = [UIImage imageWithData:[memoryCache objectForKey:tileKey]]))*/ (tileImage = [UIImage imageWithData:[self tileDataForKey:tileKey]])) // [UIImage imageWithContentsOfFile:cachePath])) // [[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
//        tileImage = [UIImage imageWithContentsOfFile:cachePath];
        [self enableFade:YES];
        isFinal = YES;
    }
    else if ( /*(tileImage = [UIImage imageWithData:[memoryCache objectForKey:[tileKey stringByAppendingString:@"_tmp"]]]))*/ (tileImage = [UIImage imageWithData:[self fragmentDataForKey:tileKey]])) // (tileImage = [UIImage imageWithContentsOfFile:tmpPath])) // [[NSFileManager defaultManager] fileExistsAtPath:tmpPath])
    {
//        tileImage = [UIImage imageWithContentsOfFile:tmpPath];
        [self enableFade:NO];
    }
    else
    {
        NSString *tileURLString = [NSString stringWithFormat:@"http://a.tiles.mapbox.com/v3/examples.map-2k9d7u0c/%i/%i/%i.png", tileZ, tileX, tileY];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
        {
            NSData *tileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tileURLString]];

//            [tileData writeToFile:cachePath atomically:YES];

            [self storeTileData:tileData forKey:tileKey];

//            dispatch_sync(dispatch_get_main_queue(), ^(void)
//            {
//                [memoryCache setObject:tileData forKey:tileKey];
//            });

//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
//            });

            dispatch_sync(dispatch_get_main_queue(), ^(void)
            {
                [self enableFade:YES];
//
                if (self.superlayer)
                    self.contents = (id)[[UIImage imageWithData:tileData] CGImage];

                isFinal = YES;

//                [NSObject cancelPreviousPerformRequestsWithTarget:self];

//                if (self.superlayer)
//                    [self.superlayer setNeedsDisplayInRect:self.frame];

//                NSLog(@"%@", ((MTLLayer *)self.superlayer).memoryCache);
            });
        });

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void)
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

//                NSString *cachePath = [NSString stringWithFormat:@"%@/%i_%i_%i.png", NSTemporaryDirectory(), currentZoom, (int)nextTileX, (int)nextTileY];

//                NSLog(@"need %i, %i, %i - looking at %i, %f, %f", zoom, x, y, currentZoom, nextTileX, nextTileY);

//                if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
//                    tileImage = [UIImage imageWithContentsOfFile:cachePath];
                tileImage = [UIImage imageWithData:[self tileDataForKey:tileKey]];

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

                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
                    {
                        NSData *tileData = UIImagePNGRepresentation(tileImage);
//                        [tileData writeToFile:tmpPath atomically:YES];
                        [self storeFragmentData:tileData forKey:tileKey];

//                        dispatch_sync(dispatch_get_main_queue(), ^(void)
//                        {
//                            [memoryCache setObject:tileData forKey:[tileKey stringByAppendingString:@"_tmp"]];
//                        });
                    });

                    break;
                }
                else
                {
                    //                tileImage = [UIImage imageNamed:@"tile.png"];
                }
                
                currentTileDepth++;
                currentZoom = zoom - currentTileDepth;
            }

            if (tileImage && ! isFinal)
            {
                dispatch_sync(dispatch_get_main_queue(), ^(void)
                {
                    [self enableFade:NO];

                    if (self.superlayer)
                        self.contents = (id)[tileImage CGImage];

//                    [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:1.0];

//                    if (self.superlayer)
//                        [self.superlayer setNeedsDisplayInRect:self.frame];
                });
            }
        });
    }

    if ( ! tileImage)
        return;
//        tileImage = [UIImage imageNamed:@"grid.png"];

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