// There has to be a better way then keeping this global around
var clicked_event;
$(document).ready(function() {
  $('#calendar').fullCalendar({
    editable: true,
    ignoreTimezone: true,
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
      var deltaApplied = applyDeltas(event, dayDelta, minuteDelta);
      var serialized = serializeReminder(deltaApplied);
      // This is essentially a sneaky update, so we send a put message to the server
      $.ajax({
        url: '/reminders/' + event.id + '/',
        type: 'PUT',
        data: serialized,
        dataType: 'JSON'
      }).success( function(json) {
        event.start = json.start;
        event.end = json.end;
        $('#calendar').fullCalendar('updateEvent', event);
      });
    },
    loading: function(isLoading, view) {
      // The started loading and done loading callback
    },
    eventDataTransform: function(eventData) {
      // Can modify the data if it comes in a format fullcalendar doesn't understand
      var transformedData = {};
      transformedData['id'] = eventData.id;
      transformedData['title'] = eventData.title;
      transformedData['allDay'] = eventData.allDay;
      transformedData['start'] = eventData.start;
      transformedData['end'] = eventData.end;

      return transformedData;
    }
  });

  $('.date_picker_field').datetimepicker({
    dateFormat: 'D M d yy',
    timeFormat: 'HH:mm:ss z',
    useLocalTimezone: true,
    showTimezone: true,
    timezone: 'CT',
    timezoneList: [ 
                    { value: 'ET', label: 'Eastern'}, 
                    { value: 'CT', label: 'Central' }, 
                    { value: 'MT', label: 'Mountain' }, 
                    { value: 'PT', label: 'Pacific' } 
                  ]
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
    console.log(sub_data);
    $.ajax({
      url: form.attr('action'),
      type: 'PUT',
      data: sub_data,
      dataType: "JSON"
    }).success( function(json) {
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

function serializeReminder(reminder){
  var data = {
    'edit_reminder[title]': reminder.title,
    'edit_reminder[start]': reminder.start,
    'edit_reminder[end]': reminder.end
  }
  return data;
};

function applyDeltas(reminder, dayDelta, minuteDelta){
  var deltaApplied = reminder;
  deltaApplied.start.day = deltaApplied.start.day + dayDelta;
  deltaApplied.end.day = deltaApplied.end.day + dayDelta;

  deltaApplied.start.minute = deltaApplied.start.minute + minuteDelta;
  deltaApplied.end.minute = deltaApplied.end.minute + minuteDelta;
  return deltaApplied;
};