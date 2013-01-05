//
//  MTLContentView.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLContentView.h"

@implementation MTLContentView

- (void)drawRect:(CGRect)rect
{
//    NSLog(@"redraw at %i", self.zoomLevel);

    int zoom = 0; //log2(self.superview.transform.a);

    int virtualTileSize = 256 / powf(2, zoom);

    for (int x = 0; x < rect.size.width / virtualTileSize; x++)
    {
        for (int y = 0; y < rect.size.height / virtualTileSize; y++)
        {
            CGRect subrect = CGRectMake(x * virtualTileSize, y * virtualTileSize, virtualTileSize, virtualTileSize);

            CGContextRef c = UIGraphicsGetCurrentContext();

            [[UIImage imageNamed:@"tile.png"] drawInRect:subrect];

            CGContextSetStrokeColorWithColor(c, [[UIColor blackColor] CGColor]);
            CGContextSetLineWidth(c, 5 / (zoom + 1));
            CGContextStrokeRect(c, subrect);
        }
    }
}

- (void)setTransform:(CGAffineTransform)transform
{
    int oldZoomScale = floor(self.transform.a);
    int newZoomScale = floor(transform.a);

    NSLog(@"%i -> %i", oldZoomScale, newZoomScale);

    [super setTransform:transform];

    if (newZoomScale != oldZoomScale)
    {
        [super setTransform:CGAffineTransformIdentity];

        self.zoomLevel = (newZoomScale >= 1 ? log2(newZoomScale) : 0);

        float newEdge = 256 * powf(2, self.zoomLevel);

        self.bounds = CGRectMake(0, 0, newEdge, newEdge);

        [self setNeedsDisplay];
    }
}

@end