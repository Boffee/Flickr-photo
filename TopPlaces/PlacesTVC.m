//
//  PlacesTVC.m
//  TopPlaces
//
//  Created by Brian Li on 8/28/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import "PlacesTVC.h"
#import "FlickrFetcher.h"
#import "PlaceTopFlickrPhotosTVC.h"


@interface PlacesTVC ()
@property (strong, nonatomic)NSDictionary * placesByCountries;
@property (strong, nonatomic)NSArray *orderedCountries;
@end

@implementation PlacesTVC

#pragma mark - Properties
- (void)setPlaces:(NSArray *)places {
    _places = places;
    [self sortPlacesByCountryThenCity:self.places];
    [self.tableView reloadData];

}

#pragma mark - setUp
// get the city country of the place
- (NSString *)countryForPlace:(NSDictionary *)place {
    NSString *placeInfo = [place valueForKey:FLICKR_PLACE_NAME];
    return [[placeInfo componentsSeparatedByString:@", "] lastObject];
}

// get the city of the place
- (NSString *)cityForPlace:(NSDictionary *)place {
    NSString *placeInfo = [place valueForKey:FLICKR_PLACE_NAME];
    return [[placeInfo componentsSeparatedByString:@", "] firstObject];
}

// get the region of the place
- (NSString *)regionForPlace:(NSDictionary *)place {
    NSString *placeInfo = [place valueForKey:FLICKR_PLACE_NAME];
    return [placeInfo componentsSeparatedByString:@", "][1];
}

- (void) sortPlacesByCountryThenCity:(NSArray *)places {
    // city is sorted first because it is a subsort of country. The last sorted item will be the top layer sort
    NSArray *sortedByCity;
    sortedByCity = [places sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *city1 = [(NSDictionary *)obj1 valueForKey:FLICKR_PLACE_NAME];
        NSString *city2 = [(NSDictionary *)obj2 valueForKey:FLICKR_PLACE_NAME];
        return [city1 compare:city2];
    }];
    
    
    // set up a diction with country as key and cities of the country as object
    NSMutableDictionary *placesByCountries = [[NSMutableDictionary alloc] init];
    // loop through all of the places
    for (NSDictionary *place in sortedByCity) {
        // get country
        NSString *country = [self countryForPlace:place];
        // if the dictionary does not contain the country add the country to the dictionary
        if (![placesByCountries objectForKey:country]) {
            [placesByCountries setObject:[NSMutableArray array] forKey:country];
        }
        // add the place to the array object for country key
        [(NSMutableArray *)[placesByCountries objectForKey:country] addObject:place];
    }
    
    // create an array of sorted countries to use as key ot the placesByCountries dictionary
    NSArray *orderedCountries = [placesByCountries allKeys];
    orderedCountries = [orderedCountries sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    self.orderedCountries = orderedCountries;
    self.placesByCountries = placesByCountries;
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.placesByCountries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.placesByCountries objectForKey:self.orderedCountries[section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Top Place Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    // get the place at the index path
    NSDictionary *place = [self.placesByCountries objectForKey:self.orderedCountries[indexPath.section]][indexPath.row];
    // set the cell's main title to city
    cell.textLabel.text = [self cityForPlace:place];
    // set the cell's subtitle to region
    cell.detailTextLabel.text = [self regionForPlace:place];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.orderedCountries[section];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PlaceTopFlickrPhotosTVC class]]) {
        PlaceTopFlickrPhotosTVC *tvc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            NSDictionary *place = [self.placesByCountries objectForKey:self.orderedCountries[indexPath.section]][indexPath.row];
            tvc.title = [self cityForPlace:place];
            tvc.place = place;
        }
    }
}

@end
