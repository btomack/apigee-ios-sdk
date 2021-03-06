//
//  BooksViewController.m
//  books
//

#import "BooksViewController.h"
#import "SignInViewController.h"
#import <ApigeeiOSSDK/ApigeeConnection.h>
#import <ApigeeiOSSDK/ApigeeHTTPClient.h>
#import <ApigeeiOSSDK/ApigeeHTTPResult.h>
#import "AddBookViewController.h"

@interface BooksViewController ()
@property (nonatomic, strong) NSDictionary *content;
@end

@implementation BooksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = @"My Books";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Book"
                                                                              style:UIBarButtonItemStyleBordered target:self action:@selector(addbook:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Connection"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(connect:)];                                              
}

- (void) connect:(id) sender
{
    SignInViewController *signinViewController = [[SignInViewController alloc] init];
    UINavigationController *signinNavigationController =
    [[UINavigationController alloc] initWithRootViewController:signinViewController];
    signinNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    signinNavigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    [self presentViewController:signinNavigationController animated:YES completion:nil];
}

- (void) addbook:(id) sender
{
    AddBookViewController *addBookViewController = [[AddBookViewController alloc] init];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:addBookViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self reload];
}

- (void) reload {
    ApigeeConnection *usergrid = [ApigeeConnection sharedConnection];
    if ([usergrid isAuthenticated]) {
        NSLog(@"loading...");
        ApigeeHTTPClient *client = [[ApigeeHTTPClient alloc] initWithRequest:
                                [usergrid getEntitiesInCollection:@"books" limit:100]];
        [client connectWithCompletionHandler:^(ApigeeHTTPResult *result) {
            NSLog(@"%@", result.object);
            self.content = result.object;
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.content ? [self.content[@"entities"] count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.content) {
        cell.textLabel.text = @"Please sign in.";
    } else {
        id entity = self.content[@"entities"][[indexPath row]];
        cell.textLabel.text = entity[@"title"];
        cell.detailTextLabel.text = entity[@"author"];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cell.accessoryView = deleteButton;
        [deleteButton setTitle:@"X" forState:UIControlStateNormal];
        deleteButton.tag = [indexPath row];
        [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton sizeToFit];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) deleteItem:(UIButton *) sender {
    int row = [sender tag];
    id entity = self.content[@"entities"][row];
    NSString *uuid = [entity objectForKey:@"uuid"];
    ApigeeHTTPClient *client = [[ApigeeHTTPClient alloc] initWithRequest:
                            [[ApigeeConnection sharedConnection] deleteEntity:uuid inCollection:@"books"]];
    [client connectWithCompletionHandler:^(ApigeeHTTPResult *result) {
        [self reload];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.content) {
        [self connect:nil];
    }
}

@end
