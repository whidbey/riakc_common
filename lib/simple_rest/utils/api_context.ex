defmodule RiakcCommon.SimpleRest.Utils.APIContext do
  
  defstruct target: "", headers: [],
    opts: [], handler: nil  

  def new() do
    __MODULE__.__struct__
  end

end
