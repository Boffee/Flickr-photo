//
//  RecentFLickrPhotosTVC.m
//  TopPlaces
//
//  Created by Brian Li on 8/30/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import "RecentFLickrPhotosTVC.h"
#import "RecentUserDefaults.h"

@interface RecentFLickrPhotosTVC ()

@end

@implementation RecentFLickrPhotosTVC
- (void) viewWillAppear:(BOOL)animated {
    self.photos = [RecentUserDefaults getRecentPhotos];
}
@end
