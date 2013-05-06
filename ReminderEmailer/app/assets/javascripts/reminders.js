// There has to be a better way then keeping this global around
var clicked_event;
var selected_plugin_id;
var events = {};

// Plugin forms don't include the csrf token since thier dynamic. Consider doing this a bit more carefully...
$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader("X-CSRF-Token", token);
});

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
          console.log("There was an error loading events in the first place");
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
      var access_token = $("#SuperSecretAccessToken").text();
      // This is essentially a sneaky update, so we send a put message to the server
      $.ajax({
        url: '/api/v1/reminders/' + event.id + '/',
        headers: {'Authorization': access_token},
        type: 'PUT',
        data: serialized,
        dataType: 'JSON',
        success: function() {
      // if we succeed do a get request for the new data
          $.ajax({
            url: '/api/v1/reminders/' + event.id + '/',
            headers: {'Authorization': access_token},
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
              console.log("There was an error loading events in eventDrop's GET");
            }
          });
        },
        error: function() {
          console.log("There was an error loading events in eventDrop's PUT");
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
      if(eventData.source === "event_bot"){
        transformedData['backgroundColor'] = '#FFE800';
        transformedData['textColor'] = '#000000';
        transformedData['borderColor'] = '#737373';
      }else if(eventData.source == "organization"){
        transformedData['backgroundColor'] = '#178510';
        transformedData['textColor'] = '#FFFFFF';
        transformedData['borderColor'] = '#737373';
      }else{
        transformedData['backgroundColor'] = '#057af0';
        transformedData['textColor'] = '#FFFFFF';
        transformedData['borderColor'] = '#737373';
      }
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
    var access_token = $("#SuperSecretAccessToken").text();
    $('.new_loader').show();
    // stop the default linking behavior
    e.preventDefault();
    // submit the form
    //$('#new_reminder_form').submit();
    var form = $('#new_reminder_form');
    var sub_data = form.serialize();
    $.ajax({
      url: '/api/v1/reminders/',
      headers: {'Authorization': access_token},
      type: 'POST',
      data: sub_data,
      dataType: "JSON",
      success: function() {
        $("#calendar").fullCalendar("refetchEvents");
        $('#newReminder').modal('hide');
        $('.new_loader').hide();
        fetchUpcoming();
      },
      error: function() {
        console.log("There was an error loading events!");
      }
    });
  });

  // More DRY violations
  $('#edit_reminder_link').on('click', function(e) {
    var access_token = $("#SuperSecretAccessToken").text();
    $('.edit_loader').show();
    // stop the default linking behavior
    e.preventDefault();
    // submit the form
    var form = $('#edit_reminder_form');
    var sub_data = form.serialize();
    $.ajax({
      url: '/api/v1/reminders/' + clicked_event.id + '/',
      headers: {'Authorization': access_token},
      type: 'PUT',
      data: sub_data,
      dataType: "JSON",
      success: function() {
        // if we succeed do a get request for the new data
        $.ajax({
          url: '/api/v1/reminders/' + clicked_event.id + '/',
          headers: {'Authorization': access_token},
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
            $('.edit_loader').hide();
            fetchUpcoming();
          },
          error: function() {
            console.log("There was an error loading events in edit's GET");
          }
        });
      },
      error: function() {
        console.log("There was an error loading events in edit's PUT");
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
    var access_token = $("#SuperSecretAccessToken").text();
    if(!clicked_event.attemptedDelete){
      $('#delete_reminder_button').attr('class', 'btn btn-danger delete_btn')
      $('#delete_reminder_button').text("Confirm Deletion");
      clicked_event.attemptedDelete = true;
    }else{
      $('.delete_loader').show();
      silly_data = $('#edit_reminder_form').serialize();
      $.ajax({
        url: '/api/v1/reminders/' + clicked_event.id + '/',
        headers: {'Authorization': access_token},
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
          $('.delete_loader').hide();
          fetchUpcoming();
        },
        error: function() {
          console.log("There was an error loading events in delete's DELETE");
        }
      });
    }
  });

  $('#eventSelect').change( function() {
    var access_token = $("#SuperSecretAccessToken").text();
    var selected = $('#eventSelect').find(':selected').val();
    if(selected === '0'){
      $('#eventForm').empty();
      $('#save_event_link').hide();
    }else{
      $('#eventForm').html('<p>Loading Form...</p>');
      $.ajax({
        url: '/api/v1/plugin_descriptors/' + selected + '/',
        headers: {'Authorization': access_token},
        type: 'GET',
        dataType: 'JSON', 
        success: function(json) {
          $('#eventForm').empty();
          $('#eventForm').html(json.form_html);
          $('#pluginDescription p').text(json.description);
          $('#pluginDescription').show();
          selected_plugin_id = json.id;
          $('#save_event_link').show();
        },
        error: function() {
          console.log("There was an error fetching plugins");
        }
      });
    }
  });

  $('#eventForm').submit( function(e) {
    alert("You shouldn't have a submit in your form html!");
    e.preventDefault();
  });

  $('#newEvent').on('hidden', function() {
    $('#eventSelect').val('0');
    $('#eventForm').empty();
    $('#save_event_link').hide();
    $('#pluginDescription').hide();
    $('#pluginDescription p').empty();
    selected_plugin_id = 0;
  });

  $('#editEvent').on('hidden', function() {
    $('#edit_eventForm').empty();
    $('#edit_pluginDescription p').empty();
    $('#delete_event_link').off('click');
    $('#edit_event_link').off('click');
    var e_id = $('#delete_event_link').attr('data-eid');
    events[e_id].attemptedDelete = false;
    $('#delete_event_link').removeAttr('data-eid');
    $('#delete_event_link').attr('class', 'btn btn-warning delete_btn');
    $('#delete_event_link').text("Delete Event");
  });

  $('#save_event_link').on('click', function() {
    var form = $('#eventForm');
    var json_dump = {};
    form.find('input').each(function(i, val) {
      json_dump[$(val).attr('name')] = $(val).val();
    });
    save_json = {'plugin_id': selected_plugin_id, 'configuration': JSON.stringify(json_dump)};
    access_token = $('#SuperSecretAccessToken').text();
    $('.save_loader').show();
    $.ajax({
      url: '/api/v1/active_events/',
      type: 'POST',
      headers: {'Authorization': access_token},
      data: save_json,
      dataType: 'JSON',
      success: function() {
        $('#newEvent').modal('hide');
        $('.save_loader').hide();
        fetchEvents();
      },
      error: function() {
        $('.save_loader').hide();
        console.log("There was a problem registering the event!");
      }
    });
  });

  fetchUpcoming();
  fetchEvents();
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
  var access_token = $("#SuperSecretAccessToken").text();
  // remove all the old table rows, since we're refetching
  $('#upcomingTable').find('tr').remove();
  $('#upcomingTable').append('<tr id="loadingRow"><td>Loading...</td><td><img class="save_loader_img" src="/assets/ajax-loader.gif"></td></tr>');
  var now = new Date();
  var now = now.getTime() / 1000; // this gives us the current seconds since the epoch
  var future = now + 432000; // 60 sec/min * 60 min/hour * 24 hour/day * 5 days = 432,000 seconds
  $.ajax({
    url: '/api/v1/reminders?start=' + Math.floor(now) + '&end=' + Math.floor(future),
    headers: {'Authorization': access_token},
    type: 'GET',
    success: function(json) {
      $('#loadingRow').remove();
      for(var i = 0; i < json.length; i++){
        $('#upcomingTable').append('<tr><td>' + json[i].title + '</td><td>' + String(new Date(json[i].start)) + '</td></tr>');
      }
    },
    error: function() {
      console.log("There was an error loading reminders in fetchUpcoming's GET");
    }
  });
}

function fetchEvents(){
  var access_token = $("#SuperSecretAccessToken").text();
  $('#eventsTable').find('tr').remove();
  $('#eventsTable').append('<tr id="events_loadingRow"><td>Loading...</td><td><img class="save_loader_img" src="/assets/ajax-loader.gif"></td></tr>');
  $.ajax({
    url: '/api/v1/active_events/',
    headers: {'Authorization': access_token},
    type: 'GET',
    dateType: 'JSON',
    success: function(json) {
      $('#events_loadingRow').remove();
      for(var i = 0; i < json.length; i++){
        events[String(json[i].id)] = json[i];
        events[String(json[i].id)]['attemptedDelete'] = false;
        $('#eventsTable').append('<tr><td>' + json[i].title + '</td><td><button name="' + json[i].id + '" class="btn btn-info" data-pid="' + json[i].plugin_id + '">Edit Event</button>' + '</td></tr>');
      }
      $('#eventsTable button').on('click', eventEditHandler);
    },
    error: function() {
      console.log("There was an error loading events in fetchEvent's GET")
    }
  });
}

function eventEditHandler(ev) {
  var access_token = $("#SuperSecretAccessToken").text();
  var p_id = $(this).attr('data-pid');
  var e_id = $(this).attr('name');
  $.ajax({
    url: '/api/v1/plugin_descriptors/' + p_id + '/',
    headers: {'Authorization': access_token},
    type: 'GET',
    dataType: 'JSON',
    success: function(json) {
      $('#edit_eventForm').empty();
      $('#edit_eventForm').html(json.form_html);
      $('#edit_pluginDescription p').text(json.description);
      $('#edit_pluginTitle h5').text(json.title);
      $('#delete_event_link').attr('data-eid', e_id);

      $('#delete_event_link').on('click', deleteEvent);
      $('#edit_event_link').on('click', saveEventEdit);

      // fill out the form
      var config = JSON.parse(events[e_id].configuration);
      for(var key in config) {
        if(config.hasOwnProperty(key)) {
          $('#edit_eventForm [name="' + key + '"]').val(config[key]);
        }
      }

      selected_plugin_id = json.id;
      $('#editEvent').modal('show');
    },
    error: function() {
      console.log("There was an error fetching plugins");
    }
  });
}

function saveEventEdit() {
  var e_id = $('#delete_event_link').attr('data-eid');
  var form = $('#edit_eventForm');
  var json_dump = {};
  form.find('input').each(function(i, val) {
    json_dump[$(val).attr('name')] = $(val).val();
  });
  save_json = {'plugin_id': selected_plugin_id, 'configuration': JSON.stringify(json_dump)};
  access_token = $('#SuperSecretAccessToken').text();
  $('.edit_loader').show();
  $.ajax({
    url: '/api/v1/active_events/' + e_id + '/',
    type: 'PUT',
    headers: {'Authorization': access_token},
    data: save_json,
    dataType: 'JSON',
    success: function() {
      $('#editEvent').modal('hide');
      $('.edit_loader').hide();
      fetchEvents();
    },
    error: function() {
      console.log("There was a problem registering the event!");
      $('.edit_loader').hide();
    }
  });
}

function deleteEvent() {
  var access_token = $("#SuperSecretAccessToken").text();
  var e_id = $('#delete_event_link').attr('data-eid');
  if(!events[e_id].attemptedDelete){
    events[e_id].attemptedDelete = true;
    $('#delete_event_link').attr('class', 'btn btn-danger delete_btn');
    $('#delete_event_link').text("Confirm Deletion");
  }else{
    $('.delete_loader').show();
    $.ajax({
      url: '/api/v1/active_events/' + e_id + '/',
      headers: {'Authorization': access_token},
      type: 'DELETE',
      success: function() {
        $('.delete_loader').hide();
        $('#editEvent').modal('hide');
        fetchEvents();
      },
      error: function() {
        console.log("There was an error in deleteEvent's DELETE");
        $('.delete_loader').hide();
      }
    });
  }
}