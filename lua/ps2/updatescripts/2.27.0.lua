local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

local function addCrateField( )
	return DB.FieldExistsInTable( "ps2_cratepersistence", "requireKey" )
	:Then( function( exists )
		if not exists then
			return DB.DoQuery( "ALTER TABLE `ps2_cratepersistence` ADD `requireKey` INT NOT NULL DEFAULT 1" )
		end
	end )
	:Then( function( )
		print( "\t Added column requireKey to ps2_cratepersistence" )
	end )
end

return DB.ConnectionPromise
:Then( function( )
	return DB.TableExists( 'ps2_cratepersistence' )
end )
:Then( function( shouldUpdate )
	KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "not need" )
	if shouldUpdate then
		return WhenAllFinished{ addCrateField() }
	else
		return Promise.Resolve( )
	end
end )
:Then( function( )	end, function( errid, err )
	KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
	return Promise.Reject( errid, err )
end )