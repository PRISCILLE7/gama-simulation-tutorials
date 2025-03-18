model tuto5_1

global {
    init {
        create building;
        create exit number: 4;
        create person number: 50;
        create fire number: 3;
    }
}

species building {
    geometry shape <- rectangle(100, 100);
    
    init {
        location <- {0, 0};
    }
}

species exit {
    geometry shape <- circle(2);
    
    init {
        location <- any_location_in(building);
    }
}

species fire {
    float intensity <- 1.0;
    geometry shape <- circle(5);
    
    action spread() {
        intensity <- intensity + 0.1;
        shape <- circle(5 + intensity);
    }
    
    reflex basic_behavior {
        do spread;
    }
}

species person {
    float speed <- 1.0;
    point target;
    
    action move() {
        target <- first(exit).location;
        location <- location + (target - location) / 10;
    }
    
    action avoid_fire() {
        fire nearest_fire <- first(fire);
        if (nearest_fire != nil) {
            point away_from_fire <- location + (location - nearest_fire.location) / 5;
            location <- away_from_fire;
        }
    }
    
    reflex basic_behavior {
        do move;
        do avoid_fire;
    }
}

experiment Simulation type: gui {
    output {
        display "Evacuation" {
            species building color: #95a5a6;
            species exit color: #27ae60;
            species fire color: #e74c3c;
            species person color: #3498db;
        }
    }
} 