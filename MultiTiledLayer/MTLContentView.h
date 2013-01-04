//
//  MTLContentView.h
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTLContentView : UIView

@property (nonatomic, strong) UIColor *tileColor;
@property (nonatomic, assign) int zoomLevels;

@end