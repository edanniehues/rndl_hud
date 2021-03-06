defmodule RNDL.Simulator do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: RNDL.Simulator)
  end

  def init(:ok) do
    :timer.send_interval(50, self(), :update)
#    {:ok, :stopped}
  end

  def stop do
    GenServer.call(RNDL.Simulator, {:stop})
  end

  def start do
    GenServer.call(RNDL.Simulator, {:start})
  end

  def handle_info(:update, :stopped) do
    {:noreply, :stopped}
  end

  def handle_info(:update, timer) do
    %{rpm: rpm} = RNDL.StateServer.get_state()
    rpm = if rpm >= 7000, do: 0, else: rpm + 77
    RNDL.StateServer.set(:rpm, rpm)
    RNDL.StateServer.set(:speed, (rpm/7000)*150)
    {:noreply, timer}
  end

  def handle_call({:stop}, _, timer) do
    {:ok, _} = :timer.cancel(timer)
    {:reply, :stopped, :stopped}
  end

  def handle_call({:start}, _, :stopped) do
    {:ok, timer} = init(:ok)
    {:reply, timer, timer}
  end
end
