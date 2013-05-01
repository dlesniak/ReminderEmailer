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
        //cache: true,
        error: function() {
          alert("There was an error loading events!");
        }
      }
    ],
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
        dataType: 'JSON',
        success: function() {
      // if we succeed do a get request for the new data
          $.ajax({
            url: '/api/v1/reminders/' + event.id + '/',
            type: 'GET',
            success: function(json) {
              event.start = json.start;
              event.end = json.end;
              $('#calendar').fullCalendar('updateEvent', event);
              if(event.repeat > 0){
                $('#calendar').fullCalendar('refetchEvents');
              }
              fetchUpcoming();
            },
            error: function() {
              alert("There was an error loading events!");
            }
          });
        },
        error: function() {
          alert("There was an error loading events!");
        }
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
      transformedData['backgroundColor'] = '#057af0';
      transformedData['textColor'] = '#FFFFFF';
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
      dataType: "JSON",
      success: function() {
        $("#calendar").fullCalendar("refetchEvents");
        $('#newReminder').modal('hide');
        $('#new_loader').hide();
        fetchUpcoming();
      },
      error: function() {
        alert("There was an error loading events!");
      }
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
      dataType: "JSON",
      success: function() {
        // if we succeed do a get request for the new data
        $.ajax({
          url: '/api/v1/reminders/' + clicked_event.id + '/',
          type: 'GET',
          success: function(json) {
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
            fetchUpcoming();
          },
          error: function() {
            alert("There was an error loading events!");
          }
        });
      },
      error: function() {
        alert("There was an error loading events!");
      }
    });
  });

  $('.edit_close').on('click', function(e) {
    clicked_event.attemptedDelete = false;
    $('#delete_reminder_button').attr('class', 'btn btn-warning delete_btn');
    $('#delete_reminder_button').text("Delete Reminder");
    clicked_event = null;
  });

  $('#editReminder').on('hidden', function() {
    if(clicked_event != null){
      clicked_event.attemptedDelete = false;
      $('#delete_reminder_button').attr('class', 'btn btn-warning delete_btn');
      $('#delete_reminder_button').text("Delete Reminder");
      clicked_event = null;
    }
  });

  $('#delete_reminder_button').on('click', function(e) {
    if(!clicked_event.attemptedDelete){
      $('#delete_reminder_button').attr('class', 'btn btn-danger delete_btn');
      $('#delete_reminder_button').text("Confirm Deletion");
      clicked_event.attemptedDelete = true;
    }else{
      $('#delete_loader').show();
      silly_data = $('#edit_reminder_form').serialize();
      $.ajax({
        url: '/api/v1/reminders/' + clicked_event.id + '/',
        type: 'DELETE',
        data: silly_data,
        dataType: 'JSON',
        success: function() {
          // the server responds with a 204, so there's no body
          $('#fullcalendar').fullCalendar('removeEvents', clicked_event.id);
          $('#editReminder').modal('hide');
          clicked_event = null;
          $('#calendar').fullCalendar('refetchEvents');
          $('#editReminder').modal('hide');
          $('#delete_loader').hide();
          fetchUpcoming();
        },
        error: function() {
          alert("There was an error loading events!");
        }
      });
    }
  });

  $('#eventSelect').change( function() {
    var selected = $('#eventSelect').find(':selected').val();
    $.ajax({
      url: '/api/v1/plugin_descriptors/' + selected + '/',
      type: 'GET',
      dataType: 'JSON', 
      success: function(json) {
        $('#eventForm').empty();
        $('#eventForm').html(json.form_html);
      },
      error: function() {
        alert("There was an error fetching plugins");
      }
    });
  });

  $('#eventForm').submit( function(e) {
    alert("form submitted");

    e.preventDefault();
  });

  fetchUpcoming();
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
  $('#edit_reminder_repeat').val(event.repeat);
  $('#edit_reminder_customhtml').val(event.customhtml);
};

function fetchUpcoming() {
  // remove all the old table rows, since we're refetching
  $('#upcomingTable').find('tr').remove();
  $('#upcomingTable').append('<tr id="loadingRow"><td>Loading...</td><td><img class="save_loader_img" src="/assets/ajax-loader.gif"></td></tr>');
  var now = new Date();
  var now = now.getTime() / 1000; // this gives us the current seconds since the epoch
  var future = now + 432000; // 60 sec/min * 60 min/hour * 24 hour/day * 5 days = 432,000 seconds
  $.ajax({
    url: '/api/v1/reminders?start=' + Math.floor(now) + '&end=' + Math.floor(future),
    type: 'GET',
    success: function(json) {
      $('#loadingRow').remove();
      for(var i = 0; i < json.length; i++){
        $('#upcomingTable').append('<tr><td>' + json[i].title + '</td><td>' + String(new Date(json[i].start)) + '</td></tr>');
      }
    },
    error: function() {
      alert("There was an error loading events!");
    }
  });
}