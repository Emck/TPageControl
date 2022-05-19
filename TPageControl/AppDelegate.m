//
//  AppDelegate.m
//  TPageControl
//
//  Created by Emck on 5/18/22.
//

#import "AppDelegate.h"
#import "TPageControl.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (nonatomic, strong) TPageControl *pageControl;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.pageControl = [[TPageControl alloc] initWithParentsView:self.window.contentView Style:TPCStyleBottom Height:50 BackgroundColor:[NSColor windowBackgroundColor]];
    self.pageControl.delegate = self;                           // receive Event
    [self.window.contentView addSubview:self.pageControl];      // add view
    //self.pageControl.currentDotColor = [NSColor blackColor];    // select dot color
    //self.pageControl.otherDotColor = [NSColor lightGrayColor];  // not select dot color
    //self.pageControl.dotHeight = 10;                            // dot Height
    //self.pageControl.dotSpace = 24;                             // dot space
    //self.pageControl.cornerRadius = 5;                          // dot Radius
    //self.pageControl.currentDotWidth = 20;                      // select dot width
    //self.pageControl.otherDotWidth = 10;                        // not select dot width
    //self.pageControl.buttonRadius = 8;                          // button radius
    [self.pageControl initButton:TPCButtonLeft   Size:CGSizeMake(86, 22) Title:@"Previous"   Color:[NSColor blackColor] BackgroundColor:[NSColor whiteColor]];
    [self.pageControl initButton:TPCButtonRight  Size:CGSizeMake(86, 22) Title:@"Next"       Color:[NSColor whiteColor] BackgroundColor:[NSColor colorWithRed:136 green:193 blue:170 alpha:0.8]];
    [self.pageControl initButton:TPCButtonEnding Size:CGSizeMake(86, 22) Title:@"Close Tour" Color:[NSColor whiteColor] BackgroundColor:[NSColor colorWithRed:136 green:193 blue:170 alpha:0.8]];
    self.pageControl.numberOfPages = 5;                         // total pages
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    _pageControl = nil;
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (void)pageControl:(TPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index {
    NSLog(@"Page NO: %ld",index);
}

- (void)pageControl:(TPageControl *)pageControl didClickEndingButton:(nonnull id)sender {
    [NSApp terminate:nil];
}

@end
