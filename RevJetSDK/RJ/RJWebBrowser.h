//
//  RJWebBrowser.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RJWebBrowserDelegate;

@interface RJWebBrowser : UIViewController<UIWebViewDelegate> {
 @private
  NSURL *url_;
  id<RJWebBrowserDelegate> __unsafe_unretained delegate_;

  UIWebView *webView_;
  UIToolbar *toolbar_;
  UIBarButtonItem *backButton_;
  UIBarButtonItem *forwardButton_;
}

@property (nonatomic,unsafe_unretained) id<RJWebBrowserDelegate> delegate;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UIToolbar *toolbar;
@property (nonatomic,strong) UIBarButtonItem *backButton;
@property (nonatomic,strong) UIBarButtonItem *forwardButton;

- (id)initWithDelegate:(id<RJWebBrowserDelegate>)delegate URL:(NSURL *)url;
+ (RJWebBrowser *)RJWebBrowserWithDelegate:(id <RJWebBrowserDelegate>)delegate URL:(NSURL *)url;

@end
