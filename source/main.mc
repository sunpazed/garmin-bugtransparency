using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Timer as Timer;

class BasicApp extends App.AppBase {

    function initialize() {
      App.AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new BasicView() ];
    }

}


class BasicView extends Ui.WatchFace {

    var hour = null;
    var minute = null;
    var dw = null;
    var dh = null;
    var f_block_font = null;
    var f_outline_font = null;
    var time_buffer = null;
    var height_of_bitmap = 32;

    // change the colour here
    var time_color = 0xFFFFFF;

    function initialize() {
      Ui.WatchFace.initialize();

    }

    function onLayout(dc) {

      // w,h of canvas
      dw = dc.getWidth();
      dh = dc.getHeight();

      // load font resources
      // -------------------------
      f_block_font = Ui.loadResource(Rez.Fonts.font_block);
      f_outline_font = Ui.loadResource(Rez.Fonts.font_outline);

      // we define a buffered bitmap with a custom palette
      if (Toybox.Graphics has :BufferedBitmap) {
        time_buffer = new Graphics.BufferedBitmap({
            :width=>dc.getWidth(),
            :height=>height_of_bitmap,
            :palette=>[
              Gfx.COLOR_TRANSPARENT,
              Gfx.COLOR_BLACK,
              time_color
            ]
        });
      } else {
        time_buffer = null;
      }

    }

    function onPartialUpdate(dc) {
      drawUpdate(dc,true);
    }

    function onUpdate(dc) {

      // grab time objects
      var clockTime = Sys.getClockTime();
      var date = Time.Gregorian.info(Time.now(),0);

      // define time, day, month variables
      hour = clockTime.hour;
      minute = clockTime.min;

      var deviceSettings = Sys.getDeviceSettings();
      var set_leading_zero = deviceSettings.is24Hour;

      // 12-hour support
      if (hour > 12 || hour == 0) {
          if (!deviceSettings.is24Hour)
              {
              if (hour == 0)
                  {
                  hour = 12;
                  }
              else
                  {
                  hour = hour - 12;
                  }
              }
      }

      // add padding to units if required
      if( minute < 10 ) {
          minute = "0" + minute;
      }

      if( hour < 10 && set_leading_zero) {
          hour = "0" + hour;
      }

      dc.clearClip();
      dc.setColor(Gfx.COLOR_BLACK, 0xFF00AA);
      dc.clear();

      // let's write to the time buffer if it exists
      if (time_buffer != null) {
          var time_dc = time_buffer.getDc();
          time_dc.setColor(time_color, Gfx.COLOR_TRANSPARENT);
          time_dc.drawText(dw/2, 0, f_block_font, hour.toString() + ":" + minute.toString(), Gfx.TEXT_JUSTIFY_CENTER);
          time_dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
          time_dc.drawText(dw/2, 0, f_outline_font, hour.toString() + ":" + minute.toString(), Gfx.TEXT_JUSTIFY_CENTER);
      }

      // call main render routine
      drawUpdate(dc,false);

    }

    // our main render routine, do1hz = use clips in partialUpdate mode
    function drawUpdate(dc,do1hz) {

      // set a clip region as wide and as tall as our bitmap
      if (do1hz) {
        dc.setClip(0,(dh/2)-(height_of_bitmap/2),dw,height_of_bitmap);
      }

      // draw a circle within the clipping bounds
      dc.setColor(0x00FF55, Gfx.COLOR_TRANSPARENT);
      dc.fillCircle((dw/2),(dh/2),height_of_bitmap);

      // if we're in 1hz mode, then draw the transparent bitmap over the circle
      if (do1hz && time_buffer != null) {
        dc.drawBitmap(0, (dh/2)-(height_of_bitmap/2), time_buffer );
      } else {
        dc.setColor(time_color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dw/2, (dh/2)-(height_of_bitmap/2), f_block_font, hour.toString() + ":" + minute.toString(), Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dw/2, (dh/2)-(height_of_bitmap/2), f_outline_font, hour.toString() + ":" + minute.toString(), Gfx.TEXT_JUSTIFY_CENTER);
      }

    }

}
