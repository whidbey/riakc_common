defmodule RiakcCommon.Tools.Time do  
  def current_time() do
    datetime = :calendar.universal_time()
    :calendar.datetime_to_gregorian_seconds(datetime)
  end
end