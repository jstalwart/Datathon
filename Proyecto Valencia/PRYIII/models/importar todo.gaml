/**
* Name: importartodo
* Based on the internal empty template. 
* Author: arnau
* Tags: 
*/


model importartodo

global{
	file shape_file_roads <- file("C:/Users/arnau/Desktop/UPV/Programació/GAMA_1.8.1_Windows_with_JDK/PRYIII/shp_files/EJES-CALLE.shp");
	file shape_file_buildings <- file("C:/Users/arnau/Desktop/UPV/Programació/GAMA_1.8.1_Windows_with_JDK/PRYIII/shp_files/buildings1.shp");
	geometry shape <-envelope(envelope(shape_file_buildings) + envelope(shape_file_roads));
	
	float step <- 10 #mn;
	date starting_date <- date("2019-09-01-00-00-00");
	
	int nb_people <- 100;
	int min_work_start <- 6;
	int max_work_start <- 9;
	int min_work_end <- 16;
	int max_work_end <- 20;
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h;
	graph the_graph;	
	
	init {
		create building from: shape_file_buildings with: [type::string(read("uso"))]{
			if type = "Trabajo" {
				color <- #blue;
			}
			if type = "Ocio"{
				color <- #green;
			}
			if type = "Turismo"{
				color <- #purple;
			}
			
		}
		create roads from: shape_file_roads;
		the_graph <- as_edge_graph(roads);
		
		list<building> residential_buildings <- building where (each.type="Residencial");
		list<building> work_buildings <- building where (each.type="Trabajo");
		create people number: nb_people{
			speed <- rnd(min_speed, max_speed);
			start_work <- rnd(min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			living_place <- one_of (residential_buildings);
			working_place <- one_of(work_buildings);
			objective <- "resting";
			location <- any_location_in(living_place);
		}
	}
}

species roads{
	rgb color <- #black;
	aspect base {
		draw shape color: color;
	}
}

species building{
	rgb color <- #gray;
	string type;
	aspect base {
		draw shape color: color;
	}
}

species people skills:[moving]{
	rgb color <- #yellow;
	building living_place <- nil;
	building working_place <- nil;
	int start_work;
	int end_work;
	string objective;
	point the_target <- nil;
	
	reflex time_to_work when: current_date.hour = start_work and objective = "resting" {
		objective <- "working";
		the_target <- any_location_in(working_place);
	}
	
	reflex time_to_go_home when: current_date.hour = start_work and objective = "working" {
		objective <- "resting";
		the_target <- any_location_in(living_place);
		}
		
	
	reflex move when: the_target != nil{
		do goto target: the_target on: the_graph;
		if the_target = location{
			the_target <- nil;
		}
	}
	
	
	aspect base{
		draw circle(30) color: color border: #black;
	}
}

experiment evacuacion_Valencia type: gui{
	parameter "Shapefile para las calles:" var: shape_file_roads category: "GIS";
	parameter "Shapefile para los edificios:" var: shape_file_buildings category: "GIS";
	parameter "Número de habitantes:" var: nb_people category: "Población";
	
	output{
		display Valencia_display type: opengl {
			species roads aspect: base;
			species building aspect: base;
			species people aspect: base;
		}
	}
}

/* Insert your model definition here */

