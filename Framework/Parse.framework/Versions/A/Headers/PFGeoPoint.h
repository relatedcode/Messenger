//
//  PFGeoPoint.h
//  Parse
//
//  Created by Henele Adams on 12/1/11.
//  Copyright (c) 2011 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/*!
 Object which may be used to embed a latitude / longitude point as the value for a key in a PFObject.
 PFObjects with a PFGeoPoint field may be queried in a geospatial manner using PFQuery's whereKey:nearGeoPoint:.
 
 This is also used as a point specifier for whereKey:nearGeoPoint: queries.
 
 Currently, object classes may only have one key associated with a GeoPoint type.
 */

@interface PFGeoPoint : NSObject <NSCopying, NSCoding>

/** @name Creating a PFGeoPoint */
/*!
 Create a PFGeoPoint object.  Latitude and longitude are set to 0.0.
 @result Returns a new PFGeoPoint.
 */
+ (PFGeoPoint *)geoPoint;

/*!
 Creates a new PFGeoPoint object for the given CLLocation, set to the location's
 coordinates.
 @param location CLLocation object, with set latitude and longitude.
 @result Returns a new PFGeoPoint at specified location.
 */
+ (PFGeoPoint *)geoPointWithLocation:(CLLocation *)location;

/*!
 Creates a new PFGeoPoint object with the specified latitude and longitude.
 @param latitude Latitude of point in degrees.
 @param longitude Longitude of point in degrees.
 @result New point object with specified latitude and longitude.
 */
+ (PFGeoPoint *)geoPointWithLatitude:(double)latitude longitude:(double)longitude;

/*!
 Fetches the user's current location and returns a new PFGeoPoint object via the
 provided block.
 @param geoPointHandler A block which takes the newly created PFGeoPoint as an
 argument.
 */
+ (void)geoPointForCurrentLocationInBackground:(void(^)(PFGeoPoint *geoPoint, NSError *error))geoPointHandler;

/** @name Controlling Position */

/// Latitude of point in degrees.  Valid range (-90.0, 90.0).
@property (nonatomic, assign) double latitude;
/// Longitude of point in degrees.  Valid range (-180.0, 180.0).
@property (nonatomic, assign) double longitude;

/** @name Calculating Distance */

/*!
 Get distance in radians from this point to specified point.
 @param point PFGeoPoint location of other point.
 @result distance in radians
 */
- (double)distanceInRadiansTo:(PFGeoPoint*)point;

/*!
 Get distance in miles from this point to specified point.
 @param point PFGeoPoint location of other point.
 @result distance in miles
 */
- (double)distanceInMilesTo:(PFGeoPoint*)point;

/*!
 Get distance in kilometers from this point to specified point.
 @param point PFGeoPoint location of other point.
 @result distance in kilometers
 */
- (double)distanceInKilometersTo:(PFGeoPoint*)point;

@end
