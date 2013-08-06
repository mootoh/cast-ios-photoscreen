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
      var message = event.message;
      var idx = message.image_url;

      console.log('********onMessage********' + JSON.stringify(message));

      var image_urls = [
        // "http://farm8.staticflickr.com/2836/9342179435_ea1361f989.jpg",
        "http://farm3.staticflickr.com/2887/9188577195_2945b5443d.jpg",
        "http://farm6.staticflickr.com/5471/9342194129_8b7ce4c67f.jpg",
        "http://farm3.staticflickr.com/2836/9342193489_e72a63ce4a.jpg"];

      console.log("image url = " + image_urls[idx-1]);
      this.img.src = image_urls[idx-1];
    }
  };

  cast.PhotoScreen = PhotoScreen;
})();