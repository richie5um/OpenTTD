/* $Id: win32_v.h 17428 2009-09-05 21:26:51Z rubidium $ */

/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

/** @file win32_v.h Base of the Windows video driver. */

#ifndef VIDEO_WIN32_H
#define VIDEO_WIN32_H

#include "video_driver.hpp"

class VideoDriver_Win32: public VideoDriver {
public:
	/* virtual */ const char *Start(const char * const *param);

	/* virtual */ void Stop();

	/* virtual */ void MakeDirty(int left, int top, int width, int height);

	/* virtual */ void MainLoop();

	/* virtual */ bool ChangeResolution(int w, int h);

	/* virtual */ bool ToggleFullscreen(bool fullscreen);
	/* virtual */ const char *GetName() const { return "win32"; }
};

class FVideoDriver_Win32: public VideoDriverFactory<FVideoDriver_Win32> {
public:
	static const int priority = 10;
	/* virtual */ const char *GetName() { return "win32"; }
	/* virtual */ const char *GetDescription() { return "Win32 GDI Video Driver"; }
	/* virtual */ Driver *CreateInstance() { return new VideoDriver_Win32(); }
};

#endif /* VIDEO_WIN32_H */
