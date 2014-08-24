//
//  PFSubclassing.h
//  Parse
//
//  Created by Thomas Bouldin on 3/11/13.
//  Copyright (c) 2013 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFQuery;

/*!
 If a subclass of PFObject conforms to PFSubclassing and calls registerSubclass, Parse will be able to use that class as the native class for a Parse cloud object.
 
 Classes conforming to this protocol should subclass PFObject and include PFObject+Subclass.h in their implementation file. This ensures the methods in the Subclass category of PFObject are exposed in its subclasses only.
 */
@protocol PFSubclassing

/*!
 Constructs an object of the most specific class known to implement parseClassName.
 This method takes care to help PFObject subclasses be subclassed themselves.
 For example, [PFUser object] returns a PFUser by default but will return an
 object of a registered subclass instead if one is known.
 A default implementation is provided by PFObject which should always be sufficient.
 @result Returns the object that is instantiated.
 */
+ (instancetype)object;

/*!
 Creates a reference to an existing PFObject for use in creating associations between PFObjects.  Calling isDataAvailable on this
 object will return NO until fetchIfNeeded or refresh has been called.  No network request will be made.
 A default implementation is provided by PFObject which should always be sufficient.
 @param objectId The object id for the referenced object.
 @result A PFObject without data.
 */
+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId;
  
/*! The name of the class as seen in the REST API. */
+ (NSString *)parseClassName;

/*!
 Create a query which returns objects of this type.
 A default implementation is provided by PFObject which should always be sufficient.
 */
+ (PFQuery *)query;

/*!
 Lets Parse know this class should be used to instantiate all objects with class type parseClassName.
 This method must be called before [Parse setApplicationId:clientKey:]
 */
+ (void)registerSubclass;

@end
