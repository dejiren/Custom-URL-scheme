/*
 * AppDelegate+UniversalLinks.m
 * Universal Links Category Extension Implementation
 */

#import "AppDelegate+UniversalLinks.h"
#import <WebKit/WebKit.h>

@implementation AppDelegate (UniversalLinks)

/**
 * Universal Links処理
 * continueUserActivityメソッドを追加してUniversal Linksを受信
 */
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
 restorationHandler:(void (^)(NSArray *))restorationHandler {
    
    // Universal Linksの場合のみ処理
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        
        if (url) {
            NSString *urlString = [url absoluteString];
            NSLog(@"[UniversalLinks] Universal Link received: %@", urlString);
            
            // handleOpenURL関数を呼び出すJavaScriptコード
            NSString *jsCode = [NSString stringWithFormat:
                @"if(window.handleOpenURL) { window.handleOpenURL('%@'); }", urlString];
            
            // WKWebViewでJavaScript実行
            if (self.viewController && self.viewController.webView) {
                WKWebView *webView = (WKWebView *)self.viewController.webView;
                [webView evaluateJavaScript:jsCode completionHandler:^(id result, NSError *error) {
                    if (error) {
                        NSLog(@"[UniversalLinks] JavaScript execution error: %@", error.localizedDescription);
                    } else {
                        NSLog(@"[UniversalLinks] Universal Link handled successfully");
                    }
                }];
            } else {
                // WebViewが準備できていない場合は遅延実行
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), 
                              dispatch_get_main_queue(), ^{
                    if (self.viewController && self.viewController.webView) {
                        WKWebView *webView = (WKWebView *)self.viewController.webView;
                        [webView evaluateJavaScript:jsCode completionHandler:nil];
                    }
                });
            }
            
            return YES;
        }
    }
    
    return NO;
}

@end