export {AdeptModalHook};

let AdeptModalHook = {
  mounted() {
    this.is_open = this.el.getAttribute('adept-show');
    this.handleEvent("adept-modal-event", (e) => this.onModalEvent(e));
  },

  updated() {
    this.onUpdate();
  },

  onUpdate() {
    let is_open = this.el.getAttribute('adept-show')
    if (is_open != this.is_open) {
      this.is_open = is_open
      const id = this.el.getAttribute('adept-id');
      if ( is_open == "true" ) {
        var event_prefix = 'adept-modal-show-';
        this.dispatch( event_prefix + id );
      } else {
        var event_prefix = 'adept-modal-hide-';
        this.dispatch( event_prefix + id );
      }
    }
  },

  onModalEvent( e ) {
    const event_name = e.event;
    this.dispatch( event_name );
    if ( e.opts.redirect_to != undefined ) {
      setTimeout(function() {window.location.href = e.opts.redirect_to}, 100);
    }
  },

  dispatch( event_name ) {
    var detail = { bubbles: true };
    this.el.dispatchEvent( new CustomEvent(event_name, detail) );
  }
}