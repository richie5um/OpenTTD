/* $Id: waypoint.cpp 17693 2009-10-04 17:16:41Z rubidium $ */

/*
 * This file is part of OpenTTD.
 * OpenTTD is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2.
 * OpenTTD is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with OpenTTD. If not, see <http://www.gnu.org/licenses/>.
 */

/** @file waypoint.cpp Handling of waypoints. */

#include "stdafx.h"

#include "order_func.h"
#include "window_func.h"
#include "newgrf_station.h"
#include "waypoint_base.h"

/**
 * Draw a waypoint
 * @param x coordinate
 * @param y coordinate
 * @param stat_id station id
 * @param railtype RailType to use for
 */
void DrawWaypointSprite(int x, int y, int stat_id, RailType railtype)
{
	if (!DrawStationTile(x, y, railtype, AXIS_X, STAT_CLASS_WAYP, stat_id)) {
		StationPickerDrawSprite(x, y, STATION_WAYPOINT, railtype, INVALID_ROADTYPE, AXIS_X);
	}
}

void Waypoint::GetTileArea(TileArea *ta, StationType type) const
{
	switch (type) {
		case STATION_BUOY:
		case STATION_WAYPOINT:
			break;

		default: NOT_REACHED();
	}

	ta->tile = this->xy;
	ta->w    = 1;
	ta->h    = 1;
}

Waypoint::~Waypoint()
{
	if (CleaningPool()) return;
	DeleteWindowById(WC_WAYPOINT_VIEW, this->index);
	RemoveOrderFromAllVehicles(OT_GOTO_WAYPOINT, this->index);

	this->sign.MarkDirty();
}
