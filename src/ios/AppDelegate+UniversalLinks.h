/*
 * AppDelegate+UniversalLinks.h
 * Universal Links Category Extension for AppDelegate
 * 
 * This category extends the AppDelegate class to handle Universal Links
 * and forward them to the existing handleOpenURL JavaScript function.
 */

#import "AppDelegate.h"
#import <UIKit/UIKit.h>

/**
 * Category extension for AppDelegate to handle Universal Links
 * This adds Universal Links support without modifying the auto-generated AppDelegate files
 */
@interface AppDelegate (UniversalLinks)

/**
 * Handle Universal Links when the app is launched or resumed
 * This method is called by iOS when a Universal Link is activated
 * 
 * @param application The UIApplication instance
 * @param userActivity The NSUserActivity containing the Universal Link data
 * @param restorationHandler The restoration handler block
 * @return YES if the activity was handled, NO otherwise
 */
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
 restorationHandler:(void (^)(NSArray *))restorationHandler;

@end
