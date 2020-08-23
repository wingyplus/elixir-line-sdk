defmodule LINELoginCmd.Plug do
  @moduledoc """
  Plug api to handle LINE OAuth callback.
  """

  alias LINELoginCmd.CodeState

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn.query_string
    |> Plug.Conn.Query.decode()
    |> Map.get("code")
    |> CodeState.store_code()

    send_resp(conn, 200, "Code received")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end

defmodule LINELoginCmd.CodeState do
  @moduledoc """
  OAuth code state management.
  """
  use GenServer

  # Client API

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Store code into code state.
  """
  def store_code(code) do
    GenServer.cast(__MODULE__, {:store_code, code})
  end

  @doc """
  Get the code from code state.
  """
  def get_code() do
    GenServer.call(__MODULE__, :get_code)
  end

  @doc """
  Polling the code until it available.
  """
  def polling_code() do
    case get_code() do
      :nocode ->
        polling_code()

      {:ok, code} ->
        code
    end
  end

  def clear() do
    GenServer.call(__MODULE__, :clear)
  end

  # Server API

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_cast({:store_code, code}, state) do
    {:noreply, Map.put(state, :code, code)}
  end

  @impl true
  def handle_call(:get_code, _from, %{code: code} = state) do
    {:reply, {:ok, code}, state}
  end

  @impl true
  def handle_call(:get_code, _from, state) do
    {:reply, :nocode, state}
  end

  @impl true
  def handle_call(:clear, _from, _state) do
    {:reply, :ok, %{}}
  end
end

defmodule LINELoginCmd.Application do
  def start_link() do
    children = [
      {LINELoginCmd.CodeState, []},
      {Plug.Cowboy, scheme: :http, plug: LINELoginCmd.Plug, options: [port: 12345]}
    ]

    opts = [strategy: :one_for_one, name: LINELoginCmd.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
