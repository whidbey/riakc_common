defmodule RiakcCommon.Tools.Identity do  

  alias RiakcCommon.Tools.Hash

  @default_partations 4096
  @default_seed 2147368987

  defp generate_partation(key,seed \\ nil, partations \\ nil) do
    murmur_hash_seed = seed || @default_seed
    murmur_hash_partations = partations || @default_partations

    hash = Murmur.hash_x86_32(key,murmur_hash_seed)
    par = Kernel.rem(hash,murmur_hash_partations)

    Integer.to_string(par)
  end
  
  def generate_with_partation(prefix,partation,data) do
    hash = Hash.get_timestamp_hash_256(data)
    "#{prefix}_#{partation}_#{hash}"
  end

  def generate_with_key(prefix,key,data,seed \\ nil, partations \\ nil) do
    partation = generate_partation(key,seed,partations)
    hash = Hash.get_timestamp_hash_256(data)
    "#{prefix}_#{partation}_#{hash}"
  end

  def partation(id) do
    list = String.split(id, "_")
    len = length(list) - 2 
    {:ok,partation} = Enum.fetch(list,len)
    partation
  end

  def hash(id) do
    list = String.split(id,"_")
    len = length(list) - 1
    {:ok,hash} = Enum.fetch(list,len)
    hash
  end
end