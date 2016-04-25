defmodule RiakcCommon.Tools.Data do  

  def struct_to_map(struct,opts \\ []) do
    if Keyword.has_key?(opts, :string_key) do
      transform_struct(struct,opts[:string_key])
    else
      transform_struct(struct,true)
    end
  end

  defp transform_struct(struct,true) do
    Map.from_struct(struct)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      if Kernel.is_atom(key) do
        Map.put(acc,Atom.to_string(key),value)
      else
        Map.put(acc,key,value)
      end
    end)

  end
  
  defp transform_struct(struct,false) do
    Map.from_struct(struct)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      if Kernel.is_bitstring(key) do
        Map.put(acc,String.to_atom(key),value)
      else
        Map.put(acc,key,value)
      end
    end)
  end

end