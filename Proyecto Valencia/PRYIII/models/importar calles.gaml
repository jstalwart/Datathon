/**
* Name: Importar calles
* Based on the internal empty template. 
* Author: Arnau i Andreu
* Tags: 
*/


model importar_calles

global{
	file shape_file_roads <- file("../includes/EJES-CALLE.shp");
	/**file shape_file_buildings <- file("C:/Users/arnau/Desktop/UPV/Programació/GAMA_1.8.1_Windows_with_JDK/PRYIII/shp_files/calificaciones.shp");*/
	geometry shape <- envelope(shape_file_roads);
	graph the_graph;
	
	init {
		/**create buildings from: shape_file_buildings;*/
		create roads from: shape_file_roads;
		the_graph <- as_edge_graph(roads);
	}
}

species roads{
	rgb color <- #black;
	aspect base {
		draw shape color: color;
	}
}

species buildings{
	rgb color <- #grey;
	aspect base {
		draw shape color: color;
	}
}

experiment evacuacion_Valencia {
	parameter "Shapefile para las calles:" var: shape_file_roads category: "GIS";
	
	output{
		display Valencia_display type: opengl {
			species roads aspect: base;
			species buildings aspect: base;
		}
	}
}

/* Insert your model definition here */

