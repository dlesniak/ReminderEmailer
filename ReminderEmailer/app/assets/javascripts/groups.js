$(document).ready(function() {
  $('#save_group_reminder_link').on('click', function() {
    console.log("Fired");
    $('#new_group_reminder_form').submit();
  });
});