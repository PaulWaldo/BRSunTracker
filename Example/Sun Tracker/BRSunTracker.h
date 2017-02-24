//
//  BRSunTracker.h
//  Sun Tracker
//
//  Created by Julien Ducret on 01/02/2014.
//  Copyright (c) 2014 Julien Ducret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol BRSunTrackerDelegate <NSObject>

@property (weak, nonatomic) UIViewController *viewController;

- (void)sunTrackerVectorUpdated:(BRSunTrackingVector)vector;

@end

@interface BRSunTracker : NSObject

@property (assign, nonatomic)   id<BRSunTrackerDelegate>    delegate;
@property (assign, nonatomic)   CGSize                      viewSize;
@property (strong, nonatomic)   CLLocation                  *location;

- (instancetype)initWithViewSize:(CGSize)viewSize;
- (void)stopServices;
- (void)restartServices;

@end
