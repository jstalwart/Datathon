/**
* Name: Importaredificios
* Based on the internal empty template. 
* Author: arnau
* Tags: 
*/


model Importaredificios

/* Insert your model definition here */

global{
	/**file shape_file_roads <- file("C:/Users/arnau/Desktop/UPV/Programació/GAMA_1.8.1_Windows_with_JDK/PRYIII/shp_files/EJES-CALLE.shp");*/
	file shape_file_buildings <- file("../includes/buildings.shp");
	/**geometry shape <- envelope(envelope(shape_file_buildings)+envelope(shape_file_roads));*/
	geometry shape <- envelope(shape_file_buildings);
	graph the_graph;
	
	init {
		/**create roads from: shape_file_roads;*/
		create buildings from: shape_file_buildings;
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

experiment importar_edificios {
	/**parameter "Shapefile para las calles:" var: shape_file_roads category: "GIS";*/
	parameter "Shapefile para los edificios:" var: shape_file_buildings category: "GIS";
	
	output{
		display Valencia_display type: opengl {
			species roads aspect: base;
			species buildings aspect: base;
		}
	}
}

/* Insert your model definition here */


