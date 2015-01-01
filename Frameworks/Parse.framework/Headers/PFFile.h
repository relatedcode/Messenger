//
//  PFFile.h
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <Parse/PFConstants.h>
#else
#import <ParseOSX/PFConstants.h>
#endif

@class BFTask;

/*!
 `PFFile` representes a file of binary data stored on the Parse servers.
 This can be a image, video, or anything else that an application needs to reference in a non-relational way.
 */
@interface PFFile : NSObject

///--------------------------------------
/// @name Creating a PFFile
///--------------------------------------

/*!
 @abstract Creates a file with given data. A name will be assigned to it by the server.

 @param data The contents of the new `PFFile`.

 @returns A new `PFFile`.
 */
+ (instancetype)fileWithData:(NSData *)data;

/*!
 @abstract Creates a file with given data and name.

 @param name The name of the new PFFile. The file name must begin with and
 alphanumeric character, and consist of alphanumeric characters, periods,
 spaces, underscores, or dashes.
 @param data The contents of the new `PFFile`.

 @returns A new `PFFile` object.
 */
+ (instancetype)fileWithName:(NSString *)name data:(NSData *)data;

/*!
 @abstract Creates a file with the contents of another file.

 @param name The name of the new `PFFile`. The file name must begin with and
 alphanumeric character, and consist of alphanumeric characters, periods,
 spaces, underscores, or dashes.
 @param path The path to the file that will be uploaded to Parse.
 */
+ (instancetype)fileWithName:(NSString *)name
              contentsAtPath:(NSString *)path;

/*!
 @abstract Creates a file with given data, name and content type.

 @param name The name of the new `PFFile`. The file name must begin with and
 alphanumeric character, and consist of alphanumeric characters, periods,
 spaces, underscores, or dashes.
 @param data The contents of the new `PFFile`.
 @param contentType Represents MIME type of the data.

 @returns A new `PFFile` object.
 */
+ (instancetype)fileWithName:(NSString *)name
                        data:(NSData *)data
                 contentType:(NSString *)contentType;

/*!
 @abstract Creates a file with given data and content type.

 @param data The contents of the new `PFFile`.
 @param contentType Represents MIME type of the data.

 @returns A new `PFFile` object.
 */
+ (instancetype)fileWithData:(NSData *)data contentType:(NSString *)contentType;

/*!
 @abstract The name of the file.

 @discussion Before the file is saved, this is the filename given by
 the user. After the file is saved, that name gets prefixed with a unique
 identifier.
 */
@property (nonatomic, copy, readonly) NSString *name;

/*!
 @abstract The url of the file.
 */
@property (nonatomic, copy, readonly) NSString *url;

///--------------------------------------
/// @name Storing Data with Parse
///--------------------------------------

/*!
 @abstract Whether the file has been uploaded for the first time.
 */
@property (nonatomic, assign, readonly) BOOL isDirty;

/*!
 @abstract Saves the file *synchronously*.

 @returns Returns whether the save succeeded.
 */
- (BOOL)save;

/*!
 @abstract Saves the file *synchronously* and sets an error if it occurs.

 @param error Pointer to an `NSError` that will be set if necessary.

 @returns Returns whether the save succeeded.
 */
- (BOOL)save:(NSError **)error;

/*!
 @abstract Saves the file *asynchronously*.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)saveInBackground;

/*!
 @abstract Saves the file *asynchronously* and executes the given block.

 @param block The block should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block;

/*!
 @abstract Saves the file *asynchronously* and executes the given block.

 @discussion This method will execute the progressBlock periodically with the percent progress.
 `progressBlock` will get called with `100` before `resultBlock` is called.

 @param block The block should have the following argument signature: `^(BOOL succeeded, NSError *error)`
 @param progressBlock The block should have the following argument signature: `^(int percentDone)`
 */
- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block
                    progressBlock:(PFProgressBlock)progressBlock;

/*
 @abstract Saves the file *asynchronously* and calls the given callback.

 @param target The object to call selector on.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 `[result boolValue]` will tell you whether the call succeeded or not.
 */
- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector;

///--------------------------------------
/// @name Getting Data from Parse
///--------------------------------------

/*!
 @abstract Whether the data is available in memory or needs to be downloaded.
 */
@property (assign, readonly) BOOL isDataAvailable;

/*!
 @abstract *Synchronously* gets the data from cache if available or fetches its contents from the network.

 @returns The `NSData` object containing file data. Returns `nil` if there was an error in fetching.
 */
- (NSData *)getData;

/*!
 @abstract This method is like <getData> but avoids ever holding the entire `PFFile` contents in memory at once.

 @discussion This can help applications with many large files avoid memory warnings.

 @returns A stream containing the data. Returns `nil` if there was an error in fetching.
 */
- (NSInputStream *)getDataStream;

/*!
 @abstract *Synchronously* gets the data from cache if available or fetches its contents from the network.
 Sets an error if it occurs.

 @param error Pointer to an `NSError` that will be set if necessary.

 @returns The `NSData` object containing file data. Returns `nil` if there was an error in fetching.
 */
- (NSData *)getData:(NSError **)error;

/*!
 @abstract This method is like <getData> but avoids ever holding the entire `PFFile` contents in memory at once.

 @param error Pointer to an `NSError` that will be set if necessary.

 @returns A stream containing the data. Returns nil if there was an error in
 fetching.
 */
- (NSInputStream *)getDataStream:(NSError **)error;

/*!
 @abstract This method is like <getData> but avoids ever holding the entire `PFFile` contents in memory at once.

 @discussion This can help applications with many large files avoid memory warnings.

 @see getData

 @returns A stream containing the data. Returns `nil` if there was an error in fetching.
 */
- (BFTask *)getDataInBackground;

/*!
 @abstract This method is like <getDataInBackground> but avoids
 ever holding the entire `PFFile` contents in memory at once.

 @discussion This can help applications with many large files avoid memory warnings.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)getDataStreamInBackground;

/*!
 @abstract *Asynchronously* gets the data from cache if available or fetches its contents from the network.

 @param block The block should have the following argument signature: `^(NSData *result, NSError *error)`
 */
- (void)getDataInBackgroundWithBlock:(PFDataResultBlock)block;

/*!
 @abstract This method is like <getDataInBackgroundWithBlock:> but avoids
 ever holding the entire `PFFile` contents in memory at once.

 @discussion This can help applications with many large files avoid memory warnings.

 @param block The block should have the following argument signature: `(NSInputStream *result, NSError *error)`
 */
- (void)getDataStreamInBackgroundWithBlock:(PFDataStreamResultBlock)block;

/*!
 @abstract *Asynchronously* gets the data from cache if available or fetches its contents from the network.

 @discussion This method will execute the progressBlock periodically with the percent progress.
 `progressBlock` will get called with `100` before `resultBlock` is called.

 @param resultBlock The block should have the following argument signature: (NSData *result, NSError *error)
 @param progressBlock The block should have the following argument signature: (int percentDone)
 */
- (void)getDataInBackgroundWithBlock:(PFDataResultBlock)resultBlock
                       progressBlock:(PFProgressBlock)progressBlock;

/*!
 @abstract This method is like <getDataInBackgroundWithBlock:progressBlock:> but avoids
 ever holding the entire `PFFile` contents in memory at once.

 @discussion This can help applications with many large files avoid memory warnings.

 @param resultBlock The block should have the following argument signature: `^(NSInputStream *result, NSError *error)`.
 @param progressBlock The block should have the following argument signature: `^(int percentDone)`.
 */
- (void)getDataStreamInBackgroundWithBlock:(PFDataStreamResultBlock)resultBlock
                             progressBlock:(PFProgressBlock)progressBlock;

/*
 @abstract *Asynchronously* gets the data from cache if available or fetches its contents from the network.

 @param target The object to call selector on.
 @param selector The selector to call.
 It should have the following signature: `(void)callbackWithResult:(NSData *)result error:(NSError *)error`.
 `error` will be `nil` on success and set if there was an error.
 */
- (void)getDataInBackgroundWithTarget:(id)target selector:(SEL)selector;

///--------------------------------------
/// @name Interrupting a Transfer
///--------------------------------------

/*!
 @abstract Cancels the current request (upload or download of file).
 */
- (void)cancel;

@end
