//
//  RouteViewControllerDelegate.h
//  MK Waypoints
//
//  Created by Frank Blumenberg on 11.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MKTRouteViewControllerChild <NSObject>

@end

@protocol MKTRouteViewControllerDelegate <NSObject>

- (void)controllerDidChangeToolbar:(UIViewController *)controller;

@end

