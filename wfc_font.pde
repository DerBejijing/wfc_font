final int TILES = 12;

final int WIDTH = 160;
final int HEIGHT = 160;
final int CELL_SIZE = 5;

final int PEN_RADIUS = 9;

boolean paint = false;

WFC_Algorithm algorithm;


void settings() {
    size(HEIGHT * CELL_SIZE, WIDTH * CELL_SIZE);
}

void setup() {
    frameRate(10);

    algorithm = new WFC_Algorithm(WIDTH, HEIGHT, CELL_SIZE, 1.0f);
    algorithm.add_texture("files_7/0000.png");
    algorithm.add_texture("files_7/1111.png");

    algorithm.add_texture("files_7/1010.png");
    algorithm.add_texture("files_7/0101.png");

    algorithm.add_texture("files_7/1000.png");
    algorithm.add_texture("files_7/0100.png");
    algorithm.add_texture("files_7/0010.png");
    algorithm.add_texture("files_7/0001.png");

    algorithm.add_texture("files_7/1110.png");
    algorithm.add_texture("files_7/0111.png");
    algorithm.add_texture("files_7/1011.png");
    algorithm.add_texture("files_7/1101.png");


    for(int x = 0; x < WIDTH; ++x) {
        for(int y = 0; y < HEIGHT; ++y) {
            rect(x * CELL_SIZE, y * CELL_SIZE, x * CELL_SIZE + CELL_SIZE, y * CELL_SIZE + CELL_SIZE);
        }
    }
}

void mouseDragged() {
    int mouse_x_mapped = int(map(mouseX, 0, WIDTH * CELL_SIZE, 0, WIDTH));
    int mouse_y_mapped = int(map(mouseY, 0, WIDTH * CELL_SIZE, 0, WIDTH));
    
    if(paint) {
        fill(255, 0, 0, 10);
        stroke(255, 0, 0);
        ellipse(mouseX, mouseY, 50, 50);
        
        for(int x = -1 * PEN_RADIUS; x < PEN_RADIUS; ++x) {
            for(int y = -1 * PEN_RADIUS; y < PEN_RADIUS; ++y) {
                
                // SET WEIGHT
                
            }
        }
    }
}


void keyPressed() {
    if (key == 's') algorithm.solve();
    if (key == 'p') paint =! paint;
    if (key == 'f') algorithm.save_image();
}


void draw() {
}