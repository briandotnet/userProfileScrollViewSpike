//
//  CHUserProfileViewModel.h
//  userProfileScrollViewSpike
//
//  Created by Brian Ge on 7/12/13.
//  Copyright (c) 2013 Brian Ge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHUserProfileViewModel : NSObject

@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, strong) NSString *userLastName;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSArray  *files;
@property (nonatomic, strong) NSDictionary *additionalDetails;

@end
