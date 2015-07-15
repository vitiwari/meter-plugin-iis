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

local boundary = require('boundary')
local Emitter = require('core').Emitter
local Error = require('core').Error
local Object = require('core').Object
local Process = require('uv').Process
local timer = require('timer')
local math = require('math')
local string = require('string')
local os = require('os')
local CommandPlugin = require('framework').CommandPlugin
local table = require('table')
local io = require('io')
local fs = require('fs')

function splitLines(str, terminator)
	
	local lines = str:split(terminator)

	return lines
end

function parsePerformanceCounterLine(line)
	local parts = line:split(' : ')
	if (#parts ~= 2) then
		return nil
	end
	
	return parts[1], tonumber(parts[2])
end

local _map = {
--	{metric = 'IIS_GENERAL_CPU_USAGE', perfCounterIdString = '', perfCounterLocalname = '\\Processador(_Total)\\% Tempo de Processador'},
	{metric = 'IIS_GENERAL_CPU_USAGE', perfCounterIdString = '', perfCounterLocalname = '\\Processor(_Total)\\% Processor Time'},
	{metric = 'IIS_GENERAL_CPU_QUEUE_LENGTH', perfCounterIdString = '', perfCounterLocalname = '\\System\\Processor Queue Length'},
	{metric = 'IIS_GENERAL_MEMORY_FREE', perfCounterIdString = '', perfCounterLocalname = '\\Memory\\Available Bytes'},
	{metric = 'IIS_GENERAL_MEMORY_PAGE_PER_SECOND', perfCounterIdString = '', perfCounterLocalname = '\\Memory\\Pages/sec'},
	{metric = 'IIS_GENERAL_DISK_TIME', perfCounterIdString = '', perfCounterLocalname = '\\PhysicalDisk(_Total)\\% Disk Time'},
	{metric = 'IIS_ASPNET_REQUESTS_PER_SECOND', perfCounterIdString = '', perfCounterLocalname = '\\ASP.NET Applications(__Total__)\\Requests/Sec'},
	{metric = 'IIS_ASPNET_RESTARTS', perfCounterIdString = '', perfCounterLocalname ='\\ASP.NET\\Application Restarts'},
	{metric = 'IIS_ASPNET_REQUEST_WAIT_TIME', perfCounterIdString = '', perfCounterLocalname = '\\ASP.NET\\Request Wait Time'},
	{metric = 'IIS_ASPNET_REQUESTS_QUEUED', perfCounterIdString = '', perfCounterLocalname = '\\ASP.NET\\Requests Queued'},
	{metric = 'IIS_ASPNET_EXECPTIONS_THROWN_PER_SECOND', perfCounterIdString = '', perfCounterLocalname = '\\.NET CLR Exceptions(_Global_)\\# of Exceps Thrown / sec'},
	{metric = 'IIS_ASPNET_TOTAL_COMMITTED_BYTES', perfCounterIdString = '', perfCounterLocalname ='\\.NET CLR Memory(_Global_)\\# Total committed Bytes'},
	{metric = 'IIS_SERVICE_GET_REQUESTS_PER_SECOND', perfCounterIdString = '', perfCounterLocalname = '\\Web Service(_Total)\\Get Requests/sec'},
	{metric = 'IIS_SERVICE_POST_REQUESTS_PER_SECOND', perfCounterIdString = '', perfCounterLocalname = '\\Web Service(_Total)\\Post Requests/sec'},
	{metric = 'IIS_SERVICE_CURRENT_CONNECTIONS', perfCounterIdString = '', perfCounterLocalname = '\\Web Service(_Total)\\Current Connections'}
}

function concatPerformanceCounters(map)

	local performanceCounters = {}
		table.foreach(map, function (_, v)

			table.insert(performanceCounters, '"' .. v.perfCounterLocalname .. '"')
	end)

	return table.concat(performanceCounters, " ")
end

function parsePerformanceCounterMappingLine(line)

	local parts = line:split(' : ')

	return parts[1], parts[2]	
end

function getPerformanceCounterMapItem(map, pc)
	for k, v in pairs(map) do
		if v.perfCounterLocalname == pc then
			return v
		end
	end

	return nil
end


function getPerformanceCounterLocalnamesMap(map)

	local params = concatPerformanceCounters(map)
	--local proc = io.popen('powershell -NoProfile -File tools\\get-performance-counter-mapping.ps1 ' .. params)
	--local proc = io.popen('cat ./test/mapping.txt')
	local proc = fs.readFileSync('./test/mapping.txt')

	local output = proc:read('*a')
	proc:close()

	local result = {}
	local lines = splitLines(output, '\n')
	table.foreach(lines, function (_, l) 
		l = string.trim(l)
		if l:isEmpty() then
			return
		end

		local genericCounter, localCounter = parsePerformanceCounterMappingLine(l)
		local item = getPerformanceCounterMapItem(map, genericCounter) 
		if item then 
			item.perfCounterLocalname = localCounter
		end

		table.insert(result, item)
	end)

	return result
end

-- Update the performance counter map to local names
--_map = getPerformanceCounterLocalnamesMap(_map)

function cleanSpecialChars(str)
	local clean = string.gsub(str, '%%', '')
	clean = string.gsub(clean, '%(', '')
	clean = string.gsub(clean, '%)', '')

	return string.lower(clean)
end

function performanceCounterToMetric(performanceCounter, map)

	for k,v in pairs(map) do
	    local perf1 = cleanSpecialChars(performanceCounter)
	    local perf2 = cleanSpecialChars(v.perfCounterLocalname)
		local exists, _ = string.find(perf1, perf2) 
		if exists then
			return v.metric
		end
	end

	return nil
end

local params = boundary.param
params.name = 'Boundary IIS Plugin'
params.version = '1.0'
params.command = "powershell -NoProfile -File tools\\get-performance-counters.ps1 " .. concatPerformanceCounters(_map) 
--params.command = "cat test/lines.txt" 
--print(params.command)
local plugin = CommandPlugin:new(boundary.param)

function plugin:onParseCommandOutput(output)

	local delimiter = '\r\n'
	if os.type() == 'Linux' then
		delimiter = '\n'	
	end

	local lines = splitLines(output, delimiter)
	local result = {}
	table.foreach(lines, 
		function (_, l)

			local line = l:trim()
			if (line:isEmpty()) then
				return
			end

			local pc, val = parsePerformanceCounterLine(l)

			local metric = performanceCounterToMetric(pc, _map)
			if metric then
				result[metric] = val
			else
				p(pc .. ' does not has a metric associated.')
				p(_map)
			end


		end)
	
	return result

end
plugin:poll()

