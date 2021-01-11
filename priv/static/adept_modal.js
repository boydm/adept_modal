export {AdeptModalHook};

let AdeptModalHook = {
  mounted() {
    // alert("mounted");
    // setTimeout(function() {this.onUpdate()}, 100);
    this.handleEvent("adept-modal-event", (e) => this.onModalEvent(e));
  },

  updated() {
    // alert("updated");
    this.onUpdate();
  },

  onUpdate() {
    let id = this.el.getAttribute('adept-id');
    var event_prefix = 'adept-modal-hide-';
    if ( this.el.getAttribute('adept-show') == "true" ){event_prefix = 'adept-modal-show-';} 
    this.dispatch( event_prefix + id );
  },

  onModalEvent( e ) {
    const event_name = e.event;
    this.dispatch( event_name );
    if ( e.opts.redirect_to != undefined ) {
      // alert( 'redirect_to: ' + e.opts.redirect_to );
      setTimeout(function() {window.location.href = e.opts.redirect_to}, 100);
    }
  },

  dispatch( event_name ) {
    var detail = { bubbles: true };
    this.el.dispatchEvent( new CustomEvent(event_name, detail) );
  }
}
