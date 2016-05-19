defmodule RiakcCommon.Beam.Spy do

  @spec disassemble(module) ::
          {:ok, asm_code :: [tuple], asm_file :: :file.path} | {:error, term}
  def disassemble(module) do
    case read_abstract_code(module) do
      {:ok, path, ac} ->
        case :compile.noenv_forms(ac, [:S]) do
          {:ok, _, {_erl_module, _exports, _attribs, asm_codes, _labels}} ->
            asm_dir  = :file.get_cwd |> elem 1
            asm_name = :filename.basename(path, '.beam') ++ '.S'
            {:ok, asm_codes, :filename.join(asm_dir, asm_name)}
          :error ->
            {:error, :unkown_compile_error}
          {:error, errors, warnings} ->
            {:error, {:compile_error, errors, warnings}}
        end
      {:error, _}=err ->
        err
    end
  end

  @spec disassemble_to_erl(module) :: :ok | {:error, term}
  def disassemble_to_erl(module) do
    case read_abstract_code(module) do
      {:ok, _path, ac} ->
        :erl_syntax.form_list(ac) |> :erl_prettypr.format |> IO.puts
        :ok
      {:error, _}=err ->
        err
    end
  end

  @spec read_abstract_code(module) :: {:ok, :file.path, [tuple]} | {:error, term}
  defp read_abstract_code(module) do
    case :code.which(module) do
      :non_existing ->
        {:error, {:non_existing, module}}
      path when is_list(path) ->
        case :beam_lib.chunks(path, [:abstract_code]) do
          {:ok, {_, [{:abstract_code, {_, ac}}]}} ->
            {:ok, path, ac}
          {:error, :bean_lib, reason} ->
            {:error, reason}
        end
    end
  end

end