$(document).ready (function() {
	equi();
	search = null;
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
		search = "start";
		start_search(projection,svg,null);
		$('p.search_stop').html("Searching for "+$('#search_field').val());
		$('.search_start').hide();
		$('.search_stop').show();
	});

	$("#stop_search").click(function() {
		search = "stop";
		$('p.search_stop').html("");
		$('.search_start').show();
		$('.search_stop').hide();
	});
}

function start_search(projection,svg,max_id) {
	if (search=="start") {
		$.ajax({
			  type: "POST",
			  url: "/searches.json",
		  data: { term: $("#search_field").val(), max_id:max_id }
		}).done(function( json ) {
			tweets_to_map(json,projection,svg);
			var max = json.max_id;
			start_search(projection,svg,max);
		});
	}
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


