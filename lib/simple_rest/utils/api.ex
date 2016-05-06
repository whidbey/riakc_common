defmodule RiakcCommon.SimpleRest.Utils.API do
  def post(url,data,handler \\ nil ,headers\\[], opts \\ []) do
    response = HTTPoison.post(url,data,headers,opts)
    if nil == handler do
      response
    else
      handler.(response)
    end
  end
  
  def put(url,data,handler \\ nil ,headers\\[], opts \\ []) do
    response = HTTPoison.put(url,data,headers,opts)
    if nil == handler do
      response
    else
      handler.(response)
    end
  end
  def patch(url,data,handler \\ nil ,headers\\[], opts \\ []) do
    response = HTTPoison.patch(url,data,headers,opts)
    if nil == handler do
      response
    else
      handler.(response)
    end
  end

  def get(url,handler \\ nil ,headers\\[], opts \\ []) do
    response = HTTPoison.get(url,headers,opts)
    if nil == handler do
      response
    else
      handler.(response)
    end
  end

  def delete(url,handler \\ nil ,headers\\[], opts \\ []) do
    response = HTTPoison.delete(url,headers,opts)
    if nil == handler do
      response
    else
      handler.(response)
    end
  end

  
end
