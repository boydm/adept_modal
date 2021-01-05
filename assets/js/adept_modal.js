/*
================================================================================
Adept Modal Dialog JavaScript Client
================================================================================

See the hexdocs at `https://hexdocs.pm/adept_modal` for documentation.

This file is the required Phoenix Hook to catch modal control events from the server

*/

// Hooks.AdeptModal = {
//   mounted() {
//     this.handleEvent("modal_event", (e) => this.onModalEvent(e))
//   },

//   onModalEvent( e ) {
//     const detail = {}
//     this.el.dispatchEvent( new CustomEvent(e.event, {
//         detail,
//         bubbles: true
//     } ) )
//   }
// }

class AdeptModal {
  hook( hooks ) {
    hooks.AdeptModal = {
      mounted() {
        this.handleEvent("modal_event", (e) => this.onModalEvent(e))
      },

      onModalEvent( e ) {
        const detail = {}
        this.el.dispatchEvent( new CustomEvent(e.event, {
            detail,
            bubbles: true
        } ) )
      }
    }
  }
}