-- Create the table
local module = {}

-- services
local _DSS = game:GetService("DataStoreService")
local _HTTPS = game:GetService("HttpService")

-- basics
local _ItemDS = _DSS:GetOrderedDataStore("Items") -- stores ItemTemplate's
local _ShopDS = _DSS:GetOrderedDataStore("Shops") -- stores Shop's
local _GroupDS = _DSS:GetOrderedDataStore("Groups") -- stores Group's

local _Enum = {
	ItemCategory = {
		Melee = {
			Blunt = "Blunt",
			Sword = "Sword",
			Vibrosword = "Vibrosword",
			Chainsword = "Chainsword",
			Gauntlet = "Gauntlet",
			Explosive = "Explosive",
		},
		Projectile = {
			Kinetic = "Kinetic",
			Plasma = "Plasma",
			Electric = "Electric",
			Explosive = "Explosive",
			Thrower = "Thrower",
		},
		Utility = {
			Grapple = "Grapple",
			Spray = "Spray",
			Explosive = "Explosive",
			Stun = "Stun",
			Armor = "Armor",
		},
		Armor = {
			Head = "Head",
			Face = "Face",
			Arms = "Arms",
			Torso = "Torso",
			Legs = "Legs",
		},
		Cybernetic = {
			RightFoot = "RightFoot",
			LeftFoot = "LeftFoot",
			Feet = "Feet",
			RightCalf = "RightCalf",
			LeftCalf = "LeftCalf",
			Calves = "Calves",
			RightKnee = "RightKnee",
			LeftKnee = "LeftKnee",
			Knees = "Knees",
			RightThigh = "RightThigh",
			LeftThigh = "LeftThigh",
			Thighs = "Thighs",
			Hips = "Hips",
			LowerBack = "LowerBack",
			UpperBack = "UpperBack",
			Abdomen = "Abdomen",
			Chest = "Chest",
			RightShoulder = "RightShoulder",
			LeftShoulder = "LeftShoulder",
			Shoulders = "Shoulders",
			RightUpperArm = "RightUpperArm",
			LeftUpperArm = "LeftUpperArm",
			UpperArms = "UpperArms",
			RightForearm = "RightForearm",
			LeftForearm = "LeftForearm",
			Forearms = "Forearms",
			RightHand = "RightHand",
			LeftHand = "LeftHand",
			Hands = "Hands",
			Neck = "Neck",
			Spine = "Spine",
			Face = "Face",
			RightEye = "RightEye",
			LeftEye = "LeftEye",
			Eyes = "Eyes",
			RightEar = "RightEar",
			LeftEar = "LeftEar",
			Ears = "Ears",
			Skull = "Skull",
			Brain = "Brain",
			Other = "Other",
		},
		Clothing = {
			Jacket = "Jacket",
			Shirt = "Shirt",
			Pants = "Pants",
			Shorts = "Shorts",
			Shoes = "Shoes",
			Glasses = "Glasses",
			Hat = "Hat",
			Earphones = "Earphones",
			Belt = "Belt",
			Watch = "Watch",
			Band = "Band",
			Pauldron = "Pauldron",
			Rig = "Rig",
		}
	}
}

module._itemTemplateTable = {
	
}

module._itemTable = {
	
	new = function(self, object, 
		ItemInformation : {
			UniqueId : string, -- string
			ItemTemplateId : number, -- 7 digit int

			TemplateInformation : {

				MainCategory : string, -- string
				SubCategory : string , -- string
				Description : string, -- string
				ItemImage : number, -- asset id
				Name : string, -- string
				Creator : number, -- player UserId	
				isApproved : boolean, -- bool
				approvedBy : number, -- player UserId
			},

			Logs : {

			},
			
		})
		print(":new() called on itemTable")
		object = object or {}
		
		object.ItemInformation = ItemInformation or 
			{
				
				UniqueId = _HTTPS:GenerateGUID(false), -- string
				ItemTemplateId = 0, -- 7 digit int

				TemplateInformation = {

					MainCategory = "", -- string
					SubCategory = "", -- string
					Description = "", -- string
					ItemImage = 0, -- asset id
					Name = "", -- string
					Creator = 0, -- player UserId	
					isApproved = false, -- bool
					approvedBy = 0, -- player UserId
				},

				Logs = {

				},
				
			}
		
		
		setmetatable(object, self)
		self.__index = self
		
		return object
	end,
	
	ChangeCategory = function(self, Category : string, SubCategory : string)
		if not Category or SubCategory then error(":ChangeCategory() requires both Category and SubCategory to be stated") return end
		local Category = _Enum[Category]
		if not Category then error(Category, " is not a valid MainCategory type.") return end
		local SubCategory = Category[SubCategory]
		if not SubCategory then error(SubCategory, " is not a valid SubCategory type.") return end
		self.MainCategory = Category
		self.SubCategory = SubCategory
		return nil 
	end,
	
	AddLog = function(self, TransactionTable : { TransactionType : string, TiedUserId : number, Amount : number?})
		--[[
		format:
		{
			TransactionType -- string
			TiedUserId -- int
			Amount -- int if TransactionType is 'Purchase', otherwise nil
		}
		]]
		if #self.ItemInformation.Logs > 4 then
			for i, v in ipairs(self.ItemInformation.Logs) do
				if i > 4 then table.remove(self.Logs,i) end
			end
		end
		table.insert(self.ItemInformation.Logs, TransactionTable)
		
	end,
	
	-- Item information
	ItemInformation = {

		UniqueId = "", -- string
		ItemTemplateId = 0, -- 7 digit int
		
		TemplateInformation = {
			
			MainCategory = "", -- string
			SubCategory = "", -- string
			Description = "", -- string
			ItemImage = 0, -- asset id
			Name = "", -- string
			Creator = 0, -- player UserId	
			isApproved = false, -- bool
			approvedBy = 0, -- player UserId
		},
	
		Logs = {
			
		},
	},
	
	
	
}

local _characterProfileTable = {
	new = function (self, ProfileName : string, Name : string, Bio : string, PlayerUserId : number, AssociatedSaveSlots : {SaveSlotId : number}?)
		print(":new() called on characterProfileTable")
		local newTable = {}
		ProfileName = ProfileName or "Unnamed"
		
		AssociatedSaveSlots = AssociatedSaveSlots or {}
		PlayerUserId = PlayerUserId or 0
		newTable.AssociatedSaveSlots = AssociatedSaveSlots
		newTable.PlayerUserId = PlayerUserId

		setmetatable(newTable, self)
		self.__index = self

		return newTable
	end,
	
	ProfileInformation = {
		PlayerUserId = 0, -- player userid we're tied to
		CharacterProfileSlot = 0, -- number of the slot, basically the ID
		AssociatedSaveSlots = {}, -- contains the saveslots
		ProfileName = "Unnamed", -- named
		CharacterInformation = {
			["CharacterName"] = "",
			["CharacterBio"] = "",
			["CharacterImg"] = "",
			["EmpowermentType"] = "",
			["Empowerment"] = "",
			["EmpowermentTitle"] = "",
			["IsCustomEmpowerment"] = false,
			["Skills"] = {
				{}, {}, {}, {}, {}
			}
		},
		Credits = 0, -- credits associated with the account
		Inventory = {} -- holds itemTables
	}
	
}


local _groupTable = {
	
	Creator = {}, -- {PlayerUserId, CharacterProfileSlot}
	Owners = {}, -- {PlayerUserId, CharacterProfileSlot}
	Admins = {}, -- {PlayerUserId, CharacterProfileSlot}
	Members = {}, -- {PlayerUserId, CharacterProfileSlot}
	LinkedShop = {}, -- fill with shopTable
	PropertiesOwned = {}, -- {placeId : int, name : string}
	Credits = {
		Amount = 0, -- int
		TransactionLogs = {} -- {playerUserId : int, Amount : int, InOrOut : boolean}
	} -- int
	
}



local _shopItem = {
	
	AssociatedItem = {}, -- itemTable
	Price = 0, -- int
	forSale = false, -- bool
	
}

local _shopTable = {
	
	LinkedGroup = {}, -- fill with groupTable
	
	Items = {
		--- fill with shopItem's
	},
	
	
	
	
}



local selectedCategory
local selectedSubcategory

local module = {}

print("Indexing the economy module.")




return module
