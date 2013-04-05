// There has to be a better way then keeping this global around
var clicked_event;
$(document).ready(function() {
  $('#calendar').fullCalendar({
    editable: true,
    eventSources: [
      {
        url: '/reminders.json',
        type: 'GET',
        cache: true,
        error: function() {
          alert("There was an error loading events!");
        }
      }
    ],
    dayClick: function(date, allDay, jsEvent, view) {
      alert(date + ' has been clicked!');
    },
    eventClick: function(event, jsEvent, view) {
      // Modify the action of the form to reflect the clicked events id
      $('#edit_reminder_form').attr('action', '/reminders/' + event.id + '/')
      // Fill in the form with data from the event
      $('#edit_reminder_title').val(event.title);
      $('#edit_reminder_start').val(event.start);
      $('#edit_reminder_end').val(event.end);
      $('#editReminder').modal('show');
      clicked_event = event;
    },
    eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
      alert(dayDelta);
    },
    loading: function(isLoading, view) {
      // The started loading and done loading callback
    },
    eventDataTransform: function(eventData) {
      // Can modify the data if it comes in a format fullcalendar doesn't understand
      return eventData;
    }
  });

  $('.date_picker_field').datetimepicker({
    dateFormat: 'D M d yy',
    timeFormat: 'HH:mm:ss z'
  });

  $('#save_reminder_link').on('click', function(e) {
    // stop the default linking behavior
    e.preventDefault();
    // submit the form
    $('#new_reminder_form').submit();
  });

  // More DRY violations
  $('#edit_reminder_link').on('click', function(e) {
    // stop the default linking behavior
    e.preventDefault();
    // submit the form
    var form = $('#edit_reminder_form');
    var sub_data = form.serialize();
    $.ajax({
      url: form.attr('action'),
      type: 'PUT',
      data: sub_data,
      dataType: "JSON"
    }).success(function(json){
      // refresh the data for the event
      clicked_event.start = json.start;
      clicked_event.end = json.end;
      clicked_event.title = json.title;
      //clicked_event.repeat = sub_data.repeat;
      $('#calendar').fullCalendar('updateEvent', clicked_event);
    });
  });

  $('.edit_close').on('click', function(e) {
    clicked_event = null;
  });
});