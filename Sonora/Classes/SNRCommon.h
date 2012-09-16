/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#define kArtworkCompressionFactor 0.5
#define kThumbnailArtworkSize CGSizeMake(64.f, 64.f)
#define kIndexInvalid -1
#define kNumberOfSecondsPerDay 86400.0

#define SONORA_APPDELEGATE (SonoraAppDelegate*)[NSApp delegate]
#define SONORA_UI_CONTROLLER [SONORA_APPDELEGATE uiController]
#define SONORA_MANAGED_OBJECT_CONTEXT [SONORA_APPDELEGATE managedObjectContext]
#define SONORA_MAIN_WINDOW [SONORA_APPDELEGATE window]
#define SONORA_SCALE_FACTOR [SONORA_MAIN_WINDOW backingScaleFactor]

#define SONORA_COMPILING_ML __MAC_OS_X_VERSION_MAX_ALLOWED >= 1080

#define SNR_RunningMountainLion (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_7)
#define SNR_ArtistsViewController [SONORA_APPDELEGATE artistsViewController]
#define SNR_QueueCoordinator [SONORA_APPDELEGATE queueCoordinator]
#define SNR_MainQueueController [[SONORA_APPDELEGATE queueCoordinator] mainQueueController]

extern NSString* const kEntityNameTag;
extern NSString* const kEntityNameAlbum;
extern NSString* const kEntityNamePlayCount;
extern NSString* const kEntityNameKeyword;
extern NSString* const kEntityNameArtist;
extern NSString* const kEntityNameArtwork;
extern NSString* const kEntityNameThumbnailArtwork;
extern NSString* const kEntityNameSong;
extern NSString* const kEntityNameiTunesPersistentID;
extern NSString* const kEntityNameMix;
extern NSString* const kEntityNameMixArtwork;
extern NSString* const kEntityNameMixThumbnailArtwork;

extern NSString* const kSortTrackNumberKey;
extern NSString* const kSortNameKey;
extern NSString* const kSortSortNameKey;
extern NSString* const kSortRankingKey;
extern NSString* const kSortPopularityKey;
extern NSString* const kSortDateModifiedKey;
extern NSString* const kSortScoreKey;
extern NSString* const kSortArtistKey;
extern NSString* const kSortDiscNumberKey;

extern NSString* const kImageGenericArtwork;
extern NSString* const kImageGenericArtworkThumbnail;

extern NSString* const kGrowlNotificationNowPlaying;
extern NSString* const kGrowlNotificationImportediTunesTracks;
extern NSString* const kGrowlNotificationLovedTrack;

extern NSString* const kUserDefaultsSearchShortcutKey;