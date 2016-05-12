defmodule RiakcCommon.Tools.Version do  

  defp with_vsn(app,action) do
    Application.load(app)
    vsn = Application.spec(app,:vsn)
    if nil == vsn do 
      nil
    else
      vsn = List.to_string(vsn)
      vsn = String.split(vsn,".")
      action.(vsn)
    end
  end

  def major(app) do
    with_vsn(app, fn(version)->
      if length(version) >= 1 do
        :lists.nth(1,version)
      else 
        nil
      end
    end)
  end

  def mirror(app) do
    with_vsn(app, fn(version)->
      if length(version) >= 2 do
        :lists.nth(2,version)
      else
        nil
      end
    end)
  end
  
  def revision(app) do
    with_vsn(app, fn(version)->
      if length(version) >= 3 do
        :lists.nth(3,version)
      else
        nil
      end
    end)
  end

end