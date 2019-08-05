//
//  ViewController.m
//  ImageDither
//
//  Created by 硕方 on 8/5/19.
//  Copyright © 2019 zwwuchn. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Extension.h"
@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageView];
    self.imageView.image = [[UIImage imageNamed:@"girl"] dither];
    
}

- (UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
    }
    return _imageView;
}
@end
