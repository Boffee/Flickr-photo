//
//  RecentUserDefaults.m
//  TopPlaces
//
//  Created by Brian Li on 8/30/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import "RecentUserDefaults.h"

@implementation RecentUserDefaults

#define MAX_PHOTOS_STORED 20
+(NSArray *)getRecentPhotos {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault arrayForKey:@"recently viewed photos"];
}

+(void)addPhotoToUserDefault:(NSDictionary *)photo {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    // retrieve a mutable copy of the current photos stored to add the new photo
    NSMutableArray *photos = [[userDefault arrayForKey:@"recently viewed photos"] mutableCopy];
    if (!photos) {
        photos = [[NSMutableArray alloc]init];
    }
    NSLog(@"photos stored:%d", [photos count]);
    [photos removeObject:photo];
    [photos insertObject:photo atIndex:0];
    if ([photos count] > MAX_PHOTOS_STORED) {
        [photos removeObjectAtIndex:MAX_PHOTOS_STORED];
    }
    [userDefault setValue:photos forKey:@"recently viewed photos"];
    [userDefault synchronize];
}

+(void)removeAllPhotos {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"recently viewed photos"];
}
@end
