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

@property (strong, nonatomic) NSNumber *value0;
@property (strong, nonatomic) NSNumber *value1;
@property (strong, nonatomic) NSNumber *value2;
@property (strong, nonatomic) NSNumber *value3;

@end

@interface PWAstronomicalPositions : NSObject

+ (NSArray <PWVector *> *)createpositionsForDate:(NSDate *) date
                                        location: (CLLocation *) location;

@end
