//
//  TPageControl.m
//  TPageControl
//
//  Created by Emck on 5/18/22.
//

#import "TPageControl.h"

@implementation TPageAnimation
@end

@implementation TPageButton

- (void)setTitleWithColor:(NSString *)title Color:(NSColor *)color {
    [super setTitle:title];
    if (color != nil) {
        NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
        NSRange rtitleRange = NSMakeRange(0, [colorTitle length]);
        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:rtitleRange];
        [self setAttributedTitle:colorTitle];
    }
}

@end

@interface TPageControl ()

@property (nonatomic, strong) NSMutableArray *dotViewArrayM;        // save dot Views
@property (nonatomic, assign) BOOL isInitialize;                    // flag is need Initialize
@property (atomic,    assign) BOOL inAnimating;                     // flag in Animating
@property (nonatomic, strong) TPageButton *leftButton;              // left button
@property (nonatomic, strong) TPageButton *rightButton;             // right button
@property (nonatomic, strong) TPageButton *endingButton;            // ending button

@end

@implementation TPageControl

- (instancetype)initWithParentsView:(NSView *)parentsView Style:(TPCStyle)style Height:(NSInteger)height {
    if (style == TPCStyleTop) self = [super initWithFrame:NSMakeRect(0, parentsView.frame.size.height - height, parentsView.frame.size.width, height)];
    else self = [super initWithFrame:NSMakeRect(0, 0, parentsView.frame.size.width, height)];       // default bottom
    
    if (self) {
        self.currentDotColor = [NSColor blackColor];        // default select dot color
        self.otherDotColor   = [NSColor lightGrayColor];    // default not select dot color
        self.isInitialize    = YES;                         // need Initialize
        self.inAnimating     = NO;
        self.dotViewArrayM   = [NSMutableArray array];      // alloc Array
        self.buttonRadius    = 8;                           // default button Radius
    }
    return self;
}

- (void)initButton:(TPCStyle)style Size:(CGSize)size Title:(NSString *)title Color:(NSColor *)color BackgroundColor:(NSColor *)backgroundColor {
    TPageButton *pageButton = [[TPageButton alloc] initWithFrame:CGRectMake(0,0,size.width, size.height)];  // default origin is 0,0
    [[pageButton cell] setBackgroundColor:backgroundColor]; // set backgroundColor
    [pageButton setTitleWithColor:title Color:color];       // set title and title color
    pageButton.wantsLayer =YES;                             // enable Layer
    pageButton.layer.cornerRadius = self.buttonRadius;      // corner Radius
    pageButton.bordered = NO;                               // without bordered
    pageButton.target = self;
    pageButton.action = @selector(buttonClick:);
    pageButton.hidden = YES;
    switch (style) {
        case TPCButtonLeft:
            pageButton.frame = CGRectMake(20, 15, size.width, size.height);
            self.leftButton = pageButton;
            break;
        case TPCButtonRight:
            pageButton.frame = CGRectMake(self.superview.frame.size.width - 106, 15, size.width, size.height);
            self.rightButton = pageButton;
            break;
        case TPCButtonEnding:
            pageButton.frame = CGRectMake(self.superview.frame.size.width - 106, 15, size.width, size.height);
            self.endingButton = pageButton;
            break;
        default: break;
    }
    [self addSubview:pageButton];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self updateView];              // update Views
}

- (void)updateView {
    if (self.dotViewArrayM.count == 0) return;
    if (self.isInitialize == NO) return;
    
    self.isInitialize = NO;
    CGFloat totalWidth = self.currentDotWidth + (self.numberOfPages - 1) * (self.dotSpace + self.otherDotWidth);
    CGFloat currentX = (self.frame.size.width - totalWidth) / 2;
    for (int i = 0; i < self.dotViewArrayM.count; i++) {
        NSView *dotView = self.dotViewArrayM[i];
        // update frame
        CGFloat width = (i == self.currentPage ? self.currentDotWidth : self.otherDotWidth);
        CGFloat height = self.dotHeight;
        CGFloat x = currentX;
        CGFloat y = (self.frame.size.height - height) / 2;
        dotView.frame = CGRectMake(x, y, width, height);

        currentX = currentX + width + self.dotSpace; // next dot X position

        // update color
        dotView.layer.backgroundColor = self.otherDotColor.CGColor;
        if (i == self.currentPage) dotView.layer.backgroundColor = self.currentDotColor.CGColor;
    }
    
    if (self.leftButton != nil) self.leftButton.hidden = YES;
    if (self.rightButton != nil) self.rightButton.hidden = NO;
    if (self.endingButton != nil) self.endingButton.hidden = YES;
}

- (void)buttonClick:(id) button {
    if (self.leftButton == button) {
        self.currentPage = (self.currentPage -1 + self.numberOfPages) % self.numberOfPages;
    }
    else if (self.rightButton == button) {
        self.currentPage = (self.currentPage + 1 + self.numberOfPages) % self.numberOfPages;
    }
    else if (self.endingButton == button) {
        if (_delegate && [_delegate respondsToSelector: @selector(pageControl:didClickEndingButton:)])
            [_delegate pageControl: self didClickEndingButton: self.endingButton];  // Call delegate
    }
}

- (void)setNumberOfPages:(int)numberOfPages {
    _numberOfPages = numberOfPages;
    
    if (self.dotViewArrayM.count > 0) {     // clean view array
        [self.dotViewArrayM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             [(NSView *)obj removeFromSuperview];
         }];
        [self.dotViewArrayM removeAllObjects];
    }
    // create dot view
    for (int i = 0; i < numberOfPages; i++) {
        NSView *dotView = [[NSView alloc] initWithFrame:CGRectZero];
        dotView.wantsLayer = YES;
        dotView.layer.cornerRadius = self.cornerRadius;
        [self addSubview:dotView];
        [self.dotViewArrayM addObject:dotView];             // save dot view into array
    }

    self.isInitialize = YES;    // flag need Initialize
    [self updateLayer];         // update view to screen
}

- (void)setCurrentPage:(int)currentPage {
    if (currentPage < 0 || currentPage >= self.dotViewArrayM.count ||self.dotViewArrayM.count == 0 || currentPage == self.currentPage || self.inAnimating) {
        return;
    }
    if (currentPage ==0) {
        self.leftButton.hidden = YES;
        self.rightButton.hidden = NO;
        self.endingButton.hidden = YES;
    }
    else if (currentPage >0 && currentPage < _numberOfPages -1) {
        self.leftButton.hidden = NO;
        self.rightButton.hidden = NO;
        self.endingButton.hidden = YES;
    }
    else if (currentPage == _numberOfPages -1) {
        self.leftButton.hidden = NO;
        self.rightButton.hidden = YES;
        self.endingButton.hidden = NO;
    }
    
    NSView *currentView = self.dotViewArrayM[self.currentPage];
    [currentView removeFromSuperview];
    [self addSubview:currentView positioned:NSWindowAbove relativeTo:nil];
    self.inAnimating = YES;
    
    TPageAnimation *panimation = nil;
    // go to right
    if (currentPage > self.currentPage) {
        CGFloat width = self.currentDotWidth + (self.dotSpace + self.otherDotWidth) * (currentPage - self.currentPage);
        CGFloat height = currentView.frame.size.height;
        NSRect endFrame = NSMakeRect(currentView.frame.origin.x, currentView.frame.origin.y, width, height);
           
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    currentView,NSViewAnimationTargetKey,
                                    NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,
                                    [NSValue valueWithRect:currentView.frame],NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:endFrame],NSViewAnimationEndFrameKey, nil];
        panimation = [[TPageAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dictionary]];
        panimation.pageAnimationType = PageAnimationNext;
    }
    // go to left
    else {
        CGFloat x = currentView.frame.origin.x - (self.dotSpace + self.otherDotWidth) * (self.currentPage - currentPage);
        CGFloat y = currentView.frame.origin.y;
        CGFloat w = self.currentDotWidth + (self.dotSpace + self.otherDotWidth) * (self.currentPage - currentPage);
        CGFloat h = currentView.frame.size.height;
        NSRect endFrame = NSMakeRect(x, y, w, h);
           
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    currentView,NSViewAnimationTargetKey,
                                    NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,
                                    [NSValue valueWithRect:currentView.frame],NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:endFrame],NSViewAnimationEndFrameKey, nil];
        panimation = [[TPageAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dictionary]];
        panimation.pageAnimationType = PageAnimationPrevious;
    }
    
    panimation.currentPage = currentPage;
    panimation.currentView = currentView;
    panimation.delegate = self;
    panimation.duration = 0.3;
    [panimation setAnimationBlockingMode:NSAnimationNonblocking];
    [panimation startAnimation];
}

// listen animationDidEnd, do something
- (void)animationDidEnd:(TPageAnimation*)animation {
    if (animation.pageAnimationType == PageAnimationNext) {
        NSView *endView = self.dotViewArrayM[animation.currentPage];
        [endView removeFromSuperview];
        endView.layer.backgroundColor = animation.currentView.layer.backgroundColor;
        endView.frame = animation.currentView.frame;
        [self addSubview:endView positioned:NSWindowAbove relativeTo:nil];

        animation.currentView.layer.backgroundColor = [self.otherDotColor CGColor];
        
        // move other view
        CGFloat start_X = animation.currentView.frame.origin.x;
        for (int i = 0; i < (animation.currentPage - self.currentPage); i++) {
            NSView *dotView = self.dotViewArrayM[self.currentPage + i];
            CGRect tempFrame = dotView.frame;
            // move left
            tempFrame.origin = CGPointMake(start_X + (self.otherDotWidth + self.dotSpace) * i, tempFrame.origin.y);
            tempFrame.size = CGSizeMake(self.otherDotWidth, self.dotHeight);
            dotView.frame = tempFrame;
        }
        
        NSRect moveToFrame = NSMakeRect(CGRectGetMaxX(endView.frame) - self.currentDotWidth, endView.frame.origin.y, self.currentDotWidth, endView.frame.size.height);
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    endView,NSViewAnimationTargetKey,
                                    NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,
                                    [NSValue valueWithRect:endView.frame],NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:moveToFrame],NSViewAnimationEndFrameKey, nil];
        TPageAnimation *panimation = [[TPageAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dictionary]];
        panimation.pageAnimationType = PageAnimationEnd;
        panimation.currentPage = animation.currentPage;
        panimation.delegate = self;
        panimation.duration = 0.3;
        [panimation setAnimationBlockingMode:NSAnimationNonblocking];
        [panimation startAnimation];
    }
    else if (animation.pageAnimationType == PageAnimationPrevious) {
        NSView *endView = self.dotViewArrayM[animation.currentPage];
        [endView removeFromSuperview];
        endView.layer.backgroundColor = animation.currentView.layer.backgroundColor;
        endView.frame = animation.currentView.frame;
        [self addSubview:endView positioned:NSWindowAbove relativeTo:nil];

        animation.currentView.layer.backgroundColor = [self.otherDotColor CGColor];
        
        // move other view
        CGFloat start_X = CGRectGetMaxX(animation.currentView.frame);
        for (int i = 0; i < (self.currentPage - animation.currentPage); i++) {
            NSView *dotView = self.dotViewArrayM[self.currentPage - i];
            CGRect tempFrame = dotView.frame;
            // move right
            tempFrame.origin = CGPointMake(start_X - self.otherDotWidth - (self.otherDotWidth + self.dotSpace) * i, tempFrame.origin.y);
            tempFrame.size = CGSizeMake(self.otherDotWidth, tempFrame.size.height);
            dotView.frame = tempFrame;
        }
        
        NSRect moveToFrame = NSMakeRect(endView.frame.origin.x, endView.frame.origin.y, self.currentDotWidth, endView.frame.size.height);
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    endView,NSViewAnimationTargetKey,
                                    NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,
                                    [NSValue valueWithRect:endView.frame],NSViewAnimationStartFrameKey,
                                    [NSValue valueWithRect:moveToFrame],NSViewAnimationEndFrameKey, nil];
        TPageAnimation *panimation = [[TPageAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dictionary]];
        panimation.pageAnimationType = PageAnimationEnd;
        panimation.currentPage = animation.currentPage;
        panimation.delegate = self;
        panimation.duration = 0.3;
        [panimation setAnimationBlockingMode:NSAnimationNonblocking];
        [panimation startAnimation];
    }
    else if (animation.pageAnimationType == PageAnimationEnd) {
        _currentPage = animation.currentPage;
        self.inAnimating = NO;
        if (_delegate && [_delegate respondsToSelector: @selector(pageControl:didSelectPageAtIndex:)])
            [_delegate pageControl: self didSelectPageAtIndex: _currentPage];       // Call delegate
    }
}

@end
