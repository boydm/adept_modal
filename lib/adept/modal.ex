defmodule Adept.Modal do
  use Phoenix.LiveComponent

  import IEx

  alias Phoenix.LiveView.Socket
  alias Phoenix.LiveView
  alias Phoenix.HTML


  #--------------------------------------------------------
  @doc """
  Renders a modal component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, SlingerWeb.LinkLive.FormComponent,
        id: @link.id || :new,
        action: @live_action,
        link: @link,
        return_to: Routes.link_index_path(@socket, :index) %>
  """
  def render( socket, component, id, opts ) when is_atom(id) or is_bitstring(id) do
    inner_id = id
    modal_id = to_string(inner_id) <> "__modal__"

    modal_opts = opts
    |> Keyword.put(:id, modal_id)
    |> Keyword.put(:inner_id, inner_id)
    |> Keyword.put_new(:component, component)
    # sensible defaults
    |> Keyword.put_new(:show, false)
    |> Keyword.put_new(:show_x, true)
    |> Keyword.put_new(:return_to, nil)
    |> Keyword.put_new(:opts, [])
    |> Keyword.put_new(:inner_opts, [])

    live_component(socket, __MODULE__, modal_opts)
  end

  defp event_name( id, :show ), do: "modal-show-" <> prep_event_name(id)
  defp event_name( id, :hide ), do: "modal-hide-" <> prep_event_name(id)
  defp prep_event_name( id ) when is_atom(id) or is_bitstring(id) do
    id
    |> to_string()
    |> String.trim()
    |> String.replace("_", "-")
  end


  #--------------------------------------------------------
  def show_script(id) when is_atom(id) or is_bitstring(id) do
    id
    |> event_name(:show)
    |> dispatch_window_event()
    |> HTML.raw()
  end

  def hide_script(id) when is_atom(id) or is_bitstring(id) do
    id
    |> event_name(:hide)
    |> dispatch_window_event()
    |> HTML.raw()
  end

  #--------------------------------------------------------
  def push_show_event( %Socket{} = socket, id ) when is_atom(id) or is_bitstring(id) do
    push_event( socket, "modal_event", %{event: event_name(id, :show)} )
  end

  def push_hide_event( %Socket{} = socket, id ) when is_atom(id) or is_bitstring(id) do
    push_event( socket, "modal_event", %{event: event_name(id, :hide)} )
  end

  #--------------------------------------------------------
  defp dispatch_window_event( event_name, event_data \\ "{}" ) do
    event_name
    |> do_window_event( event_data )
  end

  defp do_window_event( event_name, %{} = event_data ) do
    do_window_event( event_name, Jason.encode!(event_data ) )
  end

  defp do_window_event( event_name, event_data ) when is_bitstring(event_data) do
    "$dispatch('#{event_name}', #{event_data})"
  end

  #--------------------------------------------------------
  defp inner_component( assigns ) do

    opts = assigns.opts
    |> Keyword.put_new( :id, assigns.inner_id )
    |> Keyword.put_new( :show, assigns.show )
    # |> Keyword.put_new( :hide_event, assigns.hide_event )
    # |> Keyword.put_new( :show_event, assigns.show_event )
    |> Keyword.put_new( :title, assigns.title )
    |> Keyword.put_new( :return_to, assigns.return_to )

    live_component( assigns.socket, assigns.component, opts )
  end

end
