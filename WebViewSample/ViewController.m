//
//  ViewController.m
//  WebViewSample
//
//  Created by aCetylAcid on 2017/01/15.
//  Copyright © 2017年 zrn-ns.com. All rights reserved.
//

#import "ViewController.h"

//#define INITIAL_URL @"https://gocart.jp/"
#define INITIAL_URL @"https://gocart.jp/ap/item/i/A0GC00007VBC?colvar=UAL"
#define PATTERN     @"/i/([a-zA-Z0-9]*)"

@interface ViewController () <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初回画面表示時にIntialURLで指定した Web ページを読み込む
    NSURL *url = [NSURL URLWithString:INITIAL_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)loadView
{
    [super loadView];
    
    // WKWebView インスタンスの生成
    self.webView = [WKWebView new];
    
    // Auto Layout の設定
    // 画面いっぱいに WKWebView を表示するようにする
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:0]
                                ]];
    
    // デリゲートにこのビューコントローラを設定する
    self.webView.navigationDelegate = self;
    
    // フリップでの戻る・進むを有効にする
    self.webView.allowsBackForwardNavigationGestures = YES;
    
    // WKWebView インスタンスを画面に配置する
    [self.view insertSubview:self.webView atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTapped:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (IBAction)forwardBtnTapped:(id)sender {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (IBAction)reloadBtnTapped:(id)sender {
    [self.webView reload];
}

- (IBAction)decideBtnTapped:(id)sender {
    // URLから商品コードを抽出
    NSString *urlString = [self.webView.URL absoluteString];
    NSString *productCode = [self.class parseProductCodeFromURL:urlString pattern:PATTERN];
    
    NSString *msg = [NSString stringWithFormat:@"URL: %@\nPRODUCT_CODE: %@", self.webView.URL, productCode];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"INFO"
                                                                 message:msg
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:cancelAction];
    [self presentViewController:controller animated:YES completion:nil];
}

/**
 * URL内で正規表現のパターン(1)に一致する部分の文字列を取得する。
 * 複数に一致した場合、最初に一致した箇所を取得する
 */
+ (NSString *)parseProductCodeFromURL:(NSString *)urlString pattern:(NSString *)pattern
{
    // URLから商品コードを抽出
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:urlString
                                      options:NSMatchingReportProgress
                                        range:NSMakeRange(0, [urlString length])];
    if (matches.count != 0) {
        NSTextCheckingResult *match = (NSTextCheckingResult*)[matches objectAtIndex:0];
        return [urlString substringWithRange:[match rangeAtIndex:1]];
    } else {
        return @"";
    }
}

@end
