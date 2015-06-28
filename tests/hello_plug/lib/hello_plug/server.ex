defmodule HelloPlug.Server do
  def start_link do
    Plug.Adapters.Cowboy.http HelloPlug.App, []
  end
end
