// External namespace for cast specific javascript library
var cast = window.cast || {};

(function() {
  'use strict';

  PhotoScreen.PROTOCOL = "net.mootoh.cast.photoscreen";

  function PhotoScreen(img) {
    this.img = img;
    this.channelHandler_ = new cast.receiver.ChannelHandler('PhotoScreenDebug');
    this.channelHandler_.addEventListener(cast.receiver.Channel.EventType.MESSAGE, this.onMessage.bind(this));
    this.channelHandler_.addEventListener(cast.receiver.Channel.EventType.OPEN, this.onChannelOpened.bind(this));
    this.channelHandler_.addEventListener(cast.receiver.Channel.EventType.CLOSED, this.onChannelClosed.bind(this));
  }

  PhotoScreen.prototype = {
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
      try {
        var message = event.message;
        console.log('********onMessage********' + JSON.stringify(message));

        var command = message.command;

        if (command === 'sender_info') {
          this.sender_ip   = message.ip_address;
          this.sender_port = message.port;
        } else if (command === 'show') {
          var image_id = message.image_id;
          var image_url = 'http://' + this.sender_ip + ':' + this.sender_port + '/' + image_id + '.jpg';
          console.log("image url = " + image_url);
          this.img.src = image_url;
        } else {
          console.log('Unknown command: ' + command);
        }
      } catch (ex) {
        console.log('Exception: ' + ex);
      }
    }
  };

  cast.PhotoScreen = PhotoScreen;
})();