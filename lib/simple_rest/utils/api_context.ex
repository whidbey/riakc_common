defmodule RiakcCommon.SimpleRest.Utils.ApiContext do
  
  defstruct target: "", headers: [],
    opts: [], handler: nil  

  def new() do
    __MODULE__.__struct__
  end

end
