defmodule TestComponent do
  use Phoenix.LiveComponent
  import IEx

  @impl true
  def render(assigns) do
    assigns = Map.put_new( :test_data, "" )
    pry()
    ~L"""
    <div>inner:<%= @test_data %></div>
    """
  end
end

defmodule AdeptModalTest do
  use ExUnit.Case
  doctest AdeptModal

  alias Adept.Modal
  # alias Phoenix.LiveView.Socket
  alias Phoenix.LiveView

  import IEx



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
    socket = %LiveView.Socket{}
    %LiveView.Rendered{static: _} = Modal.render( socket, :test_component, :test_id )
  end

  test "render sets up opening div with defaults" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", test_data: :abc )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    # parse out the first element, which should be the opening div
    # it should also be the only root level element in the html
    [{"div",attrs,_}] = html

    # inspect the attrs. somewhat simpler in map form
    attrs = Enum.into(attrs, %{})
    assert Map.get(attrs, "phx-hook") ==  "AdeptModal"
    assert Map.get(attrs, "x-on:keydown.escape.window") ==  "adept_modal_is_open = false"
    assert Map.get(attrs, "x-on:adept-modal-show-test-id.window") ==  "adept_modal_is_open = true"
    assert Map.get(attrs, "x-on:adept-modal-hide-test-id.window") ==  "adept_modal_is_open = false"
    assert Map.get(attrs, "x-init") ==  "setTimeout(function() {adept_modal_is_open = false}, 100)"
  end

  test "render shows the modal if show is true" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", show: true )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    # parse out the first element, which should be the opening div
    # it should also be the only root level element in the html
    [{"div",attrs,_}] = html

    # inspect the attrs. somewhat simpler in map form
    attrs = Enum.into(attrs, %{})
    assert Map.get(attrs, "x-init") ==  "setTimeout(function() {adept_modal_is_open = true}, 100)"
  end

  test "the X button is rendered by default but it is not a link" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title" )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    assert Floki.find( html, "span.sr-only" ) == [{"span", [{"class", "sr-only"}], ["Dismiss"]}]
    assert Floki.find( html,"a" ) == []    
  end

  test "the X button is rendered as a link if return_to is set" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", return_to: "test_return" )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    assert Floki.find( html, "span.sr-only" ) == [{"span", [{"class", "sr-only"}], ["Dismiss"]}]
    refute Floki.find( html,"a[href=\"test_return\"]" ) == []
  end

  test "the X button is not rendered rendered if show_x is false" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", show_x: false )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    assert Floki.find( html, "span.sr-only" ) == []
  end

  test "the size is md by default" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title" )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    refute Floki.find( html,"div[class~=\"sm:max-w-md\"]" ) == []
    assert Floki.find( html,"div[class~=\"sm:max-w-xl\"]" ) == []
  end

  test "the size is set according to @size" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", size: "xl" )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    assert Floki.find( html,"div[class~=\"sm:max-w-md\"]" ) == []
    refute Floki.find( html,"div[class~=\"sm:max-w-xl\"]" ) == []
  end

  test "the inner component is rendered" do
    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", test_data: :abc )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    pry()
  end

  test "options are passed through to the inner component" do

    r = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", test_data: :abc )
    pry()


    {:ok, html} = %LiveView.Socket{}
    |> Modal.render( TestComponent, :test_id, title: "Test Title", test_data: :abc )
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> Floki.parse_document()

    pry()

    assert Floki.find( html,"div[class~=\"sm:max-w-md\"]" ) == []
    refute Floki.find( html,"div[class~=\"sm:max-w-xl\"]" ) == []
  end

  # , test_data: :abc

end





