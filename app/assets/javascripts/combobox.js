(function( $ ) {
  $.widget( "ui.combobox", {
    _create: function() {
      var self = this;
      var select = this.element.hide(),
        selected = select.children( ":selected" ),
        value = selected.val() ? selected.text() : "";
      var input = $( "<input id=autocomplete_combobox_" + this.options.watermark + ">" )
        .insertAfter( select )
        .val( value );
      var watermark = ('Search ' + this.options.watermark), resetWatermark = function () {
        currentValue = input.val();
        if (currentValue == '' || currentValue == watermark) {
          input.val(watermark);
          input.addClass('watermark');
        }
        else {
          input.removeClass('watermark');
        }
      };

      resetWatermark();

      input.focus(function () {
        resetWatermark();
        this.select();
      });

      input.change(function () {
        resetWatermark();
      });

      input.mouseup(function(e){
        e.preventDefault();
      });

      input.autocomplete({
        delay: 0,
        minLength: 0,
        source: function( request, response ) {
          var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
          response( select.children( "option" ).map(function() {
            var text = $( this ).text();
            if ( this.value && ( !request.term || matcher.test(text) ) )
            return {
              label: text.replace(
                new RegExp(
                  "(?![^&;]+;)(?!<[^<>]*)(" +
                  $.ui.autocomplete.escapeRegex(request.term) +
                  ")(?![^<>]*>)(?![^&;]+;)", "gi"
                ), "$1" ),
              value: text,
              option: this
            };
          }) );
        },
        select: function( event, ui ) {
          ui.item.option.selected = true;
          //select.val( ui.item.option.value );
          self._trigger( "selected", event, {
            item: ui.item.option
          });
        },
        change: function( event, ui ) {
          if ( !ui.item ) {
            var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
            valid = false;
            select.children( "option" ).each(function() {
              if ( this.value.match( matcher ) ) {
                this.selected = valid = true;
                return false;
              }
            });
            if ( !valid ) {
              // remove invalid value, as it didnt match anything
              $( this ).val( "" );
              select.val( "" );
              return false;
            }
          }
        }
      })
      .addClass( "ui-widget ui-widget-content ui-corner-left" );

      input.data( "autocomplete" )._renderItem = function( ul, item ) {
        return $( "<li></li>" )
        .data( "item.autocomplete", item )
        .append( "<a>" + item.label + "</a>" )
        .appendTo( ul );
      };
    }
  });
})(jQuery);
