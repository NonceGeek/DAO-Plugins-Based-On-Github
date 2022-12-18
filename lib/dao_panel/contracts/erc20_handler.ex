defmodule DAOPanel.Contracts.Erc20Handler do
    @moduledoc """
      handle with Erc20 Contract
    """

    @func %{
      name: "name",
      symbol: "symbol",
      decimals: "decimals",
      governance: "governance",
      transfer: "transfer",
      balance_of: "balanceOf",
      mint: "mint"
    }

    def get_abi() do
      "contracts/erc20/erc20.abi"
      |> File.read!()
      |> Poison.decode!()
    end

    def parse_event(tx_receipt_raw) do
      tx_receipt_atomed = ExStructTranslator.to_atom_struct(tx_receipt_raw)
      first_log =
        Enum.fetch!(tx_receipt_atomed.logs, 0)

      data = abstract_data(first_log)
      topics = abstract_topics(first_log)
      Ethereum.EventLog.decode(get_abi(), topics, data)
    end

    def abstract_data(%{data: data} = _log), do: data
    def abstract_topics(%{topics: topics = _log}), do: topics
  end
