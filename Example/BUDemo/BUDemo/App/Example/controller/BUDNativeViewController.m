//
//  BUDNativeViewController.m
//  BUDemo
//
//  Created by carl on 2017/8/15.
//  Copyright © 2017年 bytedance. All rights reserved.
//

#import "BUDNativeViewController.h"
#import <BUAdSDK/BUBannerAdView.h>
#import <BUAdSDK/BUNativeAd.h>
#import <BUAdSDK/BUNativeAdRelatedView.h>
#import "UIImageView+AFNetworking.h"
#import <BUAdSDK/BUVideoAdView.h>
#import "BUDMacros.h"
#import "BUDRefreshButton.h"
#import "BUDNormalButton.h"

@interface BUDNativeViewController () <BUNativeAdDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *customview;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UILabel *adLabel;
@property (nonatomic, strong) BUNativeAd *ad;
@property (nonatomic, strong) BUDRefreshButton *button;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) BOOL isNormalView; // 是否为普通视图
@property (nonatomic, strong) BUDNormalButton *collectionBtn;
@property (nonatomic, strong) BUDNormalButton *normalBtn;
@property (nonatomic, strong) BUNativeAdRelatedView *relatedView;

@end

@implementation BUDNativeViewController

- (void)dealloc {}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self bulidSettingBtn];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionBtn.center = CGPointMake(self.view.center.x, self.view.center.y*0.8);
    self.normalBtn.center = CGPointMake(self.view.center.x, self.view.center.y*1.2);
}

- (void)bulidSettingBtn {
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.collectionBtn = [[BUDNormalButton alloc] initWithFrame:CGRectMake(0, size.height * 0.4, 0, 0)];
    [_collectionBtn setTitle:@"加载Collection样式" forState:UIControlStateNormal];
    [_collectionBtn addTarget:self action:@selector(buildCollection) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_collectionBtn];
    
    self.normalBtn = [[BUDNormalButton alloc] initWithFrame:CGRectMake(0, size.height * 0.6, 0, 0)];
    [_normalBtn setTitle:@"加载普通页面样式" forState:UIControlStateNormal];
    [_normalBtn addTarget:self action:@selector(buildNormalView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_normalBtn];
}

- (void)buildCollection {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完成加载" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
    self.collectionBtn.hidden = YES;
    self.normalBtn.hidden = YES;
    self.isNormalView = NO;
    [self buildupView];
    [self buildUICollectionView];
    [self loadNativeAd];
}

- (void)buildNormalView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完成加载" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
    self.collectionBtn.hidden = YES;
    self.normalBtn.hidden = YES;
    self.isNormalView = YES;
    [self buildupView];
    [self loadNativeAd];
}

- (void)buildUICollectionView {
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //该方法也可以设置itemSize
    layout.minimumLineSpacing = 2;
    
    //2.初始化collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width,300) collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    
    //4.设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)buildupView {
    
    CGFloat cusViewWidth = 290;
    CGFloat leftMargin = cusViewWidth/20;
    _relatedView = [[BUNativeAdRelatedView alloc] init];
    // Custom 视图测试
    _customview = [[UIView alloc] initWithFrame:CGRectMake(5, 5, cusViewWidth, cusViewWidth)];
    _customview.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_customview];
    _customview.frame = CGRectMake(5, 5, cusViewWidth, cusViewWidth);
    if(self.isNormalView) {
        [self.view addSubview:_customview];
        _customview.frame = CGRectMake(0, 200, self.view.frame.size.width,300);
    }
    
    CGFloat swidth = CGRectGetWidth(_customview.frame);
    
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, leftMargin, swidth - leftMargin * 2, 30)];
    _infoLabel.backgroundColor = [UIColor magentaColor];
    _infoLabel.text = @"test ads";
    _infoLabel.adjustsFontSizeToFitWidth = YES;
    [_customview addSubview:_infoLabel];
    
    CGFloat buttonWidth = ceilf((swidth-4 * leftMargin)/3);
    _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(_infoLabel.frame), CGRectGetMaxY(_infoLabel.frame)+5, buttonWidth, 30)];
    [_actionButton setTitle:@"自定义按钮" forState:UIControlStateNormal];
    _actionButton.userInteractionEnabled = YES;
    _actionButton.backgroundColor = [UIColor orangeColor];
    _actionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_customview addSubview:_actionButton];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_actionButton.frame)+5, CGRectGetMaxY(_infoLabel.frame)+5, 150, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"ads title";
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [_customview addSubview:_titleLabel];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.backgroundColor = [UIColor redColor];
    [_customview addSubview:_imageView];
    
    // 添加视频视图
    [_customview addSubview:self.relatedView.videoAdView];
    // 添加logo视图
    self.relatedView.logoImageView.frame = CGRectZero;
    [_customview addSubview:self.relatedView.logoImageView];
    // 添加dislike按钮
    self.relatedView.dislikeButton.frame = CGRectMake(CGRectGetMaxX(_infoLabel.frame) - 20, CGRectGetMaxY(_infoLabel.frame)+5, 24, 20);
    [_customview addSubview:self.relatedView.dislikeButton];
    // 添加广告标签
    self.relatedView.adLabel.frame = CGRectZero;
    [_customview addSubview:self.relatedView.adLabel];
    
    self.button = [[BUDRefreshButton alloc] init];
    [self.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

-(void)buttonTapped:(UIButton *)sender {
    [self loadNativeAd];
}


- (void)loadNativeAd {
    BUNativeAd *nad = [[BUNativeAd alloc] init];;
    BUAdSlot *slot1 = [[BUAdSlot alloc] init];
    BUSize *imgSize1 = [[BUSize alloc] init];
    imgSize1.width = 1080;
    imgSize1.height = 1920;
    slot1.ID = self.viewModel.slotID;
    slot1.AdType = BUAdSlotAdTypeFeed;
    slot1.position = BUAdSlotPositionFeed;
    slot1.imgSize = imgSize1;
    slot1.isSupportDeepLink = YES;
    nad.adslot = slot1;
    
    nad.rootViewController = self;
    nad.delegate = self;
    
    self.ad = nad;
    
    [nad loadAdData];
}

- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    self.infoLabel.text = nativeAd.data.AdDescription;
    self.titleLabel.text = nativeAd.data.AdTitle;
    BUMaterialMeta *adMeta = nativeAd.data;
    CGFloat contentWidth = CGRectGetWidth(_customview.frame) - 20;
    BUImage *image = adMeta.imageAry.firstObject;
    const CGFloat imageHeight = contentWidth * (image.height / image.width);
    CGRect rect = CGRectMake(10, CGRectGetMaxY(_actionButton.frame) + 5, contentWidth, imageHeight);
    self.relatedView.logoImageView.frame = CGRectMake(CGRectGetMaxX(rect) - 15 , CGRectGetMaxY(rect) - 15, 15, 15);
    self.relatedView.adLabel.frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - 14, 26, 14);
    
    // imageMode来决定是否展示视频
    if (adMeta.imageMode == BUFeedVideoAdModeImage) {
        self.imageView.hidden = YES;
        self.relatedView.videoAdView.hidden = NO;
        self.relatedView.videoAdView.frame = rect;
        [self.relatedView refreshData:nativeAd];
    } else {
        self.imageView.hidden = NO;
        self.relatedView.videoAdView.hidden = YES;
        if (adMeta.imageAry.count > 0) {
            if (image.imageURL.length > 0) {
                self.imageView.frame = rect;
                [self.imageView setImageWithURL:[NSURL URLWithString:image.imageURL] placeholderImage:nil];
            }
        }
    }
 
    
    // Register UIView with the native ad; the whole UIView will be clickable.
    [nativeAd registerContainer:self.customview withClickableViews:@[self.infoLabel, self.actionButton]];
}


#pragma mark - BUNativeAdDelegate
- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error
{
    NSString *info = @"物料加载失败";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"native" message:info delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alert show];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *)view
{
    NSString *str = NSStringFromClass([view class]);
    NSString *info = [NSString stringWithFormat:@"点击了 %@", str];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"广告" message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alert show];
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd
{
    
}

#pragma mark - UICollectionViewDataSource

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
    
    if (indexPath.row == 1) {
        self.customview.hidden = NO;
        [cell addSubview:self.customview];
    } else {
        [cell.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj == self.customview ) {
                self.customview.hidden = YES;
            }
        }];
    }
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(300, 300);
}

@end
