//
//  PlaceTopFlickrPhotosTVC.m
//  TopPlaces
//
//  Created by Brian Li on 8/28/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import "PlaceTopFlickrPhotosTVC.h"
#import "FlickrFetcher.h"

@interface PlaceTopFlickrPhotosTVC ()

@end

@implementation PlaceTopFlickrPhotosTVC

- (NSDictionary *) place {
    if (!_place) {
        _place = [[NSDictionary alloc] init];
    }
    return _place;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self fetchPhotos];
}

- (IBAction) fetchPhotos {
    [self.refreshControl beginRefreshing];
    if (self.place) {
        id placeID = [self.place valueForKey:FLICKR_PLACE_ID];
        // use fetchure to get an array of place dictionaries
        NSURL *topPlaces = [FlickrFetcher URLforPhotosInPlace:placeID maxResults:50];
        
        dispatch_queue_t fetchQ = dispatch_queue_create("get photo", NULL);
        dispatch_async(fetchQ, ^{
            // save data in json file
            NSData *jsonResults = [NSData dataWithContentsOfURL:topPlaces];
            // converdata from json to dictionary
            NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                options:0
                                                                                  error:NULL];
            // get the array of photos
            NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photos = photos;
                [self.refreshControl endRefreshing];
            });
        });

    }
}


@end
