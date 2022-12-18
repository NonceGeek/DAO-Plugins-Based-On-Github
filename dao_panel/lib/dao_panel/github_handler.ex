defmodule DAOPanel.GithubHandler do
  @doc """
    Handler things about github.
  """
  alias DAOPanel.Contracts.Erc20Handler

  @github_api "https://api.github.com"
  @client Tentacat.Client.new(%{access_token: Constants.get_github_token()})

  def get_repos(username, :user) do
    Http.http_get("#{@github_api}/users/#{username}/repos", Constants.get_github_token())
  end

  def get_repos(org_name, :org) do
    Http.http_get("#{@github_api}/orgs/#{org_name}/repos?sort=updated", Constants.get_github_token())
  end

  def analyze_repo(owner, repo_name, :issue) do
    elem(Tentacat.Issues.list(@client, owner, repo_name), 1)
  end

  def clean_data(data, :issue) do
    data
    |> Enum.map(fn elem ->
      elem_atomed =
        ExStructTranslator.to_atom_struct(elem)
      %{
        body: elem_atomed.body,
        labels: elem_atomed.labels,
        url: elem_atomed.html_url
      }
    end)
  end

  def clean_data(data, :repo) do
    data
    |> Enum.map(fn elem ->
      elem_atomed =
        ExStructTranslator.to_atom_struct(elem)
      %{
        name: elem_atomed.name,
        url: handle_git_url(elem_atomed.clone_url)
      }
    end)
  end

  def filter_issue_by_label(issues, label) do
    issues
    |> Enum.filter(fn %{labels: labels} ->
      labels |> Enum.any?(fn %{name: name} -> name==label end)
    end)
  end

  def handle_git_url(url), do: String.replace(url, ".git", "")

  # +-------------------------+
  # | Issue’s Text Abstractor |
  # +-------------------------+

  def abstract_money(txt) do
    do_abstract(txt, "Bounty")
  end

  def abstract_proof_link(txt) do
    do_abstract(txt, "Proof")
  end

  def abstract_chain(txt) do
    do_abstract(txt, "Chain")
  end

  def do_abstract(txt, key) do
    txt
    |> String.split("#{key}: `")
    |> Enum.fetch!(1)
    |> String.split("`")
    |> Enum.fetch!(0)
  end

  def abstract_tx_id(proof_link) do
    proof_link
    |> String.split("/")
    |> Enum.fetch!(-1)
  end

  def abstract_tx(txt) do
    tx_id =
      txt
      |> abstract_proof_link()
      |> abstract_tx_id()

    # chain =
    #  abstract_chain(txt)

    # tx_raw = Ethereumex.HttpClient.eth_get_transaction_by_hash(tx_id)
    {:ok, tx_receipt_raw} = Ethereumex.HttpClient.eth_get_transaction_receipt(tx_id)
    Erc20Handler.parse_event(tx_receipt_raw)
  end
end
