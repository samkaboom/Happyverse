local ServiceRetries = {}

function ServiceRetries.new(config)
	local DataStoreService = config.DataStoreService
	local MarketplaceService = config.MarketplaceService
	local InsertService = config.InsertService
	local TextService = config.TextService
	local CachedGamePassOwnership = config.CachedGamePassOwnership

	local LongOperationWarnSeconds = config.LongOperationWarnSeconds
	local DataStoreMaxRetries = config.DataStoreMaxRetries
	local DataStoreRetryDelay = config.DataStoreRetryDelay
	local DataStoreBudgetMaxWait = config.DataStoreBudgetMaxWait

	local operations = {}

	function operations.WarnLongOperation(label, startedAt)
		local elapsed = os.clock() - startedAt
		if elapsed >= LongOperationWarnSeconds then
			warn(label, "took", elapsed, "seconds")
		end
	end

	function operations.WaitForDataStoreBudget(requestType)
		local startedAt = os.clock()
		while true do
			local success, budget = pcall(function()
				return DataStoreService:GetRequestBudgetForRequestType(requestType)
			end)

			if not success then
				warn("GetRequestBudgetForRequestType failed", requestType, budget)
				return false
			end

			if budget >= 1 then
				return true
			end

			if os.clock() - startedAt >= DataStoreBudgetMaxWait then
				warn("Timed out waiting for datastore budget", requestType)
				return false
			end

			task.wait(DataStoreRetryDelay)
		end
	end

	function operations.SetAsyncInBackground(dataStore, key, value, label)
		task.spawn(function()
			local startedAt = os.clock()
			local success, response

			for attempt = 1, DataStoreMaxRetries do
				operations.WaitForDataStoreBudget(Enum.DataStoreRequestType.SetIncrementAsync)
				success, response = pcall(function()
					dataStore:SetAsync(key, value)
				end)

				if success then
					break
				end

				warn(label, "failed attempt", attempt, response)
				task.wait(DataStoreRetryDelay * attempt)
			end

			operations.WarnLongOperation(label, startedAt)
			if not success then
				warn(label, "failed after retries", response)
			end
		end)
	end

	function operations.GetAsyncWithBudget(dataStore, key, label)
		local startedAt = os.clock()
		local success, response

		for attempt = 1, DataStoreMaxRetries do
			operations.WaitForDataStoreBudget(Enum.DataStoreRequestType.GetAsync)
			success, response = pcall(function()
				return dataStore:GetAsync(key)
			end)

			if success then
				break
			end

			warn(label, "failed attempt", attempt, response)
			task.wait(DataStoreRetryDelay * attempt)
		end

		operations.WarnLongOperation(label, startedAt)
		if success then
			return true, response
		else
			warn(label, "failed after retries", response)
			return false, response
		end
	end

	function operations.UserOwnsGamePassWithCache(player, gamePassId)
		local cacheKey = tostring(player.UserId) .. "_" .. tostring(gamePassId)
		if CachedGamePassOwnership[cacheKey] ~= nil then
			return CachedGamePassOwnership[cacheKey]
		end

		local startedAt = os.clock()
		local success, ownsGamePass

		for attempt = 1, DataStoreMaxRetries do
			success, ownsGamePass = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
			end)

			if success then
				CachedGamePassOwnership[cacheKey] = ownsGamePass
				break
			end

			warn("UserOwnsGamePassAsync failed attempt", attempt, player.UserId, gamePassId, ownsGamePass)
			task.wait(DataStoreRetryDelay * attempt)
		end

		operations.WarnLongOperation("UserOwnsGamePassAsync", startedAt)
		if success then
			return ownsGamePass
		else
			warn("UserOwnsGamePassAsync failed after retries", player.UserId, gamePassId, ownsGamePass)
			return false
		end
	end

	function operations.LoadAssetWithRetry(assetId, label)
		local startedAt = os.clock()
		local success, asset

		for attempt = 1, DataStoreMaxRetries do
			success, asset = pcall(function()
				return InsertService:LoadAsset(assetId)
			end)

			if success then
				break
			end

			warn(label, "LoadAsset failed attempt", attempt, assetId, asset)
			task.wait(DataStoreRetryDelay * attempt)
		end

		operations.WarnLongOperation(label, startedAt)
		if success then
			return asset
		else
			warn(label, "LoadAsset failed after retries", assetId, asset)
			return nil
		end
	end

	function operations.FilterStringWithRetry(text, userId, label)
		local startedAt = os.clock()
		local success, textObject

		for attempt = 1, DataStoreMaxRetries do
			success, textObject = pcall(function()
				return TextService:FilterStringAsync(text, userId)
			end)

			if success then
				break
			end

			warn(label, "FilterStringAsync failed attempt", attempt, textObject)
			task.wait(DataStoreRetryDelay * attempt)
		end

		operations.WarnLongOperation(label, startedAt)
		if success then
			return textObject
		else
			warn(label, "FilterStringAsync failed after retries", textObject)
			return nil
		end
	end

	function operations.GetFilteredBroadcastTextWithRetry(textObject, label)
		local startedAt = os.clock()
		local success, filteredMessage

		for attempt = 1, DataStoreMaxRetries do
			success, filteredMessage = pcall(function()
				return textObject:GetNonChatStringForBroadcastAsync()
			end)

			if success then
				break
			end

			warn(label, "GetNonChatStringForBroadcastAsync failed attempt", attempt, filteredMessage)
			task.wait(DataStoreRetryDelay * attempt)
		end

		operations.WarnLongOperation(label, startedAt)
		if success then
			return filteredMessage
		else
			warn(label, "GetNonChatStringForBroadcastAsync failed after retries", filteredMessage)
			return false
		end
	end

	return operations
end

return ServiceRetries
