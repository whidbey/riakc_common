defmodule RiakcCommon.Tools.Hash do  

	alias RiakcCommon.Tools.Time

	def get_hash_256(data) do
		:crypto.hash(:sha256,data)
		|> Base.encode16
		|> String.downcase 
	end


	def get_random_hash_256(data) do
		timestamps = Time.current_time()
		key = data <> to_string(timestamps)
		:crypto.hash(:sha256,key)
		|> Base.encode16
		|> String.downcase    
	end
	
	def get_timestamp_hash_256(data) do
		timestamps = Integer.to_string(Time.current_time())
		key = data <> timestamps
		hash = :crypto.hash(:sha256,key)
		|> Base.encode16
		|> String.downcase 
		timestamps <> "_" <> hash
	end


end