-- Copyright 2015 Boundary, Inc.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local framework = require('framework')
local Plugin = framework.Plugin
local CommandOutputDataSource = framework.CommandOutputDataSource
local CachedDataSource = framework.CachedDataSource
local gsplit = framework.string.gsplit

local params = framework.params

local metrics_map = {
	['processor(_total)\\% processor time'] = 'IIS_GENERAL_CPU_USAGE',
	['system\\processor queue length'] = 'IIS_GENERAL_CPU_QUEUE_LENGTH',
	['memory\\available bytes'] = 'IIS_GENERAL_MEMORY_FREE',
	['memory\\pages/sec'] = 'IIS_GENERAL_MEMORY_PAGE_PER_SECOND',
	['physicaldisk(_total)\\% disk time'] = 'IIS_GENERAL_DISK_TIME',
	['asp.net applications(__total__)\\requests/sec'] = 'IIS_ASPNET_REQUESTS_PER_SECOND',
	['asp.net\\application restarts'] = 'IIS_ASPNET_RESTARTS',
	['asp.net\\request wait time'] = 'IIS_ASPNET_REQUEST_WAIT_TIME',
	['asp.net\\requests queued'] = 'IIS_ASPNET_REQUESTS_QUEUED',
	['.net clr exceptions(_global_)\\# of exceps thrown / sec'] = 'IIS_ASPNET_EXECPTIONS_THROWN_PER_SECOND',
	['.net clr memory(_global_)\\# total committed bytes'] = 'IIS_ASPNET_TOTAL_COMMITTED_BYTES',
	['web service(_total)\\get requests/sec'] = 'IIS_SERVICE_GET_REQUESTS_PER_SECOND',
	['web service(_total)\\post requests/sec'] = 'IIS_SERVICE_POST_REQUESTS_PER_SECOND',
	['web service(_total)\\current connections'] = 'IIS_SERVICE_CURRENT_CONNECTIONS'
}

local cmd = {
	path = "get_metrics_native.exe",
	args = {},
	use_popen = false
}

local ds = CommandOutputDataSource:new(cmd)

local plugin = Plugin:new(params, ds)

function plugin:onParseValues(data)
	local result = {}
	local output = data.output
	p(data.output)
	for v in gsplit(output, '\r\n') do
		local metric, value = v:match('(.+):([%d.?]+)')
		if metric and value then
			local boundary_metric = metrics_map[metric]
			if boundary_metric then
				result[boundary_metric] = tonumber(value)
			end
		end
	end
	return result
end
plugin:run()
