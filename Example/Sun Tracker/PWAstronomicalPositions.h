//
//  PWAstronomicalPositions.h
//  Sun Tracker
//
//  Created by Paul Waldo on 2/21/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "BRGeometry.h"

@interface PWVector : NSObject

@property (strong, nonatomic) NSArray <NSNumber *> *values;

@end

@interface PWAstronomicalPositions : NSObject

+ (NSArray <PWVector *> *)createpositionsForDate:(NSDate *) date
                                        location: (CLLocation *) location;

@end
