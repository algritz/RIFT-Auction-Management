 $(document).ready(function() {

    $('#sales_listing_item_id').change(function(){
      $.ajax({
        url: 'new?'+ 'item_id=',// + $(':selected', this).val(),
        data: $(':selected', this).val(),
        success: function(data){
          $('#sales_listing_item_id');
          }
      })
    });
  });