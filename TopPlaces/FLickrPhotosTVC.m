//
//  FLickerPhotosTVC.m
//  TopPlaces
//
//  Created by Brian Li on 8/28/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import "FLickrPhotosTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
#import "RecentUserDefaults.h"

@interface FLickrPhotosTVC ()

@end

@implementation FLickrPhotosTVC

-(void)setPhotos:(NSArray *)photos {
    // if photo is set, reload the table
    _photos = photos;
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.photos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    // get title and description of the photo ad index path
    NSDictionary *photo = self.photos[indexPath.row];
    NSString *title = [photo valueForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKey:FLICKR_PHOTO_DESCRIPTION];
    

    if (title.length) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = description;

    }
    else if (description.length) {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.textLabel.text = @"UNKNOWN";
        cell.detailTextLabel.text = @"";
    }
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
        if ([detail isKindOfClass:[ImageViewController class]]) {
            [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
        }
    }
}

#pragma mark - Navigation

- (void)prepareImageViewController: (ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo {
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title = [photo valueForKey:FLICKR_PHOTO_TITLE];
    ivc.hidesBottomBarWhenPushed = YES;
    [RecentUserDefaults addPhotoToUserDefault:photo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            [self prepareImageViewController:ivc toDisplayPhoto:self.photos[indexPath.row]];
        }
    }
}

@end
