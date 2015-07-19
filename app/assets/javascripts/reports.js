// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('ready page:load', function () {



  var todoDone = $('#reportVis').data('todo-done');
  var width = $('#reportVis').width(),
      height = 400;

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






});