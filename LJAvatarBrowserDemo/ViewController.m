//
//  ViewController.m
//  LJAvatarBrowserDemo
//
//  Created by txooo on 17/6/5.
//  Copyright © 2017年 领琾. All rights reserved.
//

#import "ViewController.h"
#import "LJAvatarBrowser.h"
#import <ImageIO/ImageIO.h>
#import <SDWebImage/UIImageView+WebCache.h>
@interface ViewController ()<LJAvatarBrowserDelegate>
{
    NSArray *_imgArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    _imgArray = @[@"image.gif",@"timg.jpg",@"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1728922066,2264830593&fm=27&gp=0.jpg",@"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1340624740,981264645&fm=27&gp=0.jpg"];
    for (int i = 0; i < _imgArray.count; i++) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(20 + 100 * i, 30, 80, 80)];
        if ([_imgArray[i] hasPrefix:@"http"]) {
            [imgV sd_setImageWithURL:_imgArray[i] placeholderImage:[UIImage imageNamed:@"timg.jpg"]];
        }else {
            imgV.image = [UIImage imageNamed:_imgArray[i]];
        }
        imgV.tag = 100 + i;
        imgV.userInteractionEnabled = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.layer.cornerRadius = 40;
        [self.view addSubview:imgV];
        
        imgV.clipsToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPreviewImages:)];
        [imgV addGestureRecognizer:tap];
        
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    imageView.userInteractionEnabled = YES;
    imageView.image = [UIImage imageNamed:@"image.gif"];
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageView:)];
    [imageView addGestureRecognizer:tap];
    
    [self createGIF];
}

- (void)showPreviewImages:(UITapGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag - 100;
    
    LJAvatarBrowser *browser = [LJAvatarBrowser showPreviewPhotos:[_imgArray mutableCopy] delegate:self containerView:(UIImageView *)tap.view previewIndex:tag placeholderImage:nil];
    browser.longPressBlock = ^(NSInteger index){
        NSLog(@"长按%tu",index);
    };
}

#pragma mark
- (void)photoBrowser:(LJAvatarBrowser *)browser longPressAtIndex:(NSInteger)index{
    NSLog(@"长按%tu",index);
}

- (UIView *)photoBrowser:(LJAvatarBrowser *)browser willDissmissAtIndex:(NSInteger)index {
    UIImageView *view = [self.view viewWithTag:index + 100];
    return view;
}

- (NSString *)photoBrowser:(LJAvatarBrowser *)browser originImageURLForIndex:(NSInteger)index {
    if (index == 1) {
        return @"https://ss0.baidu.com/73F1bjeh1BF3odCf/it/u=1156432014,2449352063&fm=85&s=329015CD9C40F5571A94D8A203006011";
    }
    return nil;
}

- (void)showImageView:(UITapGestureRecognizer *)tap {
    UIImageView *imageView = (UIImageView *)tap.view;
    [LJAvatarBrowser showImageView:imageView];
}

- (void)createGIF {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 250, 280, 200)];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"image" withExtension:@"gif"];//加载GIF图片
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);//将GIF图片转换成对应的图片源
    size_t frameCout = CGImageSourceGetCount(gifSource);//获取其中图片源个数，即由多少帧图片组成
    NSMutableArray* frames = [[NSMutableArray alloc] init];//定义数组存储拆分出来的图片
    CGFloat duration = 0;
    for (size_t i=0; i < frameCout; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);//从GIF图片中取出源图片
        UIImage* imageName = [UIImage imageWithCGImage:imageRef];//将图片源转换成UIimageView能使用的图片源
        [frames addObject:imageName];//将图片加入数组中
        CGImageRelease(imageRef);
        
        NSDictionary *info = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
        NSDictionary *timeDic = [info objectForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        duration += [[timeDic objectForKey:(__bridge NSString *)kCGImagePropertyGIFDelayTime] floatValue];
    }
    imageView.animationImages = frames;
    imageView.animationDuration = duration;
    [imageView startAnimating];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageView:)];
    [imageView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
