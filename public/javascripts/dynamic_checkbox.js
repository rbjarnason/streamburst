function onSelectChange() {
  Element.show('spinner'); 
  new Ajax.Request('/catalogue/'+'set_cart_all_brands?show_all='+this.checked, {asynchronous:true, evalScripts:true, onSuccess:function(request){Element.hide('spinner')}});
  }
