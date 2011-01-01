var delete_clicked = function(parent_row_class) {
  return function(ev) {
    if ( confirm('Are you sure you want to delete this property association?' ) ) {
      $.ajax({
        type: 'delete',
        url: $(ev.target).attr("href"), 
        success: function(update_response) { 
          $(ev.target).parents(parent_row_class).remove(); 
          update_notice(update_response);
        },
        error: ajax_error_alert
      });
    }

    return false;
  };
};
