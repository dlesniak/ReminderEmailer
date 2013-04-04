$(document).ready(function() {
  $('#calendar').fullCalendar({
    editable: true,
    eventSources: [
      {
        url: '/reminders.json',
        type: 'GET',
        error: function() {
          alert("There was an error loading events!");
        }
      }
    ],
    dayClick: function(date, allDay, jsEvent, view) {
      alert(date + ' has been clicked!');
    },
    eventClick: function(event, jsEvent, view) {
      // Fill in the form with data from the event
      $('#edit_reminder_title').val(event.title);
      $('#edit_reminder_start').val(event.start);
      $('#edit_reminder_end').val(event.end);
      $('#editReminder').modal('show');
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

  $('.date_picker_field').datetimepicker();

  $('#save_reminder_link').on('click', function(e) {
    // stop the default linking behavior
    e.preventDefault();
    // submit the form
    $('#new_reminder_form').submit();
  });
});