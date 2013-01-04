//
//  MTLAppDelegate.m
//  MultiTiledLayer
//
//  Created by Justin R. Miller on 1/4/13.
//  Copyright (c) 2013 MapBox. All rights reserved.
//

#import "MTLAppDelegate.h"

#import "MTLViewController.h"

@implementation MTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.window.rootViewController = [MTLViewController new];

    [self.window makeKeyAndVisible];

    return YES;
}

@end