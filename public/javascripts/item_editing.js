var item_prop_delete_clicked = function(ev) {
  if ( confirm('Are you sure you want to delete this property association?' ) ) {
    $.ajax({
      type: 'delete',
      url: $(ev.target).attr("href"), 
      success: function(update_response) { 
        $(ev.target).parents(".property_row").remove(); 
        update_notice(update_response);
      },
      error: ajax_error_alert
    });
  }

  return false;
};

var item_comp_delete_clicked = function(ev) {
  if ( confirm('Are you sure you want to delete this component association?' ) ) {
    $.ajax({
      type: 'delete',
      url: $(ev.target).attr("href"), 
      success: function(update_response) { 
        $(ev.target).parents(".item_component_row").remove(); 
        update_notice(update_response);
      },
      error: ajax_error_alert
    });
  }

  return false;
};
