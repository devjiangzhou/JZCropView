//
//  JZCropView.m
//  Petta_Phase2
//
//  Created by BaiJiangzhou on 14-6-24.
//
//ps: 整个图片scrollView的contentsize 高度 = 图片裁剪框之外图片的高度 + 屏幕的高度

#import "JZCropView.h"
#import "UIImage+Extensions.h"
#define IMAGE_SCALE 2.5

@interface JZCropView()
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIScrollView *imageScrollView;

@property (nonatomic,assign) float imageHeight;
@property (nonatomic,assign) float imageWidth;

@property (nonatomic,strong) UIImage *fullImage;

@end
@implementation JZCropView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cropRect = frame;
        
        //        self.image = [UIImage imageNamed:@"test2.jpg"];;
        //        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame cropFrame:(CGRect)cropFrame image:(UIImage*)image{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cropRect = cropFrame;
        self.image  = image;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [self initView];
}

- (void)initView
{
    __block  float scale =  MainScreenWidth / self.image.size.width;
    __block  float width = self.image.size.width * scale;
    __block  float height = self.image.size.height * scale;
    
    if (self.image.size.width > self.image.size.height) { //长 > 宽 显示宽
        scale =  MainScreenWidth / self.image.size.width;
    }else{
        scale =  MainScreenHeight / self.image.size.height;
    }
    
    width = self.image.size.width * scale;
    height = self.image.size.height * scale;
    
    self.imageHeight = height;
    self.imageWidth  = width;
    
    UIScrollView *imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight)];
    imageScrollView.userInteractionEnabled = YES;
    
    imageScrollView.delegate = self;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.showsVerticalScrollIndicator = NO;
    
    [self addSubview:imageScrollView];
    self.imageScrollView=imageScrollView;
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage: self.image];
    imageView.userInteractionEnabled=YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView=imageView;
    [imageScrollView addSubview:imageView];
    
    // 缩放
    float minZoom = imageScrollView.frame.size.width / imageView.frame.size.width;
    imageScrollView.minimumZoomScale = minZoom;
    imageScrollView.maximumZoomScale = 2;
    imageScrollView.zoomScale = minZoom;
    
    imageView.frame = CGRectMake(0, 0, MainScreenWidth, MainScreenHeight);
    
    // scrollview contentsize 必须在设置zoomScale后设置。 因为zoomScale会改变contentsize
    //    [imageScrollView setContentSize:CGSizeMake((MainScreenWidth+1), height - MainScreenWidth + MainScreenHeight)];
    
    //    imageScrollView.contentOffset=CGPointMake(0, (height - MainScreenWidth)/2);
    imageScrollView.contentOffset=CGPointMake(0, 0);
    
    //阴影
    UIView *shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight)];
    [self addSubview:shadowView];
    shadowView.userInteractionEnabled = NO;
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor]];
    //清空出来一块空白
    UIBezierPath *maskPath =  [UIBezierPath bezierPathWithRect:shadowView.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRect:self.cropRect];
    [maskPath appendPath:cutoutPath];
    mask.path = maskPath.CGPath;
    [shadowView.layer addSublayer:mask];
    
    //画外面的白线
    CAShapeLayer *cropLayer = [CAShapeLayer layer];
    [cropLayer setFillColor:[[UIColor clearColor] CGColor]];
    [cropLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [cropLayer setLineWidth:1.0f];
    UIBezierPath *cropLinePath =  [UIBezierPath bezierPathWithRect:self.cropRect];
    cropLayer.path = cropLinePath.CGPath;
    [shadowView.layer addSublayer:cropLayer];
    
    
    [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
        scale =  MainScreenWidth / self.image.size.width;
        width = self.image.size.width * scale;
        height = self.image.size.height * scale;
        
        self.imageHeight = height;
        self.imageWidth  = width;
        
        imageScrollView.contentOffset=CGPointMake(0, (height - MainScreenWidth)/2);
        imageView.frame = CGRectMake(0, self.cropRect.origin.y, width, height);
    } completion:^(BOOL finished) {
        
        // scrollview contentsize 必须在设置zoomScale后设置。 因为zoomScale会改变contentsize
        [imageScrollView setContentSize:CGSizeMake((MainScreenWidth+1), height - MainScreenWidth + MainScreenHeight)];
        
    }];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:YES];
    scrollView.contentSize = CGSizeMake(self.imageView.size.width, self.imageHeight*scale - MainScreenWidth + MainScreenHeight);
}

#pragma mark 铺满图片
-(void) makeFullImage{
    
    self.imageScrollView.contentOffset=CGPointMake(0, 0);
    if (self.fullImage) {
        self.fullImage = nil;
        self.imageScrollView.scrollEnabled=YES;
        self.imageView.image = self.image;
        self.imageScrollView.contentOffset=CGPointMake(0, 0);
        self.imageView.frame = CGRectMake(0, self.cropRect.origin.y, self.imageWidth, self.imageHeight);
        [self.imageScrollView setContentSize:CGSizeMake((MainScreenWidth+1), self.imageHeight - MainScreenWidth + MainScreenHeight)];
    }else{
        self.imageScrollView.scrollEnabled = NO;
        UIImage *fulledImage = [self.image imageByScalingProportionallyToSize:CGSizeMake(MainScreenWidth, MainScreenWidth)];
        //    fullImage = [fullImage imageWithTintColor:[UIColor whiteColor]];
        //
        CGSize size = CGSizeMake(MainScreenWidth, MainScreenWidth);
        UIGraphicsBeginImageContext(size);
        
        [[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0] set];
        UIRectFill(CGRectMake(0, 0, MainScreenWidth, MainScreenWidth));
        UIImage *whiteBgImg = UIGraphicsGetImageFromCurrentImageContext();
        [whiteBgImg drawInRect:CGRectMake(0, 0, MainScreenWidth, MainScreenWidth)];
        
        CGFloat xPadding = (MainScreenWidth - fulledImage.size.width)/2;
        CGFloat yPadding = (MainScreenWidth - fulledImage.size.height)/2;
        
        [fulledImage drawInRect:CGRectMake(xPadding, yPadding, fulledImage.size.width, fulledImage.size.height)];
        
        self.fullImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.imageView.frame = self.cropRect;
        self.imageView.image = self.fullImage;
    }
}

#pragma mark 裁剪图片
- (UIImage *)croppedImage
{
    if (self.fullImage) {
        return self.fullImage;
    }
    CGRect rect = [self convertRect:self.cropRect toView:self.imageView];
    
    CGFloat koef = self.imageView.image.size.width / self.imageScrollView.frame.size.width;
    
    CGRect finalImageRect = CGRectMake(rect.origin.x*koef, rect.origin.y*koef, rect.size.width*koef, rect.size.height*koef);
    
    UIImage *croppedImage = [self.imageView.image imageAtRect:finalImageRect];
    
    return croppedImage;
}
@end
