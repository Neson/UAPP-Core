//= require toastr

toastr.options = {
  "closeButton": false,
  "debug": false,
  "positionClass": "toast-top-full-width",
  "onclick": null,
  "showDuration": "0",
  "hideDuration": "1000",
  "timeOut": "7000",
  "extendedTimeOut": "4000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}

flash_message = {}
flash_message.success = function (message, title, optionsOverride) {
  toastr.success(message, title, optionsOverride);
  flash_message.update_first_toast();
};
flash_message.info = function (message, title, optionsOverride) {
  toastr.info(message, title, optionsOverride);
  flash_message.update_first_toast();
};
flash_message.notice = function (message, title, optionsOverride) {
  toastr.info(message, title, optionsOverride);
  flash_message.update_first_toast();
};
flash_message.warning = function (message, title, optionsOverride) {
  toastr.warning(message, title, optionsOverride);
  flash_message.update_first_toast();
};
flash_message.alert = function (message, title, optionsOverride) {
  toastr.error(message, title, optionsOverride);
  flash_message.update_first_toast();
};
flash_message.error = function (message, title, optionsOverride) {
  toastr.error(message, title, optionsOverride);
  flash_message.update_first_toast();
};
flash_message.update_first_toast = function () {
  $('#toast-container .toast:first-of-type').css('margin-top', '-' + ($('#toast-container .toast:first-of-type').height() + 37) + 'px');
  if ($(window).width() > 480) {
    $('#toast-container .toast:first-of-type .action, #toast-container .toast:first-of-type .action input[type=submit], #toast-container .toast:first-of-type .action .button').css('height', ($('#toast-container .toast:first-of-type').height() + 30) + 'px');
  } else {
    $('#toast-container .toast:first-of-type .action, #toast-container .toast:first-of-type .action input[type=submit], #toast-container .toast:first-of-type .action .button').css('height', ($('#toast-container .toast:first-of-type').height() + 16) + 'px');
  }

}
flash_message.count = 0;
toastr.options.onShown = function() {
  flash_message.count++;
  flash_message.update_first_toast();
  setTimeout(function () { $('#toast-container .toast:first-of-type').addClass('show'); }, 1);
};
