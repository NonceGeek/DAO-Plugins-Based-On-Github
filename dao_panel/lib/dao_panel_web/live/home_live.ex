defmodule DAOPanelWeb.HomeLive do
    alias DAOPanel.GithubHandler

    use DAOPanelWeb, :live_view


    @impl true
    def mount(_params, _session, socket) do
      {:ok,
       assign(socket,
        modal: false,
        slide_over: false,
        pagination_page: 1,
        active_tab: :home,
       )}
    end
    @impl true
    def handle_params(%{"search_input" => %{"text_input" => org_name, "select" => selected_repo}}, _uri, socket) do
      try do
        {:ok, repos} =
          GithubHandler.get_repos(org_name, :org)
        repos_cleaned_list =
          repos
          |> GithubHandler.clean_data(:repo)
          |> Enum.map(fn %{name: name} ->
            name
          end)

        # analyze repo here.
        issues_cleaned =
          org_name
          |> GithubHandler.analyze_repo(selected_repo, :issue)
          |> GithubHandler.clean_data(:issue)
        issues_with_reward =
          GithubHandler.filter_issue_by_label(issues_cleaned, "has reward")
        issues_paid =
          GithubHandler.filter_issue_by_label(issues_cleaned, "paid money")
        issues_paid_handled =
          handle_issues_paid(issues_paid)

        {
          :noreply,
          socket
          |> assign(:repos_cleaned_list, repos_cleaned_list)
          |> assign(:org_name_value, org_name)
          |> assign(:selected_repo, selected_repo)
          |> assign(:issues_cleaned, issues_cleaned)
          |> assign(:issues_with_reward, issues_with_reward)
          |> assign(:issues_paid, issues_paid_handled)
        }
      rescue
      _ ->
          {
            :noreply,
            socket
            |> assign(:org_name_value, org_name)
            |> assign(:repos_cleaned_list, nil)
            |> assign(:selected_repo, nil)
            |> assign(:issues_cleaned, [])
            |> assign(:issues_with_reward, [])
            |> assign(:issues_paid, [])
          }
      end
    end

    def handle_issues_paid(issues) do
      Enum.map(issues, fn %{body: body} = issue ->
        tx_parsed = GithubHandler.abstract_tx(body)
        Map.put(issue, :tx_parsed, tx_parsed)
      end)
    end

    def handle_params(%{"search_input" => %{"text_input" => org_name}}, _uri, socket) do
      try do
        {:ok, repos} =
          GithubHandler.get_repos(org_name, :org)
        repos_cleaned_list =
          repos
          |> GithubHandler.clean_data(:repo)
          |> Enum.map(fn %{name: name} ->
            name
          end)
        {
          :noreply,
          socket
          |> assign(:repos_cleaned_list, repos_cleaned_list)
          |> assign(:org_name_value, org_name)
          |> assign(:selected_repo, nil)
          |> assign(:issues_cleaned, [])
          |> assign(:issues_with_reward, [])
          |> assign(:issues_paid, [])
        }
      rescue
      _ ->
          {
            :noreply,
            socket
            |> assign(:org_name_value, org_name)
            |> assign(:repos_cleaned_list, nil)
            |> assign(:selected_repo, nil)
            |> assign(:issues_cleaned, [])
            |> assign(:issues_with_reward, [])
            |> assign(:issues_paid, [])
          }
      end
    end

    def handle_params(params, _uri, socket) do
      {
        :noreply,
        socket
        |> assign(:org_name_value, "")
        |> assign(:repos_cleaned_list, nil)
        |> assign(:selected_repo, nil)
        |> assign(:issues_cleaned, [])
        |> assign(:issues_with_reward, [])
        |> assign(:issues_paid, [])
      }
    end

    @impl true
    def render(assigns) do
      ~H"""
      <.container class="mt-10 mb-32">
        <.form
          :let={f}
          multipart
          for={:search_input}
          phx-change="value_change"
        >
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.form_label form={f} field={:input_orgs_name_you_want_to_analyze_it} />
            <.text_input form={f} field={:text_input} placeholder="NonceGeek" value={@org_name_value}/>
            <br>
            <.button label="Get Repo list!"/>
          </div>
        </div>
        <br>

        <%= if !is_nil(@repos_cleaned_list) do %>
          <.select options={@repos_cleaned_list} form={f} field={:select} value={@selected_repo}/>
        <% end %>
        <br>
        <.button label="Analyze Selected Repo!"/>
        <br>
        <br>
        <.p class="font-bold">All the Issues:</.p>
        <br>
        <%= for issue <- @issues_cleaned do %>
          <.p class="font-bold">Contents:</.p>
          <.p><%= issue.body %></.p>
          <.p class="font-bold">Link:</.p>
          <a href={issue.url}><.p><%= issue.url %></.p></a>
          <hr>
        <% end %>
        <br>
        <.p class="font-bold">Issues as Bounties:</.p>
          <%= for issue <- @issues_with_reward do %>
            <.p class="font-bold">Contents:</.p>
            <.p><%= issue.body %></.p>
            <.p class="font-bold">Link:</.p>
            <a href={issue.url}><.p><%= issue.url %></.p></a>
            <.p class="font-bold">Money in this Bounty:</.p>
            <.p class="!text-pink-600">
              <%= inspect(DAOPanel.GithubHandler.abstract_money(issue.body)) %>
            </.p>
            <.p class="font-bold">Proof Link:</.p>
            <.p class="!text-pink-600">
              <%= inspect(DAOPanel.GithubHandler.abstract_proof_link(issue.body)) %>
            </.p>
            <hr>
          <% end %>
        <br>

        <.p class="font-bold">Issues as Bounties(Paid):</.p>
          <%= for issue <- @issues_paid do %>
            <.p class="font-bold">Contents:</.p>
            <.p><%= issue.body %></.p>
            <.p class="font-bold">Link:</.p>
            <a href={issue.url}><.p><%= issue.url %></.p></a>
            <.p class="font-bold">Money in this Bounty:</.p>
            <.p class="!text-pink-600">
              <%= inspect(DAOPanel.GithubHandler.abstract_money(issue.body)) %>
            </.p>
            <.p class="font-bold">Proof Link:</.p>
            <.p class="!text-pink-600">
              <%= inspect(DAOPanel.GithubHandler.abstract_proof_link(issue.body)) %>
            </.p>
            <.p class="font-bold">Tx Parsed:</.p>
            <.p class="!text-pink-600">
              <%= inspect(issue.tx_parsed.args) %>
            </.p>
            <hr>
          <% end %>
        <br>
        </.form>
      </.container>
      """
    end

    def handle_event(key, params, socket) do
      IO.puts inspect key
      IO.puts inspect params
      IO.puts inspect socket
      {:noreply, socket}
    end
  end
