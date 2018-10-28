//
//  Spinner.m
//  Persona
//
//  Created by Azules on 2018/10/28.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "Spinner.h"

@implementation Spinner

+ (void)start {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:indicatorView];
    [indicatorView startAnimating];
}

+ (void)stop {
    for (UIView *view in [[[UIApplication sharedApplication] keyWindow] subviews]) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)view stopAnimating];
            [view removeFromSuperview];
        }
    }
}

@end
