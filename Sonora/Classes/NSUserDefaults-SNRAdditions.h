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

@interface NSUserDefaults (SNRAdditions)
@property (nonatomic, copy) NSString *lastFMUsername;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) BOOL scrobble;
@property (nonatomic, assign) BOOL synciTunesSongs;
@property (nonatomic, assign) BOOL synciTunesPlaylists;
@property (nonatomic, assign) BOOL growlNowPlaying;
@property (nonatomic, assign) BOOL growlNewImport;
@property (nonatomic, assign) BOOL copyMusic;
@property (nonatomic, assign) BOOL embedArtwork;
@property (nonatomic, assign) NSInteger sortMode;
@property (nonatomic, assign) NSInteger repeatMode;
@property (nonatomic, copy) NSString *libraryPath;
@property (nonatomic, assign) BOOL firstImport;
@property (nonatomic, assign) BOOL firstMetadataiTunes;
@property (nonatomic, assign) BOOL useMemoryInputSource;
- (void)showFirstMetadataiTunesAlert;
@end
