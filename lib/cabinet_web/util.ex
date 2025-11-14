defmodule CabinetWeb.Util do
  def format_date(%Date{} = date), do: Calendar.strftime(date, "%b %d, %Y")

  defp remove_spaces(text) when is_binary(text), do: Regex.replace(~r/\s/u, text, "")

  def format_refnum(num) when is_integer(num) do
    "INV-" <> String.pad_leading(to_string(num), 4, "0")
  end

  def format_bsb(bsb) when is_binary(bsb) do
    bsb
    |> remove_spaces()
    |> String.to_charlist()
    |> format_bsb()
  end

  def format_bsb(bsb) when is_integer(bsb), do: format_bsb(Integer.to_charlist(bsb))

  def format_bsb(bsb) when is_list(bsb) do
    bsb
    |> Enum.chunk_every(3)
    |> Enum.join(" ")
  end

  def format_abn(abn) when is_binary(abn) do
    abn
    |> remove_spaces()
    |> String.to_charlist()
    |> format_abn()
  end

  def format_abn(abn) when is_integer(abn), do: format_abn(Integer.to_charlist(abn))

  def format_abn(abn) when is_list(abn) do
    {head, rest} = Enum.split(abn, 2)
    parts = [head] ++ Enum.chunk_every(rest, 3)

    Enum.join(parts, " ")
  end

  def address_lines(nil), do: []
  def address_lines(address), do: String.split(address, "\n", trim: true)
end
