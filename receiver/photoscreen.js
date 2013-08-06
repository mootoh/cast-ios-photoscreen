// External namespace for cast specific javascript library
var cast = window.cast || {};

(function() {
  'use strict';

  Photoscreen.PROTOCOL = "net.mootoh.cast.photoscreen";

  function Photoscreen() {
    this.channelHandler_ = new cast.receiver.ChannelHandler('PhotoScreenDebug');
    this.channelHandler_.addEventListener(cast.receiver.Channel.EventType.MESSAGE, this.onMessage.bind(this));
    this.channelHandler_.addEventListener(cast.receiver.Channel.EventType.OPEN, this.onChannelOpened.bind(this));
    this.channelHandler_.addEventListener(cast.receiver.Channel.EventType.CLOSED, this.onChannelClosed.bind(this));
  }

  Photoscreen.prototype = {
    onChannelOpened: function(event) {
      console.log('onChannelOpened. Total number of channels: ' + this.channelHandler_.getChannels().length);
    },

    onChannelClosed: function(event) {
      console.log('onChannelClosed. Total number of channels: ' + this.channelHandler_.getChannels().length);

      if (this.channelHandler_.getChannels().length == 0) {
        window.close();
      }
    },

    onMessage: function(event) {
      var message = event.message;
      var channel = event.target;

      console.log('********onMessage********' + JSON.stringify(message));
  };

  cast.Photoscreen = Photoscreen;
})();