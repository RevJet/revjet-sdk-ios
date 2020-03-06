//
//  RJHTMLScanner.h
//  RevJetSDK
//
//  Copyright (c) RevJet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJHTMLScanner : NSObject

//! Scans HTML content and returns found paramenters wrapped in <code>NSDictionary</code>.
//! @see kRJParamParameters Constant to get meta paramenetrs from dictionary.
+ (NSDictionary *)getParametersFromHTML:(NSString *)aBody;

//! Scans HTML content and returns parameters in CSS (ad width and height).
+ (NSDictionary *)getCSSParametersFromHTML:(NSString *)aBody;

@end
