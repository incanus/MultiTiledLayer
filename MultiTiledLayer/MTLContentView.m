//
//  MTLContentView.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLContentView.h"

#import <QuartzCore/QuartzCore.h>

@interface MTLTiledLayer : CATiledLayer

@end

@implementation MTLTiledLayer

+ (CFTimeInterval)fadeDuration
{
    return 0.25;
}

@end

#pragma mark -

@implementation MTLContentView

+ (Class)layerClass
{
    return [MTLTiledLayer class];
}

- (void)didMoveToWindow
{
    self.contentScaleFactor = 1;
}

- (void)setZoomLevels:(int)zoomLevels
{
    ((CATiledLayer *)self.layer).levelsOfDetail     = zoomLevels + 1;
    ((CATiledLayer *)self.layer).levelsOfDetailBias = zoomLevels + 1;
}

- (int)zoomLevels
{
    return ((CATiledLayer *)self.layer).levelsOfDetail - 1;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)c
{
    usleep(200000);

    CGRect rect = CGContextGetClipBoundingBox(c);

//    NSLog(@"%@", [NSValue valueWithCGRect:rect]);

    CGContextSetFillColorWithColor(c, [self.tileColor CGColor]);
    CGContextFillRect(c, rect);

    CGContextSetStrokeColorWithColor(c, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(c, 5);
    CGContextStrokeRect(c, rect);

    int x = rect.origin.x / ((CATiledLayer *)layer).tileSize.width;
    int y = rect.origin.y / ((CATiledLayer *)layer).tileSize.height;

    UIGraphicsPushContext(c);
    [[UIColor blackColor] set];
    [[NSString stringWithFormat:@"%i, %i", x, y] drawAtPoint:CGPointMake(rect.origin.x + 15, rect.origin.y + 15) withFont:[UIFont systemFontOfSize:24]];
    UIGraphicsPopContext();
}

@end