# LJAvatarBrowserDemo
一款简单易用,轻量级图片查看工具

![效果图](https://github.com/iBoCoding/LJAvatarBrowser/blob/master/result.gif)

## <a id="How_to_use_LJAvatarBrowser"></a>How to use LJAvatarBrowser
* Installation with CocoaPods：`pod 'LJAvatarBrowser'`
* Manual import：
    * Drag All files in the `LJAvatarBrowser` folder to project
    * Import the main file：`#import "LJAvatarBrowser.h"
    
## <a id="Example"></a>Example

```swift
[LJAvatarBrowser showImageView:imageView];

Or

[LJAvatarBrowser showImageView:imageView originUrl:url];

Or

[LJAvatarBrowser showPreviewPhotos:[_imgArray mutableCopy] delegate:self containerView:containerView previewIndex:tag placeholderImage:nil]
```

## <a id="LJAvatarBrowser.h"></a>LJAvatarBrowser.h

```swift
@protocol LJAvatarBrowserDelegate<NSObject>

@optional

/**
 返回一个高清的url

 @param browser LJAvatarBrowser
 @param index 滚动下标
 @return urlString
 */
 
- (NSString *)photoBrowser:(LJAvatarBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

/**
 将要消失,用于得到最终需要变换的坐标

 @param index 当前显示的下标
 @return 最终要显示的源imageview
 */
 
- (UIImageView *)photoBrowserWillDissmissAtIndex:(NSInteger)index;

/**
 长按事件
 */
 
- (void)photoBrowserLongPressAtIndex:(NSInteger)index;

@end


@interface LJAvatarBrowser : UIView

/**
 需要预览的照片数组
 */
@property (nonatomic, retain) NSMutableArray *previewPhotos;

/**
 预览位置
 */
@property (nonatomic, assign) NSInteger previewIndex;

/**
 占位图
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 正在预览的父View
 */
@property (nonatomic, strong) UIView *containerView;

/**
 长按事件
 */
@property (nonatomic, copy) void (^longPressBlock)(NSInteger);
/**
 *	@brief	浏览头像
 *
 *	@param 	avatarImageView 	头像所在的imageView
 */
 
+ (LJAvatarBrowser *)showImageView:(UIImageView*)avatarImageView;

+ (LJAvatarBrowser *)showImageView:(UIImageView*)avatarImageView originUrl:(NSString *)url;

/**
 查看多placeholder @param previewPhotos 预览数组
 @param containerView 传入的控件的父View
 @param delegate 预览页
 @param previewIndex 预览位置
 @param placeholder 占位图
 */
 
+ (LJAvatarBrowser *)showPreviewPhotos:(NSMutableArray *)previewPhotos
                              delegate:(id)delegate
                         containerView:(UIView *)containerView
                          previewIndex:(NSInteger)previewIndex
                      placeholderImage:(UIImage *)placeholder;

@end
```  
 
