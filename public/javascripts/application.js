// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var editIn = function() {
  $(this).css('color','red');
}

var editOut = function() {
  $(this).css('color', 'black');
}

var update_notice = function(data) {
  if (data['updated'] === 'success') {
    $("#notice").html("Update successful.")
  } else {
    $("#notice").html('<span style="color:red">Update error! Please file a bug with a complete description.</span>')
  }
};

var post_this_update = function() {
  post_update($(this));
};

var post_update = function(node) {
  // make a POST call and replace the content
  var value = node.val();
  var fields = /(\w+)\[([0-9]+)\]\[(\w+)\]/.exec(node.attr('name'));
  var entity_id = fields[2];
  var request = {
    '_method': 'PUT'
  };
  request[fields[1]+'[' + fields[3] + ']'] = value;
  $.post("/"+fields[1]+"s/"+entity_id, request, update_notice, "json");
};

var ajax_date = function(node) {
  return node.click(
    function() {
      var enclosure = $(this);
      var current = $(this).html();
      var input = $('<input name="'+$(this).attr('id')+'" type="text"/>').attr('size', current.length + 1).val(current);

      input.datepicker({
        dateFormat: 'yy-mm-dd',
        defaultDate: current,
        onClose : function(dateText, node) {
          if (dateText && dateText !== current) post_update($(this));
          enclosure.html(dateText); //restore the value irrespective if it has changed.
	  ajax_date(enclosure);
        }
      });

      $(this).unbind('click');
      $(this).html(input);
      input.focus();
    }
  );
}

