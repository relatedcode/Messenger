//
//  PFUITableViewController.h
//  Parse
//
//  Created by James Yu on 11/20/11.
//  Copyright (c) 2011 Parse, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PFQuery.h"
#import "PFTableViewCell.h"

/*!
 This class allows you to think about a one-to-one mapping between a PFObject and a UITableViewCell,
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

/*! @name Creating a PFQueryTableViewController */

/*!
 The designated initializer.
 Initializes with a class name of the PFObjects that will be associated with this table.
 @param style The UITableViewStyle for the table
 @param aClassName The class name of the PFObjects that this table will display
 @result The initialized PFQueryTableViewController
 */
- (instancetype)initWithStyle:(UITableViewStyle)style className:(NSString *)aClassName;

/*!
 Initializes with a class name of the PFObjects that will be associated with this table.
 @param aClassName The class name of the PFObjects that this table will display
 @result The initialized PFQueryTableViewController
 */
- (instancetype)initWithClassName:(NSString *)aClassName;

/*! @name Configuring Behavior */

/*!
 The class of the PFObject this table will use as a datasource
 */
@property (nonatomic, strong) NSString *parseClassName;

/*!
 The key to use to display for the cell text label.
 This won't apply if you override tableView:cellForRowAtIndexPath:object:
 */
@property (nonatomic, strong) NSString *textKey;

/*!
 The key to use to display for the cell image view.
 This won't apply if you override tableView:cellForRowAtIndexPath:object:
 */
@property (nonatomic, strong) NSString *imageKey;

/*!
 The image to use as a placeholder for the cell images.
 This won't apply if you override tableView:cellForRowAtIndexPath:object:
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/// Whether the table should use the default loading view (default:YES)
@property (nonatomic, assign) BOOL loadingViewEnabled;

/// Whether the table should use the built-in pull-to-refresh feature (default: `YES`)
@property (nonatomic, assign) BOOL pullToRefreshEnabled;

/*!
 Whether the table should use the built-in pagination feature (default: `YES`)
 */
@property (nonatomic, assign) BOOL paginationEnabled;

/*!
 The number of objects to show per page (default: `25`)
 */
@property (nonatomic, assign) NSUInteger objectsPerPage;

/*!
 Whether the table is actively loading new data from the server
 */
@property (nonatomic, assign) BOOL isLoading;

/*! @name Responding to Events */

/*!
 Called when objects have loaded from Parse. If you override this method, you must
 call [super objectsDidLoad:] in your implementation.
 @param error The Parse error from running the PFQuery, if there was any.
 */
- (void)objectsDidLoad:(NSError *)error;

/*!
 Called when objects will loaded from Parse. If you override this method, you must
 call [super objectsWillLoad] in your implementation.
 */
- (void)objectsWillLoad;

/*! @name Accessing Results */

/// The array of PFObjects that is the UITableView data source
@property (nonatomic, strong, readonly) NSArray *objects;

/*!
 Returns an object at a particular indexPath. The default impementation returns
 the object at indexPath.row. If you want to return objects in a different
 indexPath order, like for sections, override this method.
 @param     indexPath   The indexPath
 @result    The object at the specified index
 */
- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

/*! @name Querying */

/*!
 Override to construct your own custom PFQuery to get the objects.
 @result PFQuery that loadObjects will use to the objects for this table.
 */
- (PFQuery *)queryForTable;

/*!
 Clears the table of all objects.
 */
- (void)clear;

/*!
 Clears the table and loads the first page of objects.
 */
- (void)loadObjects;

/*!
 Loads the objects of the className at the specified page and appends it to the
 objects already loaded and refreshes the table.
 @param     page    The page of objects to load.
 @param     clear   Whether to clear the table after receiving the objects.
 */
- (void)loadObjects:(NSInteger)page clear:(BOOL)clear;

/*!
 Loads the next page of objects, appends to table, and refreshes.
 */
- (void)loadNextPage;

/*! @name Data Source Methods */

/*!
 Override this method to customize each cell given a PFObject that is loaded. If you
 don't override this method, it will use a default style cell and display either
 the first data key from the object, or it will display the key as specified
 with keyToDisplay.

 The cell should inherit from PFTableViewCell which is a subclass of UITableViewCell.

 @param tableView   The table view object associated with this controller.
 @param indexPath   The indexPath of the cell.
 @param object      The PFObject that is associated with the cell.
 @result            The cell that represents this object.
 */
- (PFTableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object;

/*!
 Override this method to customize the cell that allows the user to load the
 next page when pagination is turned on.
 @param tableView   The table view object associated with this controller.
 @param indexPath   The indexPath of the cell.
 @result            The cell that allows the user to paginate.
 */
- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath;


@end
