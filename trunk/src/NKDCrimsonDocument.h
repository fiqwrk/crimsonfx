// -----------------------------------------------------------------------------------
//  NKDCrimsonDocument.h
// -----------------------------------------------------------------------------------
//  Created by Jeff LaMarche on 1/28/05.
//  Copyright (c) 2005 Naked Software. All rights reserved.
// -----------------------------------------------------------------------------------
// THIS	SOURCE CODE IS PROVIDED AS-IS WITH NO WARRANTY OF ANY KIND
// -----------------------------------------------------------------------------------
// You may use and redistribute this source code without limitation
// -----------------------------------------------------------------------------------
#import <Cocoa/Cocoa.h>
#import "NKDMutableMovie.h"
#import "NKDCrimsonMovieFrameView.h"
#import "NKDLaserEffectSettings.h"
#import "NSColor-interpolate.h"
#import "CompressMovie.h"
#import "DTSQTUtilities.h"
#import "NSString+FSSPec.h"
#import <QTKit/QTKit.h>
@protocol CrimsonThreadWatchProtocol
- (BOOL)shouldCancel;
- (void)incrementProgress;
- (long)currentFrame;
- (NKDCrimsonMovieFrameView *)docView;
- (void)setCurrentFrame:(long)newCurrentFrame;
- (void)setProgressTextFromThread:(NSString *)inText;
@end

@interface NKDCrimsonDocument : NSDocument <NSCoding, CrimsonThreadWatchProtocol>
{
    long		    currentFrame;
    NKDMutableMovie	    *movie;
    NSString		    *moviePath;
    NSMutableDictionary	    *settings;
    
    IBOutlet NKDCrimsonMovieFrameView *docView;
    IBOutlet NSSlider	    *frameSlider;
    IBOutlet NSPopUpButton  *effectTypePopUp;

    IBOutlet NSBox	    *keyframeBox;
    IBOutlet NSButton	    *keyframeCheckbox;
    IBOutlet NSColorWell    *auraColorWell;
    IBOutlet NSColorWell    *coreColorWell;
    IBOutlet NSTextField    *frameCountText;
    
    IBOutlet NSButton	    *startNudgeUp;
    IBOutlet NSButton	    *startNudgeRight;
    IBOutlet NSButton	    *startNudgeDown;
    IBOutlet NSButton	    *startNudgeLeft;
    IBOutlet NSTextField    *startWidthTF;
    IBOutlet NSSlider	    *startWidthSlider;
    IBOutlet NSButton	    *startRoundedCheckbox;
    
    IBOutlet NSButton	    *endNudgeUp;
    IBOutlet NSButton	    *endNudgeRight;
    IBOutlet NSButton	    *endNudgeDown;
    IBOutlet NSButton	    *endNudgeLeft;
    IBOutlet NSTextField    *endWidthTF;
    IBOutlet NSSlider	    *endWidthSlider;
    IBOutlet NSButton	    *endRoundedCheckbox;
    
    IBOutlet NSButton	    *emitterBulbCheckbox;
    
    // Progress Dialog
    IBOutlet NSButton		    *cancelButton;
    IBOutlet NSProgressIndicator    *progressIndicator;
    IBOutlet NSTextField	    *progressText;
    BOOL			    shouldCancel;
    IBOutlet NSWindow		    *progressPanel;
}
- (NSWindow *)window;
- (long)currentFrame;
- (void)setCurrentFrameFromObject:(NSNumber *)newFrame;
- (void)setCurrentFrame:(long)newCurrentFrame;
- (NKDMutableMovie *)movie;
- (void)setMovie:(NKDMutableMovie *)newMovie;
- (NSMutableDictionary *)settings;
- (void)setSettings:(NSMutableDictionary *)newSettings;
- (NSButton *)keyframeCheckbox;
- (NSString *)moviePath;
- (void)setMoviePath:(NSString *)newMoviePath;
- (NKDCrimsonMovieFrameView *)docView;
- (void)setDocView:(NKDCrimsonMovieFrameView *)newDocView;

/*!
@method currentSettings
@discussion Accessor sets "currentSettings" to the correct value for the currentFrame. It returns 
 the actual settings for this frame, if it's a key frame, otherwise,
 returns a fabricated settings object with interpolated values based on the previous
 and next keyframes
@result Settings object with the settings for this frame
 */
- (NKDLaserEffectSettings *)currentSettings;

- (BOOL)isCurrentFrameKeyFrame;
- (NSImage *)currentFrameImage;

- (IBAction)toggleKeyFrameStatus:(id)sender;
- (IBAction)nudgeStart:(id)sender;
- (IBAction)nudgeFinish:(id)sender;
- (IBAction)stepForward:(id)sender;
- (IBAction)stepBack:(id)sender;
- (IBAction)changeFrameBasedOnSlider:(id)sender;
- (IBAction)stepToEnd:(id)sender;
- (IBAction)stepToBeginning:(id)sender;
- (IBAction)nextKeyframe:(id)sender;
- (IBAction)previousKeyframe:(id)sender;
- (IBAction)takeKeyFrameValuesfrom:(id)sender;
- (IBAction)previewFrame:(id)sender;
- (IBAction)renderMovie:(id)sender;
- (IBAction)cancelButtonPresed:(id)sender;
- (IBAction)effectTypeChanged:(id)sender;

- (BOOL)shouldCancel;
- (void)setShouldCancel:(BOOL)newShouldCancel;
- (void)renderMovieDidEnd: (NSWindow *)sheet
               returnCode:(int)returnCode
              contextInfo:(NSDictionary *)info;
- (void)renderMovieThread:(NSDictionary *)info;
- (NSImage *)currentRenderedFrame;
- (NSImage *)currentPreviewFrame;
- (void)setProgressTextFromThread:(NSString *)inText;
/*!
@method selectMovie
@discussion This method is used when a new document is created. It presents a dialog telling the user
 they must select a movie clip to use as a basis. It then presents the open dialog box to select the movie.
 If the dialog is canceled, the document is closed.
*/
- (void)selectMovie:(id)dummy;
- (void)selectMovieDialogDidEnd:(NSWindow *)sheet 
		     returnCode:(int)returnCode
		    contextInfo:(void *)contextInfo;
- (void)openMovieDialogDidEnd:(NSOpenPanel *)panel
		   returnCode:(int)returnCode 
		  contextInfo:(void *)contextInfo;
- (void)loadSourceMovie;

- (void)updateKeyframeStatus;
- (void)setKeyframeValues:(NKDLaserEffectSettings *)frameSet;
- (NSNumber *)nextKeyframeNumber;
- (NSNumber *)previousKeyframeNumber;
- (void)launchMovieAt:(NSString *)filename;
@end
