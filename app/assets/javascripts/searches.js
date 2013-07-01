$(document).ready (function() {
	equi();
});

function equi() {
	var width = 1200,
    height = 600;

	var projection = d3.geo.equirectangular()
			.scale(191.25)
			.translate([width / 2, height / 2])
			.precision(.1);

	var path = d3.geo.path()
			.projection(projection);

	var graticule = d3.geo.graticule();

	var svg = d3.select("#map").append("svg")
			.attr("width", width)
			.attr("height", height);

	svg.append("path")
			.datum(graticule)
			.attr("class", "graticule")
				.attr("d", path);

	d3.json("/world-50m.json", function(world) {
		  svg.insert("path", ".graticule")
			  .datum(topojson.feature(world, world.objects.land))
			  .attr("class", "land")
			  .attr("d", path);

	  svg.insert("path", ".graticule")
			  .datum(topojson.mesh(world, world.objects.countries, function(a, b) { return a !== b; }))
			  .attr("class", "boundary")
			  .attr("d", path);
	});


	d3.select(self.frameElement).style("height", height + "px");
	
	$("#search_submit").click(function() {
		svg.selectAll('circle').remove()
		loading_tweets("start",projection,svg);
		$.ajax({
			  type: "POST",
			  url: "/searches.json",
		  data: { term: $("#search_field").val() }
		}).done(function( json ) {
			loading_tweets("stop",projection,svg);
			tweets_to_map(json,projection,svg);
		});
	});
}

function tweets_to_map(json,projection,svg) {
	add_tweets(json.positive,'green',projection,svg);
	add_tweets(json.negative,'red',projection,svg);
	add_tweets(json.neutral,'white',projection,svg);
}

function add_tweets(tweets, color, projection, svg) {
	$.each(tweets, function(i, item) {
		if (item.lat) {
			var coords = projection([item.lng, item.lat]);
			svg.append('circle')
			.attr('cx', coords[0])
			.attr('cy', coords[1])
			.attr('r', 2)
			.style('fill', color);
		}
	});
}

function loading_tweets(toggle,projection,svg) {
//	var lng = Math.random()*181;
//	var lat = Math.random()*91;
	var coords = projection(['105', '40']);
	svg.append("circle")
	.attr('cx', coords[0])
	.attr('cy', coords[1])
	.attr('r', 2)
	.style('fill', 'white');
}

