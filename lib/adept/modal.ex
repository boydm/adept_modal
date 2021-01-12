defmodule Adept.Modal do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView
  alias Phoenix.HTML

  #--------------------------------------------------------
  def adept_modal(name, %Phoenix.LiveComponent.CID{} = target, opts \\ [], do: block) do
    do_render(name, target, block, opts)
  end

  #--------------------------------------------------------
  # using macro
  defmacro __using__(_using_opts \\ []) do
    quote do
      import Adept.Modal, only: [adept_modal: 3, adept_modal: 4]
    end # quote
  end # defmacro

  #--------------------------------------------------------
  @spec open(LiveView.Socket.t(), atom() | String.t()) :: Access.t()
  def open( %LiveView.Socket{} = socket, id, opts \\ [] ) when is_atom(id) or is_bitstring(id) do
    do_push_event( socket, event_name(id, :hide), opts ) 
  end

  @spec close(LiveView.Socket.t(), atom() | String.t()) :: Access.t()
  def close( %LiveView.Socket{} = socket, id, opts \\ [] ) when is_atom(id) or is_bitstring(id) do
    do_push_event( socket, event_name(id, :hide), opts ) 
  end

  defp do_push_event( socket, event_name, opts ) do
    opts = cond do
      path = opts[:to] ->
        Process.send_after(self(), {:patch_to, path}, 200, [] )
        %{}
      path = opts[:return_to] ->
        Process.send_after(self(), {:patch_to, path}, 200, [] )
        %{}
      path = opts[:patch_to] ->
        Process.send_after(self(), {:patch_to, path}, 200, [] )
        %{}
      path = opts[:redirect_to] ->
        %{redirect_to: path}
      true ->
        %{}
    end
    push_event( socket, "adept-modal-event", %{ event: event_name, opts: opts } )
  end

  #--------------------------------------------------------
  # render the modal
  defp do_render(name, target, block, opts) when is_list(opts) do

    assigns = Enum.into(opts, %{})
    |> Map.put( :name, prep_name(name) )
    # sensible defaults
    |> Map.put_new(:show, true)
    |> Map.put_new(:show_title, true)
    |> Map.put_new(:show_x, true)
    |> Map.put_new(:title, prep_title(name))
    |> Map.put_new(:size, "xl")
    |> Map.put_new(:close, "modal_close")

    # render and return the modal shell
    ~L"""
    <div
      x-data="{ adept_modal_open: false }"
      phx-hook="AdeptModal"
      class="fixed z-10 inset-0 overflow-y-auto"
      x-show="adept_modal_open"
      adept-id="<%= @name %>"
      adept-show="<%= @show %>"
      x-on:<%=event_name(@name,:show)%>.window="adept_modal_open = true; setTimeout( function() { $el.querySelector('[autofocus]').focus() }, 100 )"
      x-on:<%=event_name(@name,:hide)%>.window="adept_modal_open = false"
      <%= case @show do %>
        <% true -> %>
          phx-window-keydown="<%= @close %>"
          phx-key="escape"
          phx-target="<%= target %>"
          x-init="setTimeout(function() {adept_modal_open = true}, 100)"
        <% false -> %>x-init="setTimeout(function() {adept_modal_open = false}, 0)"
      <% end %>
    >

      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0" >
        <%# Background overlay, show/hide based on modal state. %>
        <div
          x-show="adept_modal_open"
          class="fixed inset-0 transition-opacity"
          aria-hidden="<%= @show %>"
          x-transition:enter="ease-out duration-300"
          x-transition:enter-start="opacity-0"
          x-transition:enter-end="opacity-100"
          x-transition:leave="ease-in duration-200"
          x-transition:leave-start="opacity-100"
          x-transition:leave-end="opacity-0"
        >
          <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
        </div>

        <%# is element is to trick the browser into centering the modal contents. %>
        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        
        <%# Modal panel, show/hide based on modal state. %>
        <div
          x-show="adept_modal_open"
          x-transition:enter="ease-out duration-300"
          x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave="ease-in duration-200"
          x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          role="dialog"
          aria-modal="true"
          aria-hidden="<%= @show %>"
          aria-labelledby="modal-headline"
          class="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-<%= @size %> sm:w-full sm:p-6"
        >
          <%= if (@title && @title != "") || @show_x do %>
            <div class="flex">
              <%= if @show_title do %>
                <h2 class="flex-1 text-2xl"><%= @title %></h2>
              <% else %>
                <div class="flex-1"></div>
              <% end %>
              <%= if @show_x do %>
                <div
                  phx-click="<%= @close %>"
                  phx-target="<%= target %>"
                  class="flex-initial mt-0.5" @click="adept_modal_open = false"
                >
                  <div class="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-indigo-50 focus:ring-indigo-600">
                    <span class="sr-only">Dismiss</span>
                    <!-- Heroicon x -->
                    <svg
                      class="h-5 w-5"
                      xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                    </svg>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
          <%= Phoenix.HTML.Tag.content_tag(:div, [], do: block) %>
        </div>
      </div>
    </div>
    """
  end

  def render(_) do
    raise """
    Adept.Modal.render/1 is only here to make Phoenix.LiveComponent happy at compile time.
    It should never get called.
    """
  end

  #--------------------------------------------------------
  defp event_name( name, :show ), do: "adept-modal-show-" <> prep_name(name)
  defp event_name( name, :hide ), do: "adept-modal-hide-" <> prep_name(name)

  #--------------------------------------------------------
  defp prep_name( id ) when is_atom(id) or is_bitstring(id) do
    id
    |> to_string()
    |> String.trim()
    |> String.downcase()
    |> String.replace(" ", "-")
    |> String.replace("_", "-")
  end

  #--------------------------------------------------------
  defp prep_title( name ) when is_atom(name) or is_bitstring(name) do
    name
    |> to_string()
    |> String.trim()
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map( &upcase_first(&1) )
    |> Enum.join( " " )
  end
  defp upcase_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

end