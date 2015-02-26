local string = require('string')
local table = require('table')


local lib = {}

function string.split(self, inSplitPattern, outResults )

   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end

function string.trim(self)
   return string.match(self,"^()%s*$") and "" or string.match(self,"^%s*(.*%S)" )
end

function string.isEmpty(self)
	local s = self:trim()
	return (s == nil or s == '')
end

lib.split = string.split
lib.trim = string.trim

return lib
