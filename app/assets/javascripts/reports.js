// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('ready page:load', function () {

  var flash = $('#flash').data('flash');
  if( flash.errors) {
    for (var i = 0; i < flash.errors.length; i++) {
      Materialize.toast("<span class='red-text text-lighten-2'>"+flash.errors[i]+"</span>", 4000);
    };
  }
  else if (flash.successes) {
    for (var i = 0; i < flash.successes.length; i++) {
      Materialize.toast("<span class='blue-text text-lighten-2'>"+flash.successes[i]+"</span>", 4000);
    };
  };


  var todoDone = $('#reportVis').data('todo-done');
  var width = $('#reportVis').width(),
      height = 400;
  todoDone.average = Math.round(todoDone.average*100) / 100;

  var rScale = d3.scale.linear()
                       .domain([0, todoDone.average * 2])
                       .range([10, height / 2 * 0.9])
                       .clamp(true);

  var fontScale = d3.scale.linear()
                       .domain([0, todoDone.average, todoDone.average * 2])
                       .range([10, height / 4 * 0.9, height / 4 * 0.9]);

  function avgLabelX(avg, today){
    if( avg >= today )
      return height/2 + rScale(todoDone.average) + 16;
    else
      return height/2 + rScale(todoDone.average) - 16;

  }

  function invertClass(className){
    if( todoDone.average > todoDone.today ){
      return className;
    }
    else
      return className + " invert"
  }

  var svg = d3.select("div#reportVis")
              .append("svg")
                .attr("width", width)
                .attr("height", height);
  var circles = svg.append("g")
                    .attr("class", "circles")


  var nowCircle = circles.append("circle")
                        .attr("class", "nowCircle")
                        .attr("cx", width/2 )
                        .attr("cy", height/2 )
                        .attr("r", rScale(todoDone.today) )

  var nowPointText = circles.append("text")
                              .attr("class", "nowPointText")
                              .attr("x", width/2)
                              .attr("y", height/2)
                              .attr("font-size", fontScale(todoDone.today))
                              .attr("fill", "white")
                              .attr("dy", ".35em")
                              .attr("text-anchor", "middle")
                              .text(todoDone.today)

  var averageCircle = circles.append("circle")
                          .attr("class", invertClass("averageCircle") )
                          .attr("cx", width/2 )
                          .attr("cy", height/2 )
                          .attr("r", rScale(todoDone.average) )
                          .attr("stroke-dasharray", "10, 10")

  var avgPointText = circles.append("text")
                              .attr("class", invertClass("avgPointText") )
                              .attr("x", width/2 )
                              .attr("y", avgLabelX(todoDone.average, todoDone.today))
                              .attr("font-size", "10pt")
                              .attr("dy", ".35em")
                              .attr("opacity", 0.7)
                              .attr("text-anchor", "middle")
                              .text("avg : " + todoDone.average)

  $('.modal-trigger').leanModal();
  $('.datepicker').pickadate({
    selectMonths: true, // Creates a dropdown to control month
    selectYears: 15 // Creates a dropdown of 15 years to control year
  });
  $('select').material_select();




  $(".gauge").css("width", function(){
    var remainedDay = $(this).data("dday");
    var curr_width = 83.33;
    console.log(curr_width);

    if(remainedDay>=14)
      return curr_width + "%"
    else if (remainedDay >0)
      return Math.round(curr_width * remainedDay / 14 * 100 )/100 + "%";
    else
      return "0%"

  });


  $(".btn-small").addClass(function(){
    var point = $(this).html().trim();
    return point_to_colorClass(point);

  });

  $(".jq-change-point").on('click',function(){
    var JQthis = $(this);
    var sendingData = { which: JQthis.data('which'), id: Number(JQthis.data('which-id')), point: Number(JQthis.data('point'))  }

    if (JQthis.data('clickable') ) {
      if (sendingData.which === "new-task") {
        change_color(JQthis, sendingData);
        $('#task_point').val(sendingData.point);
      }
      else{
        $.ajax({
          method: "GET",
          url: "/change_point",
          data: sendingData,
        }).done(function() {
          change_color(JQthis, sendingData);
          Materialize.toast("<span class='blue-text text-lighten-2'>It's done! :)</span>", 4000)
        })
        .fail(function(data) {
          alert( "error : " + data.error  );
        })

        Materialize.toast("Ok,,, updating the point", 4000);
      }
    }

  })

  $("#jq-add-task").on('click',function(){
    var JQthis = $(this);
    var sendingDataTemp = {};
    var sendingData = {};

    $("#new_task").serializeArray().map(function(x){
      if(x.name.match(/task\[(.*)\]$/g)) {
        sendingData[x.name.replace(/task\[(.*)\]$/g,"$1")] = x.value;
      }
    });


    $.ajax({
          method: "POST",
          url: "/tasks",
          data: {"task":sendingData},
          dataType: 'json'
        }).done(function( data, textStatus, jqXHR )  {
          console.log(data);
          Materialize.toast("<span class='blue-text text-lighten-2'>"+data.responseText+"</span>", 4000);
        })
        .fail(function(data) {
          console.log(data);
          Materialize.toast("<span class='red-text '>"+data.responseText+"</span>", 4000);
        });

    Materialize.toast("Ok,,, adding new task...", 4000);


  })

  function change_color(JQthat, sendingData) {
    var targetID = JQthat.data('dropdown-id');
    var JQdropdownButtons = $('a.' + targetID);
    var newClass = 'dropdown-button btn-floating btn-small ' + point_to_colorClass(sendingData.point) + ' ' + targetID

    var JQdropdownList = $('ul.'+targetID).children('li');
    var Listitem;
    var JQlistitemLink;
    var itemPoint;

    JQdropdownButtons.html(sendingData.point);
    JQdropdownButtons.attr('class' , newClass);


    for (var i = 0; i < JQdropdownList.length; i++) {
      Listitem = JQdropdownList[i];
      JQlistitemLink = $(Listitem.children[0]);
      itemPoint = Number(JQlistitemLink.data('point'));

      if( itemPoint === sendingData.point){
        $(Listitem).attr('class', point_to_colorClass(sendingData.point));
        JQlistitemLink.attr('class', 'black-text jq-change-point' );
        JQlistitemLink.data('clickable', false);
      }
      else if ( itemPoint !== sendingData.point){
        $(Listitem).attr('class', 'grey darken-1');
        JQlistitemLink.attr('class', point_to_colorClass(itemPoint, true) + ' jq-change-point');
        JQlistitemLink.data('clickable', true);
      }


    };
  }

  function point_to_colorClass (point, isText ) {
    var colorCode = ["green lighten-2", "lime", "yellow", "orange", "red lighten-2" ]
    if( isText )
      colorCode = ["green-text text-lighten-2", "lime-text", "yellow-text", "orange-text", "red-text text-lighten-2" ]

    var color = "grey"
    point = Number(point);
    if( point === 1 ){
      color = colorCode[0];
    }
    else if (point === 2) {
      color = colorCode[1];
    }
    else if (point === 3) {
      color = colorCode[2];
    }
    else if (point === 5) {
      color = colorCode[3];
    }
    else if (point === 8) {
      color = colorCode[4];
    }
    return color;
  }

});