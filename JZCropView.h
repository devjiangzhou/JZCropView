//
//  JZCropView.h
//  Petta_Phase2
//
//  Created by BaiJiangzhou on 14-6-24.
//
//

#import <UIKit/UIKit.h>

@interface JZCropView : UIView<UIScrollViewDelegate>

//需要裁剪的图片
@property (nonatomic) UIImage *image;
//裁剪后的图片
@property (nonatomic, readonly) UIImage *croppedImage;
//裁剪范围
@property (nonatomic) CGRect cropRect;

//init
- (id)initWithFrame:(CGRect)frame cropFrame:(CGRect)cropFrame image:(UIImage*)image;

//展示全屏幕
-(void) makeFullImage;

@end
