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
local gsplit = framework.string.gsplit

local params = framework.params

local metrics_map = {
	['processor(_total)\\% processor time'] = {'IIS_GENERAL_CPU_USAGE', 0.01},
	['system\\processor queue length'] = {'IIS_GENERAL_CPU_QUEUE_LENGTH', 1},
	['memory\\available bytes'] = {'IIS_GENERAL_MEMORY_FREE', 1},
	['memory\\pages/sec'] = {'IIS_GENERAL_MEMORY_PAGE_PER_SECOND', 1},
	['physicaldisk(_total)\\% disk time'] = {'IIS_GENERAL_DISK_TIME', 0.01},
	['asp.net applications(__total__)\\requests/sec'] = {'IIS_ASPNET_REQUESTS_PER_SECOND', 1},
	['asp.net\\application restarts'] = {'IIS_ASPNET_RESTARTS', 1},
	['asp.net\\request wait time'] = {'IIS_ASPNET_REQUEST_WAIT_TIME', 1},
	['asp.net\\requests queued'] = {'IIS_ASPNET_REQUESTS_QUEUED', 1},
	['.net clr exceptions(_global_)\\# of exceps thrown / sec'] = {'IIS_ASPNET_EXECPTIONS_THROWN_PER_SECOND', 1},
	['.net clr memory(_global_)\\# total committed bytes'] = {'IIS_ASPNET_TOTAL_COMMITTED_BYTES', 1},
	['web service(_total)\\get requests/sec'] = {'IIS_SERVICE_GET_REQUESTS_PER_SECOND', 1},
	['web service(_total)\\post requests/sec'] = {'IIS_SERVICE_POST_REQUESTS_PER_SECOND', 1},
	['web service(_total)\\current connections'] = {'IIS_SERVICE_CURRENT_CONNECTIONS', 1}
}

local cmd = {
	path = "get_metrics_native.exe",
	args = {},
	use_popen = true -- On windows if a process outputs to stderr then stdout does not flush as expected, also if stdout is forced to be non-buffered.
}

local ds = CommandOutputDataSource:new(cmd)

local plugin = Plugin:new(params, ds)

function plugin:onParseValues(data)
	local result = {}
	local output = data.output
	for v in gsplit(output, '\r\n') do
		local metric, value = v:match('(.+):([%d.?]+)')
		if metric and value then
			local boundary_metric = metrics_map[metric][1]
      local factor = metrics_map[metric][2]
			if boundary_metric then
				result[boundary_metric] = tonumber(value) * factor
			end
		end
	end
	return result
end
plugin:run()
