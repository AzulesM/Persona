//
//  AppDelegate.m
//  Persona
//
//  Created by Azules on 2018/10/27.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "AppDelegate.h"
@import Firebase;

@interface AppDelegate ()

@property (strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    navigationBar.translucent = NO;
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.barTintColor = [UIColor colorWithRed:24.f/255.f green:25.f/255.f blue:27.f/255.f alpha:1.f];
    navigationBar.titleTextAttributes = @{NSFontAttributeName            : [UIFont fontWithName:@"MarkerFelt-Wide" size:20.f],
                                          NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [self checkCurrentUser];
    
    return YES;
}

- (void)checkCurrentUser {
    FIRUser *user = [[FIRAuth auth] currentUser];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    if (user.emailVerified) {
        UITabBarController *tabBarController = [storyBoard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        self.window.rootViewController = tabBarController;
    } else {
        UINavigationController *navigationController = [storyBoard instantiateViewControllerWithIdentifier:@"LoginNavigation"];
        self.window.rootViewController = navigationController;
    }
}

@end
