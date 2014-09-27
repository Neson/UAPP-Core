// This file will be included in each page, inside the body tag.
//
//= require semantic-ui
//
//= require_tree ./pages

$(document).ready(function() {

  $('.ui.accordion')
    .accordion()
  ;

  $('.ui.checkbox')
    .checkbox()
  ;

  $('.ui.dimmable')
    .dimmer('show')
  ;

  $('.ui.dropdown')
    .dropdown()
  ;

  $('.ui.modal')
    .modal()
  ;

  $('.ui.checkbox')
    .checkbox()
  ;

  // $('.ui.popup')
  //   .popup({
  //     position: 'bottom center'
  //   })
  // ;

  $('.ui.has-popup')
    .popup({
      position: 'bottom center'
    })
  ;

  $('.ui.rating')
    .rating()
  ;

  $('select.select2, .select2 > select').select2().on("select2-opening", function() { $('html').addClass('select2-opened'); $('html').addClass('select2-open'); }).on("select2-close", function() { $('html').removeClass('select2-open'); });

  $('.top.sidebar').first()
    .sidebar('attach events', '.top-sidebar-toggle-button')
  ;

  $('.message .close').on('click', function() {
    $(this).closest('.message').fadeOut();
  });

  $('.top-sidebar-toggle-button').unbind('click').bind('click', function () {
    if ($('.mobile.sidebar').sidebar('is open')) {
      $('.mobile.sidebar').sidebar('hide');
    } else if ($('.top.sidebar').sidebar('is open')) {
      $('.top.sidebar').sidebar('hide');
    } else if ($('.apps.sidebar').sidebar('is open')) {
      $('.apps.sidebar').sidebar('hide');
    } else {
      $('.wrapper > .main').unbind('click').bind('click', function () {
        $('.sidebar').sidebar('hide');
      });
      if ($(window).width() > 992) {
        $('.top.sidebar').sidebar('toggle');
      } else {
        $('.mobile.sidebar').sidebar('toggle');
      }
    }
  });

  $('.field_with_errors').parent('.field').addClass('error');

  $('form').bind('submit', function () { NProgress.start(); });

});
