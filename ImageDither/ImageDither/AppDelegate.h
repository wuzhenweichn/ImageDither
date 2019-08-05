//
//  AppDelegate.h
//  ImageDither
//
//  Created by 硕方 on 8/5/19.
//  Copyright © 2019 zwwuchn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

