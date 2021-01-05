defmodule AdeptModalTest do
  use ExUnit.Case
  doctest AdeptModal

  alias Adept.Modal
  # alias Phoenix.LiveView.Socket
  alias Phoenix.LiveView

  # import IEx

  test "show_script gens a script to send a show dialog event to the client window" do
    assert Modal.show_script(:test) == { :safe,
      "$dispatch('adept-modal-show-test', {})"
    }
  end
  
  test "show_script converts _ in the id to -" do
    assert Modal.show_script(:test_id) == { :safe,
      "$dispatch('adept-modal-show-test-id', {})"
    }
  end
  
  test "hide_script gens a script to send a show dialog event to the client window" do
    assert Modal.hide_script(:test) == { :safe,
      "$dispatch('adept-modal-hide-test', {})"
    }
  end
  
  test "hide_script converts _ in the id to -" do
    assert Modal.hide_script(:test_id) == { :safe,
      "$dispatch('adept-modal-hide-test-id', {})"
    }
  end

  test "push_show_event pushes an event to the client show event to the socket" do
    socket = Modal.push_show_event( %LiveView.Socket{}, :test )
    # testing against private data is brittle. May need to update this in the future.
    assert socket.private.changed.push_events == [["adept-modal-event", %{event: "adept-modal-show-test"}]]
  end
  
  test "push_hide_event pushes an event to the client show event to the socket" do
    socket = Modal.push_hide_event( %LiveView.Socket{}, :test )
    # testing against private data is brittle. May need to update this in the future.
    assert socket.private.changed.push_events == [["adept-modal-event", %{event: "adept-modal-hide-test"}]]
  end

  test "render works with defaults" do
    %LiveView.Rendered{static: _} = Modal.render( %LiveView.Socket{}, :test_component, :test_id )
  end

  test "render sets up opening div with hooks event listeners" do
    %LiveView.Rendered{static: body} = Modal.render( %LiveView.Socket{}, :test_component, :test_id )
    {:ok, html} = Floki.parse_document( body )

    # parse out the first element, which should be the opening div
    # it should also be the only root level element in the html
    [{"div",attrs,_}] = html

    # inspect the attrs. somewhat simpler in map form
    attrs = Enum.into(attrs, %{})
    # |> IO.inspect()
    assert Map.get(attrs, "phx-hook") ==  "AdeptModal"
    assert Map.get(attrs, "x-on:keydown.escape.window") ==  "is_open = false"
    # assert Map.get(attrs, "x-on:adept-modal-show-test-id.window") ==  "is_open = true"
    # assert Map.get(attrs, "x-on:adept-modal-hide-test-id.window") ==  "is_open = false"
    # assert Map.get(attrs, "x-init") ==  "setTimeout(function() {is_open = true}, 100)"
  end
end





  # def render( socket, component, id, opts ) do


  # #--------------------------------------------------------
  # def push_show_event( %Socket{} = socket, id ) when is_atom(id) or is_bitstring(id) do
  #   push_event( socket, "adept-modal-event", %{event: event_name(id, :show)} )
  # end

  # def push_hide_event( %Socket{} = socket, id ) when is_atom(id) or is_bitstring(id) do
  #   push_event( socket, "adept-modal-event", %{event: event_name(id, :hide)} )
  # end

