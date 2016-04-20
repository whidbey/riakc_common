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
		timestamp = Integer.to_string(Time.current_time())
		key = data <> timestamp
		hash = :crypto.hash(:sha256,key)
		|> Base.encode16
		|> String.downcase 
		"#{hash}#{timestamp}"
	end

	def hash_of_timestamp_hash_256(hash) do
		String.slice(hash, 0,64)
	end

	def timestamp_of_timestamp_hash_256(hash) do
		len = String.length(hash) - 64
		String.slice(hash,64,len)
	end


end