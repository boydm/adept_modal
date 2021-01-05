export {AdeptModalHook};
let AdeptModalHook = {
  mounted() {
    this.handleEvent("adept-modal-event", (e) => this.onModalEvent(e));
  },
  onModalEvent( e ) {
    const detail = {};
    this.el.dispatchEvent( new CustomEvent(e.event, {
        detail,
        bubbles: true
    } ) );
  }
}