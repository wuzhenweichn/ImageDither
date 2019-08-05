//
//  UIImage+Extension.m
//  ImageDither
//
//  Created by zwwuchn on 8/5/19.
//  Copyright © 2019 zwwuchn. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)
#pragma mark - 图片抖动处理
- (UIImage *)dither {
    UIImage *resultImage;
    // 分配内存
    const int imageWidth = self.size.width;
    const int imageHeight = self.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* oldImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    uint32_t* newImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();// 色彩范围的容器
    CGContextRef oldContext = CGBitmapContextCreate(oldImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(oldContext, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    CGContextRef newContext = CGBitmapContextCreate(newImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(newContext, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
        // 遍历像素
        int pixelNum = imageWidth * imageHeight;
        uint32_t* pCurPtr = oldImageBuf;
        uint32_t* newCurPtr = newImageBuf;
    
        for (int i = 0; i < pixelNum; i++, pCurPtr++)
        {
            int row = i / imageWidth ;
            int column = i % imageWidth;
            uint8_t* ptr = (uint8_t*)pCurPtr;
            uint8_t r = ptr[3];
            uint8_t g = ptr[2];
            uint8_t b = ptr[1];
            uint8_t nearColor = [self getNearstColor:r g:g b:b];
            uint8_t* newptr = (uint8_t*)newCurPtr;
            //残差
            int eRgb[3];
            if (nearColor == 0) {
                newptr[3] = 0;
                newptr[2] = 0;
                newptr[1] = 0;
                newptr[0] = 255;
                eRgb[0] = r;
                eRgb[1] = g;
                eRgb[2] = b;
            } else {
                newptr[3] = 255;
                newptr[2] = 255;
                newptr[1] = 255;
                newptr[0] = 255;
                eRgb[0] = r-255;
                eRgb[1] = g-255;
                eRgb[2] = b-255;
            }
            //残差 16分之 7、5、3、1
            float rate1 = 0.4375;
            float rate2 = 0.3125;
            float rate3 = 0.1875;
            float rate4 = 0.0625;
            uint32_t rgb1 = [self getPixel:oldImageBuf width:imageWidth height:imageHeight row:row column:column+1 rate:rate1 eRgb:eRgb];
            uint32_t rgb2 = [self getPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column rate:rate2 eRgb:eRgb];
            uint32_t rgb3 = [self getPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column-1 rate:rate3 eRgb:eRgb];
            uint32_t rgb4 = [self getPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column+1 rate:rate4 eRgb:eRgb];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row column:column+1 value:rgb1];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column value:rgb2];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column-1 value:rgb3];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column+1 value:rgb4];
            newCurPtr++;
        }
    
    // 将内存转成image
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, newImageBuf, bytesPerRow * imageHeight, nil);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,NULL,true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    resultImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(oldContext);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    return resultImage;
}
#pragma mark- 获取相邻像素值
- (int )getNearstColor:(uint8_t) r g:(uint8_t) g b:(uint8_t) b {
    int distance0Squared = pow(r, 2) + pow(g, 2) + pow(b, 2);
    int distance255Squared = pow((255-r), 2) + pow((255-g), 2) + pow((255-b), 2);
    if (distance0Squared < distance255Squared) {
        return 0;
    } else {
        return 1;
    }
}
#pragma mark- 获取像素点
- (uint32_t)getPixel:(uint32_t*)imageBuf width:(int)width height:(int)height   row:(int)row column:(int)column rate:(float)rate eRgb:(int *)eRgb {
    if (row < 0 || row >= height || column < 0 || column >= width) {
        return 0xFFFFFFFF;
    }
    int index = row * width + column;
    uint32_t *ptr = imageBuf + index;
    uint8_t* newptr = (uint8_t*)ptr;
    uint8_t r = newptr[3];
    uint8_t g = newptr[2];
    uint8_t b = newptr[1];
    uint8_t a = newptr[0];
    int er = eRgb[0];
    int eg = eRgb[1];
    int eb = eRgb[2];
    r = clamp(r + (int)(rate*er));
    g = clamp(g + (int)(rate*eg));
    b = clamp(b + (int)(rate*eb));
    return (r << 24) + (g << 16) + (b << 8) + a;
}
#pragma mark- 设置像素点
- (void)setPixel:(uint32_t*)imageBuf width:(int)width height:(int)height   row:(int)row column:(int)column value:(uint32_t)value {
    if (row < 0 || row >= height || column < 0 || column >= width) {
        return;
    }
    int index = row * width + column;
    uint32_t *ptr = imageBuf + index;
    uint8_t* newptr = (uint8_t*)ptr;
    int r = (value & 0xFF000000) >> 24;
    int g = (value & 0x00FF0000) >> 16;
    int b = (value & 0x0000FF00) >> 8;
    int a = value & 0x000000FF;
    
    newptr[3] = r;
    newptr[2] = g;
    newptr[1] = b;
    newptr[0] = a;
}


int clamp(int value) {
    return value > 255 ? 255 : (value < 0 ? 0: value);
}

@end
