//
//  UIImage+Extension.h
//  ImageDither
//
//  Created by zwwuchn on 8/5/19.
//  Copyright © 2019 zwwuchn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extension)
/**
 图片抖动处理
 */
- (UIImage *)dither;
@end

NS_ASSUME_NONNULL_END
