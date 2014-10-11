//
//  PFObject+Subclass.h
//  Parse
//
//  Created by Thomas Bouldin on 2/17/13.
//  Copyright (c) 2013 Parse Inc. All rights reserved.
//

#import "PFObject.h"

@class PFQuery;

/*!
 <h3>Subclassing Notes</h3>
 
 Developers can subclass PFObject for a more native object-oriented class structure. Strongly-typed subclasses of PFObject must conform to the PFSubclassing protocol and must call registerSubclass to be returned by PFQuery and other PFObject factories. All methods in PFSubclassing except for [PFSubclassing parseClassName] are already implemented in the PFObject(Subclass) category. Inculding PFObject+Subclass.h in your implementation file provides these implementations automatically.
 
 Subclasses support simpler initializers, query syntax, and dynamic synthesizers. The following shows an example subclass:
 
     @interface MYGame : PFObject< PFSubclassing >
     // Accessing this property is the same as objectForKey:@"title"
     @property (strong) NSString *title;
     + (NSString *)parseClassName;
     @end
     
     @implementation MYGame
     @dynamic title;
     + (NSString *)parseClassName {
         return @"Game";
     }
     @end
     
     MYGame *game = [[MYGame alloc] init];
     game.title = @"Bughouse";
     [game saveInBackground];

 */
@interface PFObject(Subclass)

/*! @name Methods for Subclasses */

/*!
 Designated initializer for subclasses.
 This method can only be called on subclasses which conform to PFSubclassing.
 This method should not be overridden.
 */
- (instancetype)init;

/*!
 Creates an instance of the registered subclass with this class's parseClassName.
 This helps a subclass ensure that it can be subclassed itself. For example, [PFUser object] will
 return a MyUser object if MyUser is a registered subclass of PFUser. For this reason, [MyClass object] is
 preferred to [[MyClass alloc] init].
 This method can only be called on subclasses which conform to PFSubclassing.
  A default implementation is provided by PFObject which should always be sufficient.
 */
+ (instancetype)object;

/*!
 Creates a reference to an existing PFObject for use in creating associations between PFObjects.  Calling isDataAvailable on this
 object will return NO until fetchIfNeeded or refresh has been called.  No network request will be made.
 This method can only be called on subclasses which conform to PFSubclassing.
 A default implementation is provided by PFObject which should always be sufficient.
 @param objectId The object id for the referenced object.
 @result A PFObject without data.
 */
+ (instancetype)objectWithoutDataWithObjectId:(NSString *)objectId;

/*!
 Registers an Objective-C class for Parse to use for representing a given Parse class.
 Once this is called on a PFObject subclass, any PFObject Parse creates with a class
 name matching [self parseClassName] will be an instance of subclass.
 This method can only be called on subclasses which conform to PFSubclassing. 
 A default implementation is provided by PFObject which should always be sufficient.
 */
+ (void)registerSubclass;

/*!
 Returns a query for objects of type +parseClassName.
 This method can only be called on subclasses which conform to PFSubclassing.
 A default implementation is provided by PFObject which should always be sufficient.
 */
+ (PFQuery *)query;

@end
