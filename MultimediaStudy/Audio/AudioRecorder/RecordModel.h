//
//  RecordModel.h
//  MultimediaStudy
//
//  Created by Shao Jie on 16/7/7.
//  Copyright © 2016年 yourangroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordModel : NSObject<NSCoding>
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSURL * url;
@property (nonatomic,copy) NSString * dateString;
+ (instancetype)initWithTitle:(NSString *)title url:(NSURL *)url;
@end
