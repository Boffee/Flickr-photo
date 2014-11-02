//
//  TopPlacesTVC.m
//  TopPlaces
//
//  Created by Brian Li on 8/28/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"

@interface TopPlacesTVC ()

@end

@implementation TopPlacesTVC

- (void) viewDidLoad {
    [super viewDidLoad];
    [self fetchPlaces];
}

- (IBAction) fetchPlaces {
    
    [self.refreshControl beginRefreshing];
    // use fetchure to get an array of place dictionaries
    NSURL *topPlaces = [FlickrFetcher URLforTopPlaces];
    
    // perform on a seperate queue so that it doesnt block the main queue
    dispatch_queue_t fetchQ = dispatch_queue_create("fetch top places", NULL);
    dispatch_async(fetchQ, ^{
        // get data from url as json
        NSData *jsonResults = [NSData dataWithContentsOfURL:topPlaces];
        // convert json to dictionary
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        // get the places from the dictionary
        NSArray *places = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        // assign on the main queue
        [self performSelectorOnMainThread:@selector(setPlaces:) withObject:places waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.places = places;
            [self.refreshControl endRefreshing];
        });
    });
}
@end
