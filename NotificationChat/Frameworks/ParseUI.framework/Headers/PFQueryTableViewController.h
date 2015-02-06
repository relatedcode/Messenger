/*
 *  Copyright (c) 2014, Facebook, Inc. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Facebook.
 *
 *  As with any software that integrates with the Facebook platform, your use of
 *  this software is subject to the Facebook Developer Principles and Policies
 *  [http://developers.facebook.com/policy/]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>

@class PFObject;
@class PFQuery;
@class PFTableViewCell;

/*!
 This class allows you to think about a one-to-one mapping between a <PFObject> and a `UITableViewCell`,
 rather than having to juggle index paths.

 You also get the following features out of the box:

 - Pagination with a cell that can be tapped to load the next page.
 - Pull-to-refresh table view header.
 - Automatic downloading and displaying of remote images in cells.
 - Loading screen, shown before any data is loaded.
 - Automatic loading and management of the objects array.
 - Various methods that can be overridden to customize behavior at major events in the data cycle.
 */
@interface PFQueryTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

///--------------------------------------
/// @name Creating a PFQueryTableViewController
///--------------------------------------

/*!
 @abstract Initializes with a class name of the <PFObject> that will be associated with this table.

 @param style The UITableViewStyle for the table
 @param className The class name of the instances of <PFObject> that this table will display.

 @returns An initialized `PFQueryTableViewController` object or `nil` if the object couldn't be created.
 */
- (instancetype)initWithStyle:(UITableViewStyle)style className:(NSString *)className NS_DESIGNATED_INITIALIZER;

/*!
 @abstract Initializes with a class name of the PFObjects that will be associated with this table.

 @param className The class name of the instances of <PFObject> that this table will display.

 @returns An initialized `PFQueryTableViewController` object or `nil` if the object couldn't be created.
 */
- (instancetype)initWithClassName:(NSString *)className;

///--------------------------------------
/// @name Configuring Behavior
///--------------------------------------

/*!
 @abstract The class name of the <PFObject> this table will use as a datasource.
 */
@property (nonatomic, copy) NSString *parseClassName;

/*!
 @abstract The key to use to display for the cell text label.

 @discussion This won't apply if you override <tableView:cellForRowAtIndexPath:object:>
 */
@property (nonatomic, copy) NSString *textKey;

/*!
 @abstract The key to use to display for the cell image view.

 @discussion This won't apply if you override <tableView:cellForRowAtIndexPath:object:>
 */
@property (nonatomic, copy) NSString *imageKey;

/*!
 @abstract The image to use as a placeholder for the cell images.

 @discussion This won't apply if you override <tableView:cellForRowAtIndexPath:object:>
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/*!
 @abstract Whether the table should use the default loading view. Default - `YES`.
 */
@property (nonatomic, assign) BOOL loadingViewEnabled;

/*!
 @abstract Whether the table should use the built-in pull-to-refresh feature. Defualt - `YES`.
 */
@property (nonatomic, assign) BOOL pullToRefreshEnabled;

/*!
 @abstract Whether the table should use the built-in pagination feature. Default - `YES`.
 */
@property (nonatomic, assign) BOOL paginationEnabled;

/*!
 @abstract The number of objects to show per page. Default - `25`.
 */
@property (nonatomic, assign) NSUInteger objectsPerPage;

/*!
 @abstract Whether the table is actively loading new data from the server.
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

///--------------------------------------
/// @name Responding to Events
///--------------------------------------

/*!
 Called when objects will loaded from Parse. If you override this method, you must
 call [super objectsWillLoad] in your implementation.
 */
- (void)objectsWillLoad;

/*!
 Called when objects have loaded from Parse. If you override this method, you must
 call [super objectsDidLoad:] in your implementation.
 @param error The Parse error from running the PFQuery, if there was any.
 */
- (void)objectsDidLoad:(NSError *)error;

///--------------------------------------
/// @name Accessing Results
///--------------------------------------

/*!
 @abstract The array of instances of <PFObject> that is used as a data source.
 */
@property (nonatomic, copy, readonly) NSArray *objects;

/*!
 @abstract Returns an object at a particular indexPath.

 @discussion The default impementation returns the object at `indexPath.row`.
 If you want to return objects in a different indexPath order, like for sections, override this method.

 @param indexPath The indexPath.

 @returns The object at the specified index
 */
- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

/*!
 @abstract Clears the table of all objects.
 */
- (void)clear;

/*!
 @abstract Clears the table and loads the first page of objects.
 */
- (void)loadObjects;

/*!
 @abstract Loads the objects of the className at the specified page and appends it to the
 objects already loaded and refreshes the table.

 @param page The page of objects to load.
 @param clear Whether to clear the table after receiving the objects.
 */
- (void)loadObjects:(NSInteger)page clear:(BOOL)clear;

/*!
 @abstract Loads the next page of objects, appends to table, and refreshes.
 */
- (void)loadNextPage;

///--------------------------------------
/// @name Querying
///--------------------------------------

/*!
 Override to construct your own custom PFQuery to get the objects.
 @result PFQuery that loadObjects will use to the objects for this table.
 */
- (PFQuery *)queryForTable;

///--------------------------------------
/// @name Data Source Methods
///--------------------------------------

/*!
 @abstract Override this method to customize each cell given a PFObject that is loaded.

 @discussion If you don't override this method, it will use a default style cell and display either
 the first data key from the object, or it will display the key as specified with `textKey`, `imageKey`.

 @warning The cell should inherit from <PFTableViewCell> which is a subclass of `UITableViewCell`.

 @param tableView The table view object associated with this controller.
 @param indexPath The indexPath of the cell.
 @param object The PFObject that is associated with the cell.

 @returns The cell that represents this object.
 */
- (PFTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object;

/*!
 @discussion Override this method to customize the cell that allows the user to load the
 next page when pagination is turned on.

 @param tableView The table view object associated with this controller.
 @param indexPath The indexPath of the cell.

 @returns The cell that allows the user to paginate.
 */
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath;


@end
