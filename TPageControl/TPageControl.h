//
//  TPageControl.h
//  TPageControl
//
//  Created by Emck on 5/18/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TPageAnimationType) {
    PageAnimationNext,      // Page Next Animation
    PageAnimationPrevious,  // Page Previous Animation
    PageAnimationEnd        // Page End Animation
};

// TPageAnimation (save some object)
@interface TPageAnimation : NSViewAnimation

@property ( nonatomic, assign          ) TPageAnimationType pageAnimationType;  // save Animation Type
@property ( nonatomic, assign          ) int currentPage;                       // save current Page NO
@property ( nonatomic, strong, nonnull ) NSView *currentView;                   // save current dot view

@end

@class TPageControl;

// TPageControl Delegate
@protocol TPageControlDelegate <NSObject>
@optional
-(void)pageControl: (TPageControl *)pageControl didWillSelectPageAtIndex: (NSInteger)index;
-(void)pageControl: (TPageControl *)pageControl didSelectPageAtIndex    : (NSInteger)index;
-(void)pageControl: (TPageControl *)pageControl didClickEndingButton    : (nonnull id) sender;
@end

@interface TPageButton : NSButton
- (void)setTitleWithColor:(NSString *)title Color:(NSColor *)color; // set button title and title color
@end

// TPageControl Style
typedef NS_ENUM(NSUInteger, TPCStyle) {
    TPCStyleTop,            // top
    TPCStyleBottom,         // bottom
    TPCButtonLeft,          // left button
    TPCButtonRight,         // right button
    TPCButtonEnding         // ending button
};

@interface TPageControl : NSView <NSAnimationDelegate>

- (instancetype)initWithParentsView:(NSView *)parentsView Style:(TPCStyle)style Height:(NSInteger)height BackgroundColor:(NSColor *)backgroundColor;

@property (nonatomic, strong) id<TPageControlDelegate> delegate;    // TPageControl Delegate

@property (nonatomic, assign) int      numberOfPages;       // total pages
@property (nonatomic, assign) int      currentPage;         // current page
@property (nonatomic, strong) NSColor *currentDotColor;     // select dot color
@property (nonatomic, strong) NSColor *otherDotColor;       // not select dot color
@property (nonatomic, assign) CGFloat  dotHeight;           // dot Height
@property (nonatomic, assign) CGFloat  dotSpace;            // dot space
@property (nonatomic, assign) CGFloat  cornerRadius;        // dot Radius
@property (nonatomic, assign) CGFloat  currentDotWidth;     // select dot width
@property (nonatomic, assign) CGFloat  otherDotWidth;       // not select dot width
@property (nonatomic, assign) CGFloat  buttonRadius;        // button radius
@property (nonatomic, assign) CGFloat  buttonSpace;         // button Spaces

// init button style(TPCButtonLeft,TPCButtonRight,TPCButtonEnding) with title and color
- (void)initButton:(TPCStyle)style Size:(CGSize)size Title:(NSString *)title Color:(NSColor *)color BackgroundColor:(NSColor *)backgroundColor;

@end

NS_ASSUME_NONNULL_END
