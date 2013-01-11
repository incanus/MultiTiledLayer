//
//  MTLTileLayer.h
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/8/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class FMDatabaseQueue;

@interface MTLTileLayer : CALayer

@property (nonatomic, strong) NSDate *touchDate;
@property (nonatomic, assign) FMDatabaseQueue *dbQueue;

@end