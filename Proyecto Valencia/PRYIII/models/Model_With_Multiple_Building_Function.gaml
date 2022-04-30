/**
* Name: ModelWithMultipleBuildingFunction
* Based on the internal empty template. 
* Author: arnau
* Tags: 
*/


model ModelWithMultipleBuildingFunction

global {
	file shape_file_roads <- file("../includes/EJES-CALLE.shp");
	file shape_file_buildings <- file("../includes/buildings1.shp");
	geometry shape <- envelope(envelope(shape_file_buildings) + envelope(shape_file_roads));
	float step <- 10 #mn;
	date starting_date <- date("2022-01-01-00-00-00");
	int nb_people <- 200; /*800.100 */
	float pr_drivers <- 0.3;
	int min_work_start <- 6;
	int max_work_start <- 8;
	int min_work_end <- 16; 
	int max_work_end <- 20; 
	float min_speed_walk <- 1.0 #km / #h;
	float max_speed_walk <- 5.0 #km / #h;
	float max_speed_drive <- 50.0 #km / #h;
	float min_speed_drive <- 30.0 #km / #h;
	graph the_graph;
	
	init {
		create building from: shape_file_buildings with: [type::string(read ("uso")), Trabajo::int(read("Trabajo")), Ocio::int(read("Ocio")), Residencial::int(read("Resdncl")), Turismo::int(read("Turismo"))] {
			if type="Trabajo" {
				color <- #blue ;
			}
			if type = "Ocio"{
				color <- #green;
			}
			if type = "Turismo"{
				color <- #purple;
			}
			if type = "Area Terciaria y Residencial"{
				color <- #orange;
			}
		}
		create road from: shape_file_roads ;
		the_graph <- as_edge_graph(road);
		
		list<building> residential_buildings <- building where (each.Residencial=1);
		list<building> industrial_buildings <- building  where (each.Trabajo=1) ;
		list<building> recreative_buildings <- building where (each.Ocio=1);
		create people number: nb_people {
			speed <- rnd(min_speed_walk, max_speed_walk);
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			living_place <- one_of(residential_buildings);
			working_place <- one_of(industrial_buildings);
			objective <- "resting";
			location <- any_location_in (living_place);
			color <-  #yellow;
		}
	}
}


species building {
	string type;
	int Turismo;
	int Ocio;
	int Residencial;
	int Trabajo; 
	rgb color <- #gray;
	
	aspect base {
		draw shape color: color ;
	}
}

species road  {
	rgb color <- #black ;
	aspect base {
		draw shape color: color ;
	}
}

species people skills:[moving] {
	list<building> ocio;
	rgb color;
	string transport <- "pedestrian";
	building living_place <- nil ;
	building working_place <- nil ;
	int start_work ;
	int end_work  ;
	string objective ; 
	point the_target <- nil ;
	
	reflex using_car when: objective = "resting" and rnd(0.00, 1.00) <= pr_drivers and transport = "pedestrian"{
		speed <- rnd(min_speed_drive, max_speed_drive);
		color <- #red;
		transport <- "driver";
	}
	
	reflex walking when: objective = "resting" and rnd(0.00, 1.00) > pr_drivers and transport = "driver"{
		speed <- rnd(min_speed_drive, max_speed_drive);
		color <- #yellow;
		transport <- "pedestrian";
	}
	
		
	reflex time_to_work when: current_date.hour = start_work and (objective = "resting" or objective = "chilling"){
		objective <- "working" ;
		the_target <- any_location_in (working_place);
	}
		
	reflex time_to_go_home when: current_date.hour = end_work and objective = "working"{
		objective <- "resting" ;
		the_target <- any_location_in (living_place); 
	} 
	
	reflex tiempo_de_ocio when: objective = "resting" and rnd(0.0, 1.0) < 0.3 and current_date.hour < 20 and current_date.hour > 10{
		objective <- "chilling";
		the_target <- any_location_in(one_of(ocio));
	}
	
	reflex time_to_rest when: objective = "chilling" and current_date.hour > 20{
		objective <- "resting";
		the_target <- any_location_in (living_place);
	}
	 
	reflex move when: the_target != nil {
		do goto target: the_target on: the_graph ; 
		if the_target = location {
			the_target <- nil ;
		}
	}
	
	aspect base {
		draw circle(30) color: color border: #black;
	}
}



experiment road_traffic type: gui {
	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
	parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;	
	parameter "Number of people agents" var: nb_people category: "People" ;
	parameter "Earliest hour to start work" var: min_work_start category: "People" min: 2 max: 8;
	parameter "Latest hour to start work" var: max_work_start category: "People" min: 8 max: 12;
	parameter "Earliest hour to end work" var: min_work_end category: "People" min: 12 max: 16;
	parameter "Latest hour to end work" var: max_work_end category: "People" min: 16 max: 23;
	parameter "minimal speed walking" var: min_speed_walk category: "People" min: 0.1 #km/#h ;
	parameter "maximal speed walking" var: max_speed_walk category: "People" max: 10 #km/#h;
	parameter "minimal speed driving" var: min_speed_drive category: "People" min: 25 #km/#h ;
	parameter "maximal speed driving" var: max_speed_drive category: "People" max: 120 #km/#h;
	
	output {
		display city_display type: opengl {
			species building aspect: base ;
			species road aspect: base ;
			species people aspect: base ;
		}
	}
}