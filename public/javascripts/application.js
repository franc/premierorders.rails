var editIn = function() {
  $(this).css('color','red');
};

var editOut = function() {
  $(this).css('color', 'black');
};

var update_notice = function(data) {
  if (data['updated'] === 'success') {
    $("#notice").html("Update successful.")
  } else {
    var message = (data['error'] === undefined) ? "Unexpected error! Please file a bug describing what you were doing." : data['error'];
    $("#notice").html('<span style="color:red">'+message+'</span>')
  }
};

var ajax_error_alert = function (XMLHttpRequest, textStatus, errorThrown) {
  alert("Ooooops!, request failed with status: " + XMLHttpRequest.status + ' ' + XMLHttpRequest.responseText);
}

var post_this_update = function() {
  var cont = arguments.length == 0 ? update_notice : arguments[0];
  post_update($(this), cont);
};

var post_update = function(node, continuation) {
  // make a POST call and replace the content
  var value = node.val();
  var fields = /(\w+)\[([0-9]+)\]\[(\w+)\]/.exec(node.attr('name'));
  var entity_id = fields[2];
  var request = {
    '_method': 'PUT'
  };
  request[fields[1]+'[' + fields[3] + ']'] = value;
  $.post("/"+fields[1]+"s/"+entity_id, request, continuation, "json");
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
          if (dateText && dateText !== current) post_update($(this), update_notice);
          enclosure.html(dateText); //restore the value irrespective if it has changed.
	  ajax_date(enclosure);
        }
      });

      $(this).unbind('click');
      $(this).html(input);
      input.focus();
    }
  );
};

var supports_offline = function() {
  return !!window.applicationCache;
};

var supports_local_storage = function() {
  try {
    return 'localStorage' in window && window['localStorage'] !== null;
  } catch(e){
    return false;
  }
};

var option_html = function(key, value) {
  return "<option value=\""+key+"\">"+value+"</option>";
};
