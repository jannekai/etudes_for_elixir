
defmodule Dijkstra do

	def gcd(m, n) when m == n, do: m
	def gcd(m, n) when m > n, do: gcd(m-n, n)
	def gcd(m,n), do: gcd(m, n-m)

	def gcd2(m, n) do
		cond do
			m == n -> m
			m > n -> gcd2(m-n, n)
			true -> gcd2(m, n-m)
		end
	end

end

defmodule Powers do
	
	import Kernel, except: [raise: 2]

	def raise(x, n) do
		cond do
			n == 0 -> 1
			n == 1 -> x
			n >= 0 -> x * raise(x, n-1)
			true -> 1.0 / raise(x, -n)
		end
	end

	def raise_acc(x, n) when n == 0, do: 1
	def raise_acc(x, n) when n < 0, do: 1.0 / raise_acc(x, -n)
	def raise_acc(x, n), do: raise_acc(x, n, 1)
	
	defp raise_acc(x, n, acc) when n == 0, do: acc
	defp raise_acc(x, n, acc), do: raise_acc(x, n-1, x * acc)

	def nth_root(x, n), do: nth_root(x, n, x / 2.0)
	defp nth_root(x, n, estimate) do
		f = raise_acc(estimate, n) - x
		f_prime = n * raise_acc(estimate, n-1)
		next = estimate - f / f_prime
		change = abs(next - estimate)

		IO.puts "estimate: #{estimate} next: #{next} change: #{change} f: #{f} f_prime: #{f_prime}"


		if change < 1.0e-8 do
			next
		else
			
			nth_root(x, n, next)
		end
	end
end

IO.puts Dijkstra.gcd(2, 8)
IO.puts Dijkstra.gcd2(2, 8)
IO.puts Dijkstra.gcd(14, 21)
IO.puts Dijkstra.gcd2(14, 21)
IO.puts Dijkstra.gcd(125, 46)
IO.puts Dijkstra.gcd2(125, 46)
IO.puts Dijkstra.gcd(120, 36)
IO.puts Dijkstra.gcd2(120, 36)
IO.puts ""

IO.puts Powers.raise(5,1)
IO.puts Powers.raise_acc(5,1)
IO.puts Powers.raise(2,3)
IO.puts Powers.raise_acc(2,3)
IO.puts Powers.raise(1.2, 3)
IO.puts Powers.raise_acc(1.2, 3)
IO.puts Powers.raise(2, 0)
IO.puts Powers.raise_acc(2, 0)
IO.puts Powers.raise(2, -3)
IO.puts Powers.raise_acc(2, -3)
IO.puts ""

Powers.nth_root(27, 3)

