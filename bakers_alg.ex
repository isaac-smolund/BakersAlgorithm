
defmodule Customer do
   def begin() do
      customer = spawn(__MODULE__, :loop, [:random.uniform(10000), :random.uniform(25)])
   end
   def start(customer) do
     send(customer, {:sleep})
   end
   def loop(wait, fib) do
    receive do
      {:sleep} ->
         :timer.sleep(wait)
         send(:manager, {:customer_ready, self()})
	 loop(wait, fib)
      {:pair_with_server, server} -> 
         IO.puts("Server #{inspect server} is now helping Customer #{inspect self} to calculate fib(#{fib})")
         send(server, {:calculate_fib, fib, self()})
         loop(wait, fib)
      {:print_fib, fib} -> 
         IO.puts("Customer #{inspect self} has recieved: #{fib}")
    end
end
end

defmodule Server do
   def begin() do
     server = spawn(__MODULE__, :loop, [])
     send(:manager, {:server_ready, server})
   end
   def loop do
     receive do
       {:calculate_fib, fibnum, customer} ->
          send(customer, {:print_fib, Fib.fib(fibnum)})
	  send(:manager, {:server_ready, self()})
     end
     loop
   end
end


# from https://gist.github.com/kyanny/2026028
defmodule Fib do 
  def fib(0) do 0 end
  def fib(1) do 1 end
  def fib(n) do fib(n-1) + fib(n-2) end
end
     
defmodule Manager do
  def begin() do
    manager = spawn(__MODULE__, :manage, [[], []])
    Process.register(manager, :manager)
  end
  def manage([], []) do
    receive do
      {:server_ready, server} ->
        manage([] ++ [server], [])
      {:customer_ready, customer} ->
        manage([], [] ++ [customer])
    end
  end
  def manage([first|servers], []) do
    receive do
      {:server_ready, server} ->
        manage([first] ++ servers ++ [server], [])
      {:customer_ready, customer} ->
        send(customer, {:pair_with_server, first})
        manage(servers, [])
    end
  end
  def manage([], [first|customers]) do
    receive do
      {:server_ready, server} ->
        send(first, {:pair_with_server, server})
        manage([], customers)
      {:customer_ready, customer} ->
        manage([], [first] ++ customers ++ [customer])
    end
  end
end




defmodule BakersAlg do
 def main() do
    Process.delete(:manager) 
    Manager.begin()
    server = Server.begin()
    server = Server.begin()
    server = Server.begin()
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
    Customer.start(Customer.begin());
  end
end
