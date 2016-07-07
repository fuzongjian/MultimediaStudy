//
//  RecordModel.m
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import "RecordModel.h"

@implementation RecordModel
+ (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url{
    return [[self alloc] initWithTitle:title url:url];
}
- (id)initWithTitle:(NSString *)title url:(NSURL *)url{
    if (self = [super init]) {
        _title = [title copy];
        _url = url;
        _dateString = [self getTimeStamp];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _dateString = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.dateString forKey:@"date"];
}
- (NSString *)getTimeStamp{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:currentDate];
}
@end
