//
//  RecentUserDefaults.h
//  TopPlaces
//
//  Created by Brian Li on 8/30/14.
//  Copyright (c) 2014 Brian Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentUserDefaults : NSObject
+(NSArray *)getRecentPhotos;
+(void)addPhotoToUserDefault:(NSDictionary *)photo;
+(void)removeAllPhotos;
@end
