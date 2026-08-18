-- Shared constants used across server and client
-- Single source of truth for IDs, limits, and configuration

local Constants = {}

-- Group IDs
Constants.MainGroupId = 295131561
Constants.PermissionGroupId = 295131561

-- Place IDs
Constants.CustomizationPlaceId = 88229153869269
Constants.MainLobbyPlaceId = 88229153869269

-- Limits
Constants.MaxProps = 40
Constants.MaxPropSlots = 10
Constants.MaxHeight = 50
Constants.MaxInches = 90
Constants.MaxInchesWithCustomization = 600
Constants.BaseSaveSlots = 50
Constants.MaxSaveSlots = 100
Constants.SpecialMaxSaveSlots = 80
Constants.MaxAccessories = 300
Constants.MoreAccessoriesGamepassMaxAccessories = 400
Constants.SpecialMaxAccessories = 600
Constants.AccessoryHistoryLimit = 50
Constants.MaxAccessoryDistance = 9999999999
Constants.MaxAccessoryDistanceWithCustomization = 999999999

-- Customization defaults
Constants.DefaultBodyType = 0.25
Constants.DefaultProportions = 0

-- Multiverse
Constants.RefreshDebounceTime = 20
Constants.ServerTimeout = 300

-- Messaging keys
Constants.MasterKey = "GameServerCommunication"
Constants.BackupKey = "GameServerCommunication2"

-- Account requirements
Constants.AccountAgeRequired = 1

-- Permission ranks (for PermissionGroupId)
Constants.Ranks = {
	Community = 245,
	Gamemaster = 246,
	Executives = 247,
	Staff = 248,
	Developer = 250,
	HeadDeveloper = 251,
	Manager = 253,
	Founder = 255
}

return Constants
