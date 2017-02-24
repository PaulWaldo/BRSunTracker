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

    NSMutableArray <PWVector *> *vectors = [[NSMutableArray alloc] init];
    NSDate *positionDate = riseSet.sunrise;
    do {
        positionDate = [positionDate dateByAddingTimeInterval:60 * 60];
        PWVector *vector = [self sunPositionVectorForCoordinates:location date:positionDate];
        [vectors addObject:vector];
    } while ([positionDate compare:riseSet.sunset] != NSOrderedAscending);
    return vectors;
}

// Copied from BRSunTracker
+ (PWVector *)sunPositionVectorForCoordinates:(CLLocation *)location date:(NSDate *) date {
    CLLocationCoordinate2D coordinates = location.coordinate;
    PWVector *sunPositionVector = [[PWVector alloc] init];


    // Compute spherical coordinates (azimuth & elevation angle) of the sun from location, time zone, date and current time
    BRSunSphericalPosition sunPosition = [self sunPositionForCoordinate:coordinates date:date];

    // Translate the elevation angle from 'sun - Z axis(up)' to 'sun - XY axis(ground)'
    sunPosition.elevation = 90 - sunPosition.elevation;

    // Distance Earth-Sun (radius in Spherical coordinates)
    double radius = 1.0;

    // Extract cartesian coordinates from azimuth and elevation angle
    // http://computitos.files.wordpress.com/2008/03/cartesian_spherical_transformation.pdf
    sunPositionVector.value0 = [NSNumber numberWithFloat:radius * cos(DEGREES_TO_RADIANS(sunPosition.elevation))*cos(DEGREES_TO_RADIANS(sunPosition.azimuth))];
    sunPositionVector.value1 = [NSNumber numberWithFloat:radius * cos(DEGREES_TO_RADIANS(sunPosition.elevation))*sin(DEGREES_TO_RADIANS(sunPosition.azimuth))];
    sunPositionVector.value2 = [NSNumber numberWithFloat:radius * sin(DEGREES_TO_RADIANS(sunPosition.elevation))];
    sunPositionVector.value3 = [NSNumber numberWithFloat:1.0];

    // The compass/gyroscope Y axis is inverted
    sunPositionVector.value1 = [NSNumber numberWithFloat:(- sunPositionVector.value1.floatValue)];
    return sunPositionVector;
}

- (void)updateTrackingVector {
    CMRotationMatrix rotationMatrix = _motionManager.deviceMotion.attitude.rotationMatrix;

    if (!_sunPositionVectorAvailable || !_deviceOrientationVectorAvailable) return;

    // Transform the device rotation matrix to a 4D matrix
    mat4f_t cameraTransform;
    transformFromCMRotationMatrix(cameraTransform, &rotationMatrix);

    // Project the rotation matrix to the camera
    mat4f_t projectionCameraTransform;
    multiplyMatrixAndMatrix(projectionCameraTransform, _projectionTransform, cameraTransform);

    // Multiply the projected rotation matrix with the sun coordinates vector
    vec4f_t projectedSunCoordinates;
    multiplyMatrixAndVector(projectedSunCoordinates, projectionCameraTransform, _sunPositionVector);

    // Project the rotated sun coordinates on the screen
    // (z value indicates weither the sun is in front or behind)
    BRSunTrackingVector sunTrackingVector;
    sunTrackingVector.x = ((projectedSunCoordinates[0] / projectedSunCoordinates[3] + 1.0f) * 0.5f) * _viewSize.width;
    sunTrackingVector.y = _viewSize.height - _viewSize.height*((projectedSunCoordinates[1] / projectedSunCoordinates[3] + 1.0f) * 0.5f);
    sunTrackingVector.z = projectedSunCoordinates[2];

    if (_delegate && [_delegate respondsToSelector:@selector(sunTrackerVectorUpdated:)]) {
        [_delegate sunTrackerVectorUpdated:sunTrackingVector];
    }
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
