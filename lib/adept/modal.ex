defmodule Adept.Modal do
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView.Utils
  alias Phoenix.LiveView
  alias Phoenix.HTML

  # import IEx

  #--------------------------------------------------------
  @spec show_script(atom()) :: {:safe, String.t()}
  def show_script(id) when is_atom(id) or is_bitstring(id) do
    id
    |> event_name(:show)
    |> dispatch_window_event()
    |> HTML.raw()
  end

  @spec hide_script(atom()) :: {:safe, String.t()}
  def hide_script(id) when is_atom(id) or is_bitstring(id) do
    id
    |> event_name(:hide)
    |> dispatch_window_event()
    |> HTML.raw()
  end

  #--------------------------------------------------------
  @spec push_show_event(LiveView.Socket.t(), atom() | String.t()) :: Access.t()
  def push_show_event( %LiveView.Socket{} = socket, id ) when is_atom(id) or is_bitstring(id) do
    push_event( socket, "adept-modal-event", %{event: event_name(id, :show)} )
  end

  @spec push_hide_event(LiveView.Socket.t(), atom() | String.t()) :: Access.t()
  def push_hide_event( %LiveView.Socket{} = socket, id ) when is_atom(id) or is_bitstring(id) do
    push_event( socket, "adept-modal-event", %{event: event_name(id, :hide)} )
  end

  #--------------------------------------------------------
  @spec render(LiveView.Socket.t(), atom(), atom() | String.t()) :: LiveView.Rendered.t()
  def render( %LiveView.Socket{} = socket, component, id, opts \\ [] )
  when (is_atom(id) or is_bitstring(id)) and is_atom(component) and component != nil and is_list(opts) do
    opts
    |> Keyword.put(:id, id)
    # sensible defaults
    |> Keyword.put_new(:show, false)
    |> Keyword.put_new(:show_x, true)
    |> Keyword.put_new(:return_to, nil)
    |> Keyword.put_new(:size, "md")
    |> do_render2( socket, component )
    |> HTML.raw()
  end

  defp do_render( opts, socket, component ) do
    assigns = Enum.into(opts, %{})

    # render the modal directly. doesn't need to be a component
    # in and of itself as it doesn't track any independant state
    ~L"""
    <div
      x-data="{ adept_modal_is_open: false }"
      x-on:keydown.escape.window="adept_modal_is_open = false"
      phx-hook="AdeptModal"
      class="fixed z-10 inset-0 overflow-y-auto"
      x-show="adept_modal_is_open"
      x-on:<%=event_name(@id,:show)%>.window="adept_modal_is_open = true"
      x-on:<%=event_name(@id,:hide)%>.window="adept_modal_is_open = false"
      <%=
        case @show do
          true -> "x-init='setTimeout(function() {adept_modal_is_open = true}, 100)'" |> HTML.raw()
          false -> "x-init='setTimeout(function() {adept_modal_is_open = false}, 100)'" |> HTML.raw()
        end
      %>
    >

      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0" >
        <%# Background overlay, show/hide based on modal state. %>
        <div
          x-show="adept_modal_is_open"
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
          x-show="adept_modal_is_open"
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
          <%= if @show_x do %>
            <div class="flex">
              <h2 class="flex-1 text-2xl"><%= @title %></h2>

              <div class="flex-initial mt-0.5" @click="adept_modal_is_open = false" >
                <%= if @return_to do %>
                  <%= live_patch to: @return_to do %>
                    <div class="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-indigo-50 focus:ring-indigo-600">
                      <span class="sr-only">Dismiss</span>
                      <!-- Heroicon name: x -->
                      <svg
                        class="h-5 w-5"
                        xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                      </svg>
                    </div>
                  <% end %>
                <% else %>
                  <div class="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-indigo-50 focus:ring-indigo-600">
                    <span class="sr-only">Dismiss</span>
                    <!-- Heroicon name: x -->
                    <svg
                      class="h-5 w-5"
                      xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                    </svg>
                  </div>
                <% end %>
              </div>

            </div>
          <% end %>
          <%= live_component( socket, component, opts ) %>
        </div>
      </div>
    </div>
    """
  end

  defp do_render2( opts, socket, component ) do
    assigns = Enum.into(opts, %{})

    # render the modal directly. doesn't need to be a component
    # in and of itself as it doesn't track any independant state
    """
    <div
      x-data="{ adept_modal_is_open: false }"
      x-on:keydown.escape.window="adept_modal_is_open = false"
      phx-hook="AdeptModal"
      class="fixed z-10 inset-0 overflow-y-auto"
      x-show="adept_modal_is_open"
      x-on:#{event_name(opts[:id],:show)}.window="adept_modal_is_open = true"
      x-on:#{event_name(opts[:id],:hide)}.window="adept_modal_is_open = false"
      #{
        case opts[:show] do
          true -> "x-init='setTimeout(function() {adept_modal_is_open = true}, 100)'"
          false -> "x-init='setTimeout(function() {adept_modal_is_open = false}, 100)'"
        end
      }
    >
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0" >
        <%# Background overlay, show/hide based on modal state. %>
        <div
          x-show="adept_modal_is_open"
          class="fixed inset-0 transition-opacity"
          aria-hidden="#{opts[:show]}"
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
          x-show="adept_modal_is_open"
          x-transition:enter="ease-out duration-300"
          x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave="ease-in duration-200"
          x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
          x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          role="dialog"
          aria-modal="true"
          aria-hidden="#{opts[:show]}"
          aria-labelledby="modal-headline"
          class="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-<%= @size %> sm:w-full sm:p-6"
        >
          #{ do_show_x( opts[:show_x], opts ) }
          <%#= live_component( socket, component, opts ) %>
        </div>
      </div>


    </div>
    """
  end

  defp do_show_x( false, opts ), do: ""
  defp do_show_x( true, opts ) do
    """
    <div class="flex">
      <h2 class="flex-1 text-2xl">#{opts[:title]}</h2>
      <div class="flex-initial mt-0.5" @click="adept_modal_is_open = false" >
        #{ do_return_to( opts[:return_to], opts ) }
      </div>
    </div>
    """
  end

  defp do_return_to( nil, opts ) do
    """
    <div class="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-indigo-50 focus:ring-indigo-600">
      <span class="sr-only">Dismiss</span>
      <!-- Heroicon name: x -->
      <svg
        class="h-5 w-5"
        xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
        <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
      </svg>
    </div>
    """
  end

  defp do_return_to( return_to, opts ) when is_bitstring(return_to) do
    live_patch to: return_to do
      """
      <div class="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-indigo-50 focus:ring-indigo-600">
        <span class="sr-only">Dismiss</span>
        <!-- Heroicon name: x -->
        <svg
          class="h-5 w-5"
          xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
        </svg>
      </div>
      """
    end
  end


  #--------------------------------------------------------
  defp dispatch_window_event( event_name, event_data \\ %{} ) do
    cond do
      event_data == %{} -> "$dispatch('#{event_name}', {})"
      %{} = event_data -> "$dispatch('#{event_name}', #{Jason.encode!(event_data)})"
    end
  end

  #--------------------------------------------------------
  defp event_name( id, :show ), do: "adept-modal-show-" <> prep_event_name(id)
  defp event_name( id, :hide ), do: "adept-modal-hide-" <> prep_event_name(id)
  defp prep_event_name( id ) when is_atom(id) or is_bitstring(id) do
    id
    |> to_string()
    |> String.trim()
    |> String.replace("_", "-")
  end

end





      # <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0" >
      #   <%# Background overlay, show/hide based on modal state. %>
      #   <div
      #     x-show="adept_modal_is_open"
      #     class="fixed inset-0 transition-opacity"
      #     aria-hidden="#{opts[:show]}"
      #     x-transition:enter="ease-out duration-300"
      #     x-transition:enter-start="opacity-0"
      #     x-transition:enter-end="opacity-100"
      #     x-transition:leave="ease-in duration-200"
      #     x-transition:leave-start="opacity-100"
      #     x-transition:leave-end="opacity-0"
      #   >
      #     <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
      #   </div>

      #   <%# is element is to trick the browser into centering the modal contents. %>
      #   <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
        
      #   <%# Modal panel, show/hide based on modal state. %>
      #   <div
      #     x-show="adept_modal_is_open"
      #     x-transition:enter="ease-out duration-300"
      #     x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
      #     x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
      #     x-transition:leave="ease-in duration-200"
      #     x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
      #     x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
      #     role="dialog"
      #     aria-modal="true"
      #     aria-hidden="#{opts[:show]}"
      #     aria-labelledby="modal-headline"
      #     class="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-<%= @size %> sm:w-full sm:p-6"
      #   >
      #     #{
      #       case opts[:show_x] do
      #         true -> "booger"
      #         false -> ""
      #       end
      #     }
      #     <%= live_component( socket, component, opts ) %>
      #   </div>
      # </div>









              # <div class="flex">
              #   <h2 class="flex-1 text-2xl">#{opts[:title]}</h2>

              #   <div class="flex-initial mt-0.5" @click="adept_modal_is_open = false" >
              #     #{
              #       if opts[:return_to] do
              #         live_patch to: @return_to do
              #           """
              #           <div class="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-indigo-50 focus:ring-indigo-600">
              #             <span class="sr-only">Dismiss</span>
              #             <!-- Heroicon name: x -->
              #             <svg
              #               class="h-5 w-5"
              #               xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              #               <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              #             </svg>
              #           </div>
              #           """
              #         end
              #       else
              #         """
              #         <div class="rounded-md p-1.5 text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-indigo-50 focus:ring-indigo-600">
              #           <span class="sr-only">Dismiss</span>
              #           <!-- Heroicon name: x -->
              #           <svg
              #             class="h-5 w-5"
              #             xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              #             <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              #           </svg>
              #         </div>
              #         """
              #       end
              #     }
              #   </div>
              # </div>














