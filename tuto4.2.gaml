model tuto4_2

global {
    init {
        create grass number: 100;
        create herbivore number: 20;
    }
}

species grass {
    float energy <- 1.0;
    
    action grow() {
        energy <- energy + 0.1;
    }
    
    action die() {
        do die;
    }
    
    reflex basic_behavior {
        do grow;
    }
}

species herbivore {
    float energy <- 1.0;
    point target;
    
    action move() {
        target <- any_location_in(world);
        location <- location + (target - location) / 10;
        energy <- energy - 0.01;
    }
    
    action eat(grass food) {
        energy <- energy + food.energy;
        ask food {
            do die;
        }
    }
    
    reflex basic_behavior {
        do move;
        if (energy < 0.5) {
            grass food <- first(grass overlapping self);
            if (food != nil) {
                do eat food;
            }
        }
    }
}

experiment Simulation type: gui {
    output {
        display "Ecosystem" {
            species grass color: #2ecc71;
            species herbivore color: #e74c3c;
        }
    }
} 