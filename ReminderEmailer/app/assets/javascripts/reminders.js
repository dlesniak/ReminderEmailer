// There has to be a better way then keeping this global around
var clicked_event;
$(document).ready(function() {
  $('#calendar').fullCalendar({
    editable: true,
    ignoreTimezone: true,
    eventSources: [
      {
        url: '/api/v1/reminders',
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
      // Fill in the form with data from the event
      fillEditForm(event);
      $('#editReminder').modal('show');
      clicked_event = event;
    },
    eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
      var deltaApplied = applyDeltas(event, dayDelta, minuteDelta);
      fillEditForm(deltaApplied);
      var serialized = $('#edit_reminder_form').serialize();
      // This is essentially a sneaky update, so we send a put message to the server
      $.ajax({
        url: '/api/v1/reminders/' + event.id + '/',
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
      transformedData['repeat'] = eventData.repeat;
      transformedData['start'] = eventData.start;
      transformedData['end'] = eventData.end;
      transformedData['customhtml'] = eventData.customhtml;
      transformedData['color'] = '#049CDB';
      transformedData['textColor'] = '#000000';
      transformedData['attemptedDelete'] = false;
      return transformedData;
    }
  });
  $('.date_picker_field').datetimepicker({
    dateFormat: 'D M d yy',
    timeFormat: 'HH:mm:ss z',
    useLocalTimezone: true,
    showTimezone: true,
    timezone: 'CDT',
    timezoneList: [ 
                    { value: 'EST', label: 'Eastern'}, 
                    { value: 'CDT', label: 'Central' }, 
                    { value: 'MST', label: 'Mountain' }, 
                    { value: 'PST', label: 'Pacific' } 
                  ]
  });

  $('#save_reminder_link').on('click', function(e) {
    $('#new_loader').show();
    // stop the default linking behavior
    e.preventDefault();
    // submit the form
    //$('#new_reminder_form').submit();
    var form = $('#new_reminder_form');
    var sub_data = form.serialize();
    $.ajax({
      url: '/api/v1/reminders/',
      type: 'POST',
      data: sub_data,
      dataType: "JSON"
    }).success( function() {
      $("#calendar").fullCalendar("refetchEvents");
      $('#newReminder').modal('hide');
      $('#new_loader').hide();
    });
  });

  // More DRY violations
  $('#edit_reminder_link').on('click', function(e) {
    $('#edit_loader').show();
    // stop the default linking behavior
    e.preventDefault();
    // submit the form
    var form = $('#edit_reminder_form');
    var sub_data = form.serialize();
    $.ajax({
      url: '/api/v1/reminders/' + clicked_event.id + '/',
      type: 'PUT',
      data: sub_data,
      dataType: "JSON"
    }).success( function() {
      // if we succeed do a get request for the new data
      $.ajax({
        url: '/api/v1/reminders/' + clicked_event.id + '/',
        type: 'GET'
      }).success( function(json) {
        // refresh the data for the event
        clicked_event.start = json.start;
        clicked_event.end = json.end;
        clicked_event.repeat = json.repeat;
        clicked_event.title = json.title;
        clicked_event.customhtml = json.customhtml;
        //clicked_event.repeat = sub_data.repeat;
        $('#calendar').fullCalendar('updateEvent', clicked_event);
        if(json.repeat > 0){
          $('#calendar').fullCalendar('refetchEvents');
        }
        $('#editReminder').modal('hide');
        $('#edit_loader').hide();
      });
    });
  });

  $('.edit_close').on('click', function(e) {
    clicked_event.attemptedDelete = false;
    $('#delete_reminder_button').text("Delete Reminder");
    clicked_event = null;
  });

  $('#delete_reminder_button').on('click', function(e) {
    if(!clicked_event.attemptedDelete){
      $('#delete_reminder_button').text("Confirm Deletion");
      clicked_event.attemptedDelete = true;
    }else{
      $('#delete_loader').show();
      $.ajax({
        url: '/api/v1/reminders/' + clicked_event.id + '/',
        type: 'DELETE'
      }).success( function() {
        // the server responds with a 204, so there's no body
        $('#fullcalendar').fullCalendar('removeEvents', clicked_event.id);
        $('#editReminder').modal('hide');
        clicked_event = null;
        $('#calendar').fullCalendar('refetchEvents');
        $('#editReminder').modal('hide');
        $('#delete_loader').hide();
      });
    }
  });
});

function applyDeltas(reminder, dayDelta, minuteDelta){
  var deltaApplied = reminder;
  deltaApplied.start.day = deltaApplied.start.day + dayDelta;
  deltaApplied.end.day = deltaApplied.end.day + dayDelta;

  deltaApplied.start.minute = deltaApplied.start.minute + minuteDelta;
  deltaApplied.end.minute = deltaApplied.end.minute + minuteDelta;
  return deltaApplied;
};

function fillEditForm(event){
  $('#edit_reminder_title').val(event.title);
  $('#edit_reminder_start').val(event.start);
  $('#edit_reminder_end').val(event.end);
  $('#edit_reminder_repeat').val(event.repeat);
  $('#edit_reminder_customhtml').val(event.customhtml);
};