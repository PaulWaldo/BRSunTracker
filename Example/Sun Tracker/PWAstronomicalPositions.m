//
//  PWAstronomicalPositions.m
//  Sun Tracker
//
//  Created by Paul Waldo on 2/21/17.
//
//

#import "PWAstronomicalPositions.h"
#import "PSAOCHeader.h"
#import "erndev-EDSunriseSet-029425b/EDSunriseSet.h"

@implementation PWAstronomicalPositions

+ (NSArray <PWVector *> *)createpositionsForDate:(NSDate *)date
                                        location:(CLLocation *)location {
    // Find out when sunrise and sunset occurs
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    EDSunriseSet *riseSet = [EDSunriseSet sunrisesetWithTimezone:localTime
                                                        latitude:location.coordinate.latitude
                                                       longitude:location.coordinate.longitude];
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *sunrise = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:riseSet.sunrise];
//    NSDateComponents *sunset = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:riseSet.sunrise];

    NSArray <PWVector *> *vectors = [[NSMutableArray alloc] init];
    NSDate *positionDate = riseSet.sunrise;
    do {
        positionDate = [positionDate dateByAddingTimeInterval:60 * 60];
    } while ([positionDate compare:riseSet.sunset] != NSOrderedAscending);
}

// Copied from BRSunTracker
+ (void)sunPositionVectorForCoordinates:(CLLocation *)location date:(NSDate *) date result:(vec4f_t**) result {
    CLLocationCoordinate2D coordinates = location.coordinate;
    vec4f_t *sunPositionVector = *result;


    // Compute spherical coordinates (azimuth & elevation angle) of the sun from location, time zone, date and current time
    BRSunSphericalPosition sunPosition = [self sunPositionForCoordinate:coordinates date:date];

    // Translate the elevation angle from 'sun - Z axis(up)' to 'sun - XY axis(ground)'
    sunPosition.elevation = 90 - sunPosition.elevation;

    // Distance Earth-Sun (radius in Spherical coordinates)
    double radius = 1.0;

    // Extract cartesian coordinates from azimuth and elevation angle
    // http://computitos.files.wordpress.com/2008/03/cartesian_spherical_transformation.pdf
    *sunPositionVector[0] = radius * cos(DEGREES_TO_RADIANS(sunPosition.elevation))*cos(DEGREES_TO_RADIANS(sunPosition.azimuth));
    *sunPositionVector[1] = radius * cos(DEGREES_TO_RADIANS(sunPosition.elevation))*sin(DEGREES_TO_RADIANS(sunPosition.azimuth));
    *sunPositionVector[2] = radius * sin(DEGREES_TO_RADIANS(sunPosition.elevation));
    *sunPositionVector[3] = 1.0;

    // The compass/gyroscope Y axis is inverted
    *sunPositionVector[1] = - *sunPositionVector[1];
}

+ (BRSunSphericalPosition)sunPositionForCoordinate:(CLLocationCoordinate2D)coordinate date:(NSDate *) date {
    PSAOCAzimuthZenithAngle *result = [PSAOCPSA computeSolarPositionWithDate:date
                                                                    latitude:coordinate.latitude
                                                                   longitude:coordinate.longitude];
    BRSunSphericalPosition sunCoordinates;
    sunCoordinates.azimuth = [result azimuth];
    sunCoordinates.elevation = [result zenithAngle];

    return sunCoordinates;
    
}
@end
