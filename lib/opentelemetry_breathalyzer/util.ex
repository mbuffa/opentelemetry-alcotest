defmodule OpentelemetryBreathalyzer.Util do
  @moduledoc false
  def append(list, item, condition_fct \\ fn -> true end)
      when is_list(list) and is_tuple(item) and is_function(condition_fct) do
    if condition_fct.() do
      [item | list]
    else
      list
    end
  end

  def append_lazy(list, append_fct, condition_fct \\ fn -> true end)
      when is_list(list) and is_function(append_fct) and is_function(condition_fct) do
    if condition_fct.() do
      [append_fct.() | list]
    else
      list
    end
  end
end
