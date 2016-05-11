defmodule RiakcCommon.Tools.Version do  

  defp vsn(app) do
    Application.load(app)
    vsn = Application.spec(app,:vsn)
    vsn = List.to_string(vsn)
    String.split(vsn,".")
  end

  def major(app) do
    version = vsn(app)
    :lists.nth(1,version)
  end

  def mirror(app) do
    version = vsn(app)
    :lists.nth(2,version)
  end
  def revision(app) do
    version = vsn(app)
    :lists.nth(3,version)
  end

end