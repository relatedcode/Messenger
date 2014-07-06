//  PFACL.h
//  Copyright 2011 Parse, Inc. All rights reserved.

#import <Foundation/Foundation.h>

@class PFUser;
@class PFRole;

/*!
 A PFACL is used to control which users can access or modify a particular
 object. Each PFObject can have its own PFACL. You can grant
 read and write permissions separately to specific users, to groups of users
 that belong to roles, or you can grant permissions to "the public" so that,
 for example, any user could read a particular object but only a particular
 set of users could write to that object.
 */
@interface PFACL : NSObject <NSCopying>

/** @name Creating an ACL */

/*!
 Creates an ACL with no permissions granted.
 */
+ (PFACL *)ACL;

/*!
 Creates an ACL where only the provided user has access.
 */
+ (PFACL *)ACLWithUser:(PFUser *)user;

/** @name Controlling Public Access */

/*!
 Set whether the public is allowed to read this object.
 */
- (void)setPublicReadAccess:(BOOL)allowed;

/*!
 Gets whether the public is allowed to read this object.
 */
- (BOOL)getPublicReadAccess;

/*!
 Set whether the public is allowed to write this object.
 */
- (void)setPublicWriteAccess:(BOOL)allowed;

/*!
 Gets whether the public is allowed to write this object.
 */
- (BOOL)getPublicWriteAccess;

/** @name Controlling Access Per-User */

/*!
 Set whether the given user id is allowed to read this object.
 */
- (void)setReadAccess:(BOOL)allowed forUserId:(NSString *)userId;

/*!
 Gets whether the given user id is *explicitly* allowed to read this object.
 Even if this returns NO, the user may still be able to access it if getPublicReadAccess returns YES
 or if the user belongs to a role that has access.
 */
- (BOOL)getReadAccessForUserId:(NSString *)userId;

/*!
 Set whether the given user id is allowed to write this object.
 */
- (void)setWriteAccess:(BOOL)allowed forUserId:(NSString *)userId;

/*!
 Gets whether the given user id is *explicitly* allowed to write this object.
 Even if this returns NO, the user may still be able to write it if getPublicWriteAccess returns YES
 or if the user belongs to a role that has access.
 */
- (BOOL)getWriteAccessForUserId:(NSString *)userId;

/*!
 Set whether the given user is allowed to read this object.
 */
- (void)setReadAccess:(BOOL)allowed forUser:(PFUser *)user;

/*!
 Gets whether the given user is *explicitly* allowed to read this object.
 Even if this returns NO, the user may still be able to access it if getPublicReadAccess returns YES
 or if the user belongs to a role that has access.
 */
- (BOOL)getReadAccessForUser:(PFUser *)user;

/*!
 Set whether the given user is allowed to write this object.
 */
- (void)setWriteAccess:(BOOL)allowed forUser:(PFUser *)user;

/*!
 Gets whether the given user is *explicitly* allowed to write this object.
 Even if this returns NO, the user may still be able to write it if getPublicWriteAccess returns YES
 or if the user belongs to a role that has access.
 */
- (BOOL)getWriteAccessForUser:(PFUser *)user;

/** @name Controlling Access Per-Role */

/*!
 Get whether users belonging to the role with the given name are allowed
 to read this object. Even if this returns false, the role may still
 be able to read it if a parent role has read access.
 
 @param name The name of the role.
 @return YES if the role has read access. NO otherwise.
 */
- (BOOL)getReadAccessForRoleWithName:(NSString *)name;

/*!
 Set whether users belonging to the role with the given name are allowed
 to read this object.
 
 @param name The name of the role.
 @param allowed Whether the given role can read this object.
 */
- (void)setReadAccess:(BOOL)allowed forRoleWithName:(NSString *)name;

/*!
 Get whether users belonging to the role with the given name are allowed
 to write this object. Even if this returns false, the role may still
 be able to write it if a parent role has write access.
 
 @param name The name of the role.
 @return YES if the role has read access. NO otherwise.
 */
- (BOOL)getWriteAccessForRoleWithName:(NSString *)name;

/*!
 Set whether users belonging to the role with the given name are allowed
 to write this object.
 
 @param name The name of the role.
 @param allowed Whether the given role can write this object.
 */
- (void)setWriteAccess:(BOOL)allowed forRoleWithName:(NSString *)name;

/*!
 Get whether users belonging to the given role are allowed to read this
 object. Even if this returns NO, the role may still be able to
 read it if a parent role has read access. The role must already be saved on
 the server and its data must have been fetched in order to use this method.
 
 @param role The name of the role.
 @return YES if the role has read access. NO otherwise.
 */
- (BOOL)getReadAccessForRole:(PFRole *)role;

/*!
 Set whether users belonging to the given role are allowed to read this
 object. The role must already be saved on the server and its data must have
 been fetched in order to use this method.
 
 @param role The role to assign access.
 @param allowed Whether the given role can read this object.
 */
- (void)setReadAccess:(BOOL)allowed forRole:(PFRole *)role;

/*!
 Get whether users belonging to the given role are allowed to write this
 object. Even if this returns NO, the role may still be able to
 write it if a parent role has write access. The role must already be saved on
 the server and its data must have been fetched in order to use this method.
 
 @param role The name of the role.
 @return YES if the role has write access. NO otherwise.
 */
- (BOOL)getWriteAccessForRole:(PFRole *)role;

/*!
 Set whether users belonging to the given role are allowed to write this
 object. The role must already be saved on the server and its data must have
 been fetched in order to use this method.
 
 @param role The role to assign access.
 @param allowed Whether the given role can write this object.
 */
- (void)setWriteAccess:(BOOL)allowed forRole:(PFRole *)role;

/** @name Setting Access Defaults */

/*!
 Sets a default ACL that will be applied to all PFObjects when they are created.
 @param acl The ACL to use as a template for all PFObjects created after setDefaultACL has been called.
 This value will be copied and used as a template for the creation of new ACLs, so changes to the
 instance after setDefaultACL has been called will not be reflected in new PFObjects.
 @param currentUserAccess If true, the PFACL that is applied to newly-created PFObjects will
 provide read and write access to the currentUser at the time of creation. If false,
 the provided ACL will be used without modification. If acl is nil, this value is ignored.
 */
+ (void)setDefaultACL:(PFACL *)acl withAccessForCurrentUser:(BOOL)currentUserAccess;

@end
