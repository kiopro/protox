defmodule Protox.Protoc do

  @moduledoc false

  def run([proto_file]) do
    do_run([proto_file], ["-I", "#{proto_file |> Path.dirname() |> Path.expand()}"])
  end


  def run(proto_files) do
    do_run(proto_files, ["-I", "#{common_directory_path(proto_files)}"])
  end


  # -- Private


  defp do_run(proto_files, args) do
    outfile_name = "protox_#{Protox.Util.random_string()}"
    outfile_path = Path.join([Mix.Project.build_path(), outfile_name])
    cmd_args = ["--include_imports", "-o", outfile_path] ++ args ++ proto_files

    ret = case System.cmd("protoc", cmd_args) do
      {_, 0}   -> {:ok, File.read!(outfile_path)}
      {msg, _} -> {:error, msg}
    end

    :ok = File.rm(outfile_path)

    ret
  end


  defp common_directory_path(paths_rel) do
    paths = Enum.map(paths_rel, &Path.expand/1)

    min_path = paths |> Enum.min() |> Path.split()
    max_path = paths |> Enum.max() |> Path.split()

    min_path
    |> Enum.zip(max_path)
    |> Enum.take_while(fn {a, b} -> a == b end)
    |> Enum.map(fn {x, _} -> x end)
    |> Path.join()
  end

end
