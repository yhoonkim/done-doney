// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('ready page:load', function () {
  var todoDone = $('#reportVis').data('todo-done');
  var width = $('#reportVis').width(),
      height = 400;

  var rScale = d3.scale.linear()
                       .domain([0, todoDone.average * 2])
                       .range([10, height / 2 * 0.9]);

  var fontScale = d3.scale.linear()
                       .domain([0, todoDone.average, todoDone.average * 2])
                       .range([10, height / 4 * 0.9, height / 4 * 0.9]);

  function avgCircleClass(){
    if( todoDone.average > todoDone.today ){
      return "averageCircle";
    }
    else
      return "averageCircle invert"
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
                          .attr("class", avgCircleClass() )
                          .attr("cx", width/2 )
                          .attr("cy", height/2 )
                          .attr("r", rScale(todoDone.average) )
                          .attr("stroke-dasharray", "10, 10")




});