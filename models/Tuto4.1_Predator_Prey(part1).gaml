/**
* Name: Tuto4EbwalaebwalettePriscille
* Based on the internal empty template. 
* Author: Dell
* Tags: 
*/


model Tuto4_1EbwalaebwalettePriscille


/* Insert your model definition here */

global{//definir le nombre initial des herbes
	int taille_environnement <- 80 parameter: 'Width and Height' category: 'Environnment';
	int nbre_herbes <- 300 parameter:'nombre initieale des herbes'category:'herbes' min:300 max:1000;//creer les herbes aleatoire sur le terain
	geometry shape <- envelope(square(taille_environnement));
	init {
		
		//creer les herbes aleatoire sur le terain
		create herbe number: nbre_herbes{
			//location <- {rnd(shape.width),rnd(shape.height)};
			set location <- {rnd(taille_environnement- 1.5*size)+size, rnd(taille_environnement-3*size)+ size};
		}
		
	} 
	reflex stop {
		//si les herbe sont grandis et prend toute la surface de erain,
		//if(count(herbes where(size>= taille_maximale)) = nombre_initial_herbes){
		list<point> total_herbe_area<-[];
		loop element over:(list(herbe))
		{
			write length(total_herbe_area);
			total_herbe_area<-total_herbe_area+element.location;
			
		}
		if (length(total_herbe_area)>=(shape.width*shape.height)) {	
			//alors arreter la simmulation
			
			do pause;
		}	
	}

}

species name: herbe{
	float size <-rnd(2.0);//taille initiale de l'herbe
	rgb color <- #green;//la couleur #green ou vert
	float vitesse_grandir <- 0.5; //la vitesse de grandir(croissance) 
	float taille_neer_enfant  <- 5.0; //la taille a neer les enfants //comme la taille a etre manger par les agneaux egalement c'est la taille maximal
	int duree_neer_enfant <- 5; // je definie letemps avant qu'une nouvelle pousse(herbe) apparet
	int compteur <- 0; //compteur pour la reproduction
	float rayon_reproduction <- 1.0; // je definie ici le rayon de reproduction pour compter les voisin
	
	aspect basic{
		//dessiner sa forme avec la taille + la  couleurs
		draw square(size)color:color;
	}
	reflex grandir when: size < taille_neer_enfant//si la taille actuelle < la taille maximal
	{
		size <- size + vitesse_grandir;//augmenter la taille actuelle -> depend de la vitesse de grandir
		      
	}
	reflex neer_les_enfant when:size >= taille_neer_enfant //taille_neer_enfant //si la taille > la taille a neer_les_enfant
	{
		
		compteur <-compteur +1; //compteur le compte
		
		//si le compte >= duration a neer un enfant ,alors:
		if(compteur >= duree_neer_enfant){
			write "naissance";
			list<herbe> voisin_proches <- (self neighbors_at (rayon_reproduction));
			write voisin_proches ;
			write length(voisin_proches);
			if( length(voisin_proches) < 8  ){
				create herbe number: 1{
						location<- location+1;
						//self.size<-0.5;
						self.size <-rnd(2.0);
			}

			}
			compteur <- 0;
		}
	}
}

experiment name type: gui {

	output {
	display 'herbe' {
			//
				species herbe  aspect: basic;	
			}

	}
}
