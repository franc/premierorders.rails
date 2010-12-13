var property_value_html = function(obj) {
  var elements = "";
  for (key in obj) {
    elements += "<dt>"+key+"</dt><dd>"+obj[key]+"</dd>\n";
  }
  return elements;
};
