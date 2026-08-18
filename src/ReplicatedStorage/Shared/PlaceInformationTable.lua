-- PlaceInformationTable: single source of truth for all place metadata
-- Used by both server (Multiverse) and client (server browser UI)

local PlaceInformationTable = {
	-- Major locations
	[16022954380] = {
		Name = "The Shallows",
		DisplayImage = 0,
		Description = "",
	},
	[76800883465932] = {
		Name = "Harmonic Vault",
		DisplayImage = 0,
		Description = "",
	},
	[133726169233993] = {
		Name = "Obsidian Shrine",
		DisplayImage = 0,
		Description = "",
	},
	[70549089948008] = {
		Name = "The Witherholt",
		DisplayImage = 0,
		Description = "",
	},
	[14450222064] = {
		Name = "Castellan Ward",
		DisplayImage = 0,
		Description = "",
	},
	[16820101062] = {
		Name = "Blacksmoke",
		DisplayImage = 0,
		Description = "",
	},
	[16737334026] = {
		Name = "Watcher's Row",
		DisplayImage = 0,
		Description = "",
	},
	[127880360332494] = {
		Name = "Library of Alabastra",
		DisplayImage = 0,
		Description = "",
	},
	[120313151037448] = {
		Name = "The Mindwraith",
		DisplayImage = 0,
		Description = "",
	},
	[123482208262598] = {
		Name = "Core of Creation",
		DisplayImage = 0,
		Description = "",
	},
	[119803004897276] = {
		Name = "Yellow Abbey",
		DisplayImage = 0,
		Description = "",
	},
	[112332753872711] = {
		Name = "Sunken Moth",
		DisplayImage = 0,
		Description = "",
	},
	[84063695355472] = {
		Name = "Fort Dawn",
		DisplayImage = 0,
		Description = "",
	},
	[90763476777088] = {
		Name = "In-Between",
		DisplayImage = 0,
		Description = "",
	},
	[96473183100769] = {
		Name = "Ashen Crucible",
		DisplayImage = 0,
		Description = "",
	},
	[79292773154512] = {
		Name = "Orkney Rising",
		DisplayImage = 0,
		Description = "",
	},
	[108910128947424] = {
		Name = "New Messina",
		DisplayImage = 0,
		Description = "",
	},
	[107129351430752] = {
		Name = "Hall of Jubilation",
		DisplayImage = 0,
		Description = "",
	},
	[104785274421883] = {
		Name = "Stillwater Apartments",
		DisplayImage = 0,
		Description = "",
	},
	[109702489786758] = {
		Name = "Marbrick Forest",
		DisplayImage = 0,
		Description = "",
	},
	[133750941421087] = {
		Name = "Blackstone Mineshaft",
		DisplayImage = 0,
		Description = "",
	},
	[95468475320806] = {
		Name = "Lin Jun City",
		DisplayImage = 76573068304304,
		Description = "",
	},
	[78022774582045] = {
		Name = "The Brewed Awakening",
		DisplayImage = 102408416153595,
		Description = "",
	},
	[87639394171191] = {
		Name = "St. Jiang Lian's Cathedral",
		DisplayImage = 84024762759817,
		Description = "",
	},
	[134062149028327] = {
		Name = "Lin Jun Residential",
		DisplayImage = 98994388555426,
		Description = "",
	},
	[108983354484264] = {
		Name = "Sunspire Library",
		DisplayImage = 0,
		Description = "",
	},
	[133916187791199] = {
		Name = "Tian Di Palace",
		DisplayImage = 0,
		Description = "",
	},
	[96013919143783] = {
		Name = "Veiled Emporium",
		DisplayImage = 0,
		Description = "",
	},
	[131426189085289] = {
		Name = "The Airship",
		DisplayImage = 0,
		Description = "",
	},
	[82970261751299] = {
		Name = "The Train",
		DisplayImage = 0,
		Description = "",
	},
	[124344702839053] = {
		Name = "Rotstone",
		DisplayImage = 0,
		Description = "",
	},
	[132298553099601] = {
		Name = "BSNFLK Bop",
		DisplayImage = 0,
		Description = "",
	},
	[73687410995256] = {
		Name = "Howling Wolf",
		DisplayImage = 0,
		Description = "",
	},
	[119440617660843] = {
		Name = "Council Hall",
		DisplayImage = 0,
		Description = "",
	},
	[123996615578683] = {
		Name = "St. Althea's Cathedral",
		DisplayImage = 0,
		Description = "",
	},
	[18698171098] = {
		Name = "The Gala",
		DisplayImage = 0,
		Description = "",
	},
	[117944198445997] = {
		Name = "Dawn",
		DisplayImage = 0,
		Description = "",
	},
	[16335093772] = {
		Name = "Event Areas",
		DisplayImage = 0,
		Description = "",
	},
	[86995293172733] = {
		Name = "Blacksmoke",
		DisplayImage = 135421909815035,
		Description = "",
	},
	[94153612486163] = {
		Name = "Archway Grotto (Marbrick)",
		DisplayImage = 0,
		Description = "",
	},

	-- Core places
	[13501188035] = {
		Name = "Coding Studio 1",
		DisplayImage = 0,
		Description = "A coding studio",
	},
	[12822869744] = {
		Name = "Lobby",
		DisplayImage = 0,
		Description = "Main",
	},
	[13516290197] = {
		Name = "Messina",
		DisplayImage = 14573892892,
		Description = "Main",
	},
	[13516289815] = {
		Name = "Customization Room",
		DisplayImage = 0,
		Description = "Main",
	},
	[15889165808] = {
		Name = "Saint Adram",
		DisplayImage = 0,
		Description = "",
	},
	[13546912069] = {
		Name = "Vale of Cinder",
		DisplayImage = 0,
		Description = "The Deadlands",
	},
	[14536242217] = {
		Name = "Basinfolk",
		DisplayImage = 0,
		Description = "The Deadlands",
	},

	-- Archelm homes (1-35)
	[14573368083] = { Name = "Home", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14573425543] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Archelm" },
	[14573462989] = { Name = "Home", DisplayImage = 14573867906, Description = "A home within Archelm" },
	[14573490722] = { Name = "Home", DisplayImage = 14573867636, Description = "A home within Archelm" },
	[14573503670] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Archelm" },
	[14583861075] = { Name = "Home", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14583890154] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Archelm" },
	[14583911927] = { Name = "Home", DisplayImage = 14573867636, Description = "A home within Archelm" },
	[14583966895] = { Name = "Home", DisplayImage = 14573867906, Description = "A home within Archelm" },
	[14584009099] = { Name = "Throne Room", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14584029109] = { Name = "The Manor", DisplayImage = 14573867471, Description = "A home for Archelm's Elite" },
	[14584076184] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Archelm" },
	[14584095821] = { Name = "Station Orion", DisplayImage = 14573868105, Description = "The Center of Transportation" },
	[14584128094] = { Name = "Home", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14584162291] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Archelm" },
	[14584196339] = { Name = "Home", DisplayImage = 14573867906, Description = "A home within Archelm" },
	[14584246178] = { Name = "Home", DisplayImage = 14573867906, Description = "A home within Archelm" },
	[14584293320] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Archelm" },
	[14584335800] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Archelm" },
	[14584367280] = { Name = "Home", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14584437001] = { Name = "Home", DisplayImage = 14573867636, Description = "A home within Archelm" },
	[14584470521] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Archelm" },
	[14584502091] = { Name = "Home", DisplayImage = 14573867906, Description = "A home within Archelm" },
	[14584533229] = { Name = "Home", DisplayImage = 14573867906, Description = "A home within Archelm" },
	[14584567998] = { Name = "Home", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14584653101] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Archelm" },
	[14584692185] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Archelm" },
	[14584720219] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Archelm" },
	[14584756869] = { Name = "Home", DisplayImage = 14573867906, Description = "A home within Archelm" },
	[14584794863] = { Name = "Home", DisplayImage = 14573867636, Description = "A home within Archelm" },
	[14585015793] = { Name = "Home", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14585034285] = { Name = "Home", DisplayImage = 14573868359, Description = "A home within Archelm" },
	[14585058641] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Archelm" },
	[14585085882] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Archelm" },
	[14585174588] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Archelm" },

	-- Basinfolk homes (36-38)
	[14652247271] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Basinfolk" },
	[14652287644] = { Name = "Home", DisplayImage = 14573868105, Description = "A home within Basinfolk" },
	[14652319048] = { Name = "Home", DisplayImage = 14573867471, Description = "A home within Basinfolk" },

	-- Special locations
	[14621341731] = { Name = "The Inn", DisplayImage = 14621771536, Description = "A tavern within Archelm" },
	[15090002937] = { Name = "The Academy", DisplayImage = 0, Description = "" },
	[14549103090] = { Name = "The Bank", DisplayImage = 0, Description = "" },
	[15381264997] = { Name = "The Underhelm", DisplayImage = 0, Description = "" },
	[14649892844] = { Name = "The Courthouse", DisplayImage = 15382255209, Description = "" },
	[15432964046] = { Name = "Sunscorched Arena", DisplayImage = 0, Description = "" },
}

return PlaceInformationTable
