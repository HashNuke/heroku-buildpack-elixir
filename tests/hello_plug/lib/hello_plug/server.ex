defmodule HelloPlug.Server do
  def start_link do
    port = ( System.get_env("PORT") || "4000" )
    |> String.to_integer

    Plug.Adapters.Cowboy.http HelloPlug.App, [], port: port
  end
end
