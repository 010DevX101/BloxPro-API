--!strict
local HttpService = game:GetService("HttpService")
local BASE_URL = "https://api.bloxpro.co.uk/v1"
local API_KEY = HttpService:GetSecret("BloxProKey")
local GUILD_ID = HttpService:GetSecret("BloxProGuild")

if not game:GetService("RunService"):IsServer() then
	error("BloxPro API wrapper can only be used on the server!")
end

export type GetXPResult = {
	xp: number,
	username: string
}
export type GetMedalsResult = {
	medalIds: {string},
	username: string
}
export type GetBlacklistsResult = {
	Blacklists: {string}
}
export type GetUserQualificationsResult = {
	qualifications: {string},
	username: string?
}
export type GetQualificationsResult = {
	Qualifications: {string}
}
export type GetQuotaResult = {
	InactivityNotices: boolean,
	QuotaPoints: number
}
export type GetRecordsResult = {
	records: {string},
	username: string
}

local defaultHeaders = {
	token = API_KEY,
	guildId = GUILD_ID
}

local function merge(...: {[string]: any}): {[string]: any}
	local merged = {}
	for _, table in {...} do
		for key, value in table do
			merged[key] = value
		end
	end
	return merged
end

local function get<T>(endpoint: string, headers: {[string]: any}?): T?
	headers = headers and merge(defaultHeaders, headers) or defaultHeaders
	local success: boolean, result: string = xpcall(function()
		return HttpService:GetAsync(`{BASE_URL}{endpoint}`, false, headers)
	end, function(err: string)
        warn(`[BloxPro API]: Failed to perform GET request on endpoint {endpoint} with headers {headers}. Error: {err}`)
	end)
	if not success then
		return nil
	end
	return HttpService:JSONDecode(result) :: T
end

local function post<T>(endpoint: string, headers: {[string]: any}?, body: {[string]: any}?): T?
	headers = headers and merge(defaultHeaders, headers) or defaultHeaders
	local success: boolean, result: string = xpcall(function()
		return HttpService:PostAsync(
			`{BASE_URL}{endpoint}`,
			HttpService:JSONEncode(body or {}),
			Enum.HttpContentType.ApplicationJson,
			false,
			headers
		)
	end, function(err: string)
        warn(`[BloxPro API]: Failed to perform POST request on endpoint {endpoint} with headers {headers} and body {body}. Error: {err}`)
	end)
    if not success then
        return nil
    end
	return HttpService:JSONDecode(result) :: T
end

local BloxProAPI = {}

function BloxProAPI:getXP(userId: number): GetXPResult?
	return get(`/xp/{userId}`)
end
function BloxProAPI:getMedals(userId: number): GetMedalsResult?
	return get(`/medals/{userId}`)
end
function BloxProAPI:getBlacklists(): GetBlacklistsResult?
	return get(`/blacklist`)
end
function BloxProAPI:getUserQualifications(userId: number): GetUserQualificationsResult?
	return get(`/qualifications/{userId}`)
end
function BloxProAPI:getQualifications(): GetQualificationsResult?
	return get("/qualifications")
end
function BloxProAPI:getQuota(userId: number): GetQuotaResult?
	return get(`/quota/{userId}`)
end
function BloxProAPI:getRecords(userId: number): GetRecordsResult?
	return get(`/records/{userId}`)
end
function BloxProAPI:setXP(userId: number, amount: number): any
	return post(`/xp/{userId}`, {amount = tostring(amount), method = "set"})
end
function BloxProAPI:addXP(userId: number, amount: number): any
	return post(`/xp/{userId}`, {amount = tostring(amount), method = "add"})
end
function BloxProAPI:removeXP(userId: number, amount: number): any
	return post(`/xp/{userId}`, {amount = tostring(amount), method = "remove"})
end
function BloxProAPI:assignMedal(userId: number, medalId: string): any
	return post(`/medals/{userId}`, {medalId = medalId, method = "assign"})
end
function BloxProAPI:revokeMedal(userId: number, medalId: string): any
	return post(`/medals/{userId}`, {medalId = medalId, method = "revoke"})
end
function BloxProAPI:assignQualification(userId: number, qualificationId: string): any
	return post(`/qualifications/{userId}`, {qualificationId = qualificationId, method = "assign"})
end
function BloxProAPI:revokeQualification(userId: number, qualificationId: string): any
	return post(`/qualifications/{userId}`, {qualificationId = qualificationId, method = "revoke"})
end

return BloxProAPI
