local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- Avoid toggling Roblox's PlayerList CoreGui; Studio can throw inside CoreGui.Settings.Pages.Players.
print("TRYING TO GET TP UI")
local customLoadingScreen = TeleportService:GetArrivingTeleportGui()
if customLoadingScreen then
	print("LOADING SCREEN: TP UI FOUND!")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	customLoadingScreen.Parent = playerGui

	do
		local Fade = customLoadingScreen.Fade
		local Messages = {

			"You should read the Combat Rulebook. Like, seriously.",
			"Just about everything is sold by Mega-Corps on a digitally centralized marketplace, easily accessible via NIC. Anything else is peddled by Gangs, Bootleggers and Organized Criminal Syndicates.",
			"Critical Care becomes invalidated if death is registered within STATIC-ZONEs. Specially marked areas of the Y.CZ such as the Forest, Underground and Old City.",
			"Phones are no longer used across the world due to the development of the NIC (Neural Interface Computer) and PDA (Personal Digital Assistant).",
			"The Yukon Containment Zone is completely cut off from the outside world. Reasons as to why vary between who you ask, but most believe something terrible has struck the world at large.",
			"The water in The Limbs District is dangerously irradiated. Known to cause onset cancer to those who drink, or even swim too long in it.",
			"With the recent lack of imports entering the zone, food has become an extremely valuable resource.",
			"You should really relax and have some fun. :)",
			"Inside The Limbs District, LEAD is a place to buy firearms & install modifications.",
			"This community loves you for who you are.",
			"Contractance is by technicality, a job promotion website, however its become infamously known as a hub for bounty-hunting and wetwork. Aspiring mercenaries and bounty-hunters get their start here.",
			"The Empowered used to be known as “Expressionists” in the early to mid 20th century.",
			"Lifeline is an organization dedicated to assisting new arrivals within the Yukon Containment Zone.",
			"Your character matters.",
			"Fusion Credits are a globally recognized digital currency that often falls second to numerous countries regional currency.",

			"Augmenting the body too far beyond human capability can eventually cause onset Psychopotency. Make sure to take your Neurochem Stabalizers!",
			"Augmentation is split within three distinct categories; Cyberware, Bioweaving and Empowerments. Each have unique benefits and consequences.",
			"Cyberware and Bioweaving had become the worlds answer to a gradually growing Empowered population - Hitting the consumer markets in the early 2020s, its since become a movement that blurred the lines between Humanity and Empowered.",

			"A character's tier is not telling of their power, but of their influence, or how much roleplay they generate or serve towards other characters. The power that comes with it is a reward.",
			"Tiers judge the personal growth and influence of individual characters in their respective niches, and demonstrates this growth with power and potential.",
			"The cooler you make the other person feel during Combat RP, typically the cooler they'll try to make you feel.",
			
			"Terminal Group is lead by the Mornyl Family.",
			"Corporations follow a simple and universal system for rating the damage and penetration of firearms.",
			"Trypticon SynGas is the most commonly utilized form of fuel; a synthetic gasoline developed in the late 2020s by Trypticon as a replacement to traditional gasoline through the refinement of various agricultural stocks.",
			"Spawned out of a necessary merger between a myriad of Japanese automobile and industrial manufacturers, Nuyatsu is the brainchild of two young CEOs forming the company in the late 2010s after recent embargos and tariffs had been placed by the American Government originating from Japan.",
			"Union Motors AG is a European Conglomerate of vehicle manufactures that specializes in luxury and commercial vehicles. Its known to be the foremost investor to numerous F1 teams and sport at large.",
			"Ichiryu Corp were the first to design and patent the infamous Golemmech of the modern era, alongside numerous cybernetic advancements that placed them at the top of the eastern mechatronics market.",
			"Nuyatsu Motor Company is an Japanese company that specializes in reliable, JDM oriented sports cars and SUV's, reserved for people who prefer to modify their wheels.",
			"Terminal Group once started out as 'The Block Conglomerate', a local community venture designed to stave off MegaCorp influence on small businesses within Olde Mortar.",
			"Often said to be based entirely on the owner’s own personal grudges, Trypticon Biotechnologies is a company that has absorbed almost the entire agricultural sector.",
			"Space X dominated the space launch market in the 2020s, dissolving only after the mysterious disappearance of their CEO following the launch of their fourth Mars Bound mission.",
			"Led by the enigmatic man who prefers people address him as only the CEO, Teschmo Corp is a company that creates mass-manufactured weapons of war, oftentimes selling to several sides of the same conflict.",
			"Born out of a university crested cybernetic police officer program, AEGIS Macro-Technologies has gone on to dominate the western cybernetics market. Selling to all manner of paramedics, firefighters and police officers of the western world.",
			"Olde Mortar is under the sole ownership of Terminal Group.",
			"Pyrolyzer Energy, a Chinese weapons manufacturer, coined and patented the term for 'Absolver', a internationally licensed corporate mercenary for hire.",
			"Ikku Corp started out as members of 'The Block' (what came before Terminal Group) but parted in an effort to establish themselves as competitors rather than allies.",
			
			"The prime minister of Canada was assassinated in 2020, and the parliament building was burned in the same day.",
			"CHROMEBLOOD, a band started by Empowered in 2033, stands as one of the most popular musical groups within Yukon.",
			"The subterranean complexes of the Y.CZ are referred to as the 'Underside', acting as the dwelling of criminals and those looking to get away from under the Sectorates' and Mega-Corps' watchful eye.",
			"The Shaft is an industrial complex with air rendered nigh-unbreathable by pollutants.",
			"Faro is known as the 'Sleepless District' due to the tendency of its residents to constantly party.",
			"The Limbs District as its' known today, used to be home to several cryptids and anomalous entities. It was retaken in 2033 by a large group of Empowered, led by the late Shaftman.",
			"The Underside contains an expansive zone-wide metro system that was long abandoned by Sector One. Only returning to service by the efforts of an otherwise ambiguous criminal syndicate.",
			"The American Dragon is regarded as a staple of the Y.CZ dining scene. Founded in Murs de Fer, it's become a popular go-to for its signature in-house traditional Japanese ramen.",
			"Mutancy is a rare condition among Empowered, caused by excessive pollution and contaminants present in the air of the 21st century. Mutating the genome, and causing abnormal, inhuman characteristics.",
			"While Biofuel and Syngas dominate as the foremost fuel to Aerodynes, Automobiles and more, Liquid Nitrogen, Tesla Coils, Six Stroke and Nuclear Fission all make up viable, tangible fuel systems available on the consumer market.",
			
			"Ikku Corp started out as members of 'The Block Conglomerate' (what came before Terminal Group), but parted due to a difference of ideology, vision and ego. Becoming one another's greatest competitors in the ChromeVsMeat debate.",
			"Chevron-Chrysis-Carbon Automotives (C3A) is the oldest known car and industrial manufacturer in the world. Headquartered in San Antonio, Texas Free State, C3 specializes in heavy-duty Automobiles, All-Terrain-Vehicles and various Heavy-Construction-Equipment Machinery.",
			"Richardson Group Co is among the few MediaCorp giants that control the American market. Home to numerous renowned studios, design firms, news stations and claiming ownership to a majority of the American radiowave and webstream channels. They've put considerate stake into the development of the YCZs Faro District.",
			"Numerous types of Corporations exist within WoV; ManuCorps, AgriCorps, TechCorps, DigiCorps, SecCorps, ServiceCorps and BankCorps to name the most prominent."
			
		}
		Fade.msg.Text = Messages[math.random(1, #Messages)]
		Fade.Loading.Text = "Loading " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "..."
		spawn(function()
			local placename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
			repeat 
				
				wait(0.3333)
				Fade.Loading.Text = "Loading " .. placename .. "."
				wait(0.333)
				Fade.Loading.Text = "Loading " .. placename .. ".."
				wait(0.333)
				Fade.Loading.Text = "Loading " .. placename .. "..."
			until
			Fade.Visible == false
		end)
		local t=Players.LocalPlayer:WaitForChild("Loaded", 60)
		print("WE'RE LOADED")
		if not t then print("Test failed") end

		for i = 0, 1, 0.01 do
			wait(0.01)
			Fade.BackgroundTransparency = i
			Fade.Loading.TextTransparency = i
			Fade.msg.TextTransparency = i
		end
		Fade.Visible = false
	end

	customLoadingScreen:Destroy()
end
