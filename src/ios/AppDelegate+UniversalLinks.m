/*
 * AppDelegate+UniversalLinks.m
 * Universal Links Category Extension
 * バックグラウンド起動対応
 */

#import "AppDelegate+UniversalLinks.h"
#import <WebKit/WebKit.h>

@implementation AppDelegate (UniversalLinks)

/**
 * Universal Links処理
 * バックグラウンドからの起動にも対応
 */
- (BOOL)application:(UIApplication *)application 
continueUserActivity:(NSUserActivity *)userActivity 
 restorationHandler:(void (^)(NSArray *))restorationHandler {
    
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        
        if (url) {
            NSString *urlString = [url absoluteString];
            NSLog(@"[UniversalLinks] Universal Link received: %@", urlString);
            
            // WebViewが準備できるまで待ってからhandleOpenURLを実行
            [self executeHandleOpenURLWhenReady:urlString];
            
            return YES;
        }
    }
    
    return NO;
}

/**
 * WebViewの準備完了を待ってhandleOpenURLを実行
 * 0.5秒後と2秒後に実行を試みる
 * これにより、WebViewがまだ準備できていない場合でも、後で実行されるようにする
 */
- (void)executeHandleOpenURLWhenReady:(NSString *)urlString {
    // 成功フラグで重複実行を防ぐ
    __block BOOL executed = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), 
                  dispatch_get_main_queue(), ^{
        if (!executed) {
            executed = [self tryExecuteHandleOpenURL:urlString];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), 
                  dispatch_get_main_queue(), ^{
        if (!executed) {
            executed = [self tryExecuteHandleOpenURL:urlString];
        }
    });
}

/**
 * handleOpenURL実行試行
 * @return 実行成功時YES、失敗時NO
 */
- (BOOL)tryExecuteHandleOpenURL:(NSString *)urlString {
    if (!self.viewController || !self.viewController.webView) {
        NSLog(@"[UniversalLinks] WebView not ready yet");
        return NO;
    }
    
    WKWebView *webView = (WKWebView *)self.viewController.webView;
    
    // シンプルなJavaScript実行
    NSString *jsCode = [NSString stringWithFormat:
        @"if (typeof window.handleOpenURL === 'function') {"
        @"  console.log('[Native] Calling handleOpenURL with: %@');"
        @"  window.handleOpenURL('%@');"
        @"  true;"  // 成功を返す
        @"} else {"
        @"  console.log('[Native] handleOpenURL not found, saving to localStorage');"
        @"  localStorage.setItem('djrDeeplinkPath', '%@');"
        @"  false;" // 失敗を返す
        @"}", 
        urlString, urlString, urlString];
    
    [webView evaluateJavaScript:jsCode completionHandler:^(id result, NSError *error) {
        if (error) {
            NSLog(@"[UniversalLinks] JavaScript execution failed: %@", error.localizedDescription);
        } else {
            NSLog(@"[UniversalLinks] JavaScript executed successfully");
        }
    }];
    
    return YES; // WebViewが存在すれば実行成功とみなす
}

@end