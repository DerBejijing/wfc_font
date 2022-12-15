final int TILES = 12;

final int WIDTH = 160;
final int HEIGHT = 160;
final int CELL_SIZE = 5;

final int PEN_RADIUS = 2;

boolean paint = false;

WFC_Algorithm algorithm;


void settings() {
    size(HEIGHT * CELL_SIZE, WIDTH * CELL_SIZE);
}

void setup() {
    frameRate(10);

    algorithm = new WFC_Algorithm(WIDTH, HEIGHT, CELL_SIZE, 1.0f);
    algorithm.add_texture("files_0/0000.png");
    algorithm.add_texture("files_0/1111.png");

    algorithm.add_texture("files_0/1010.png");
    algorithm.add_texture("files_0/0101.png");

    algorithm.add_texture("files_0/1110.png");
    algorithm.add_texture("files_0/0111.png");
    algorithm.add_texture("files_0/1011.png");
    algorithm.add_texture("files_0/1101.png");

    algorithm.add_texture("files_0/1100.png");
    algorithm.add_texture("files_0/0110.png");
    algorithm.add_texture("files_0/0011.png");
    algorithm.add_texture("files_0/1001.png");

    algorithm.add_texture_end("files_0/1000.png");
    algorithm.add_texture_end("files_0/0100.png");
    algorithm.add_texture_end("files_0/0010.png");
    algorithm.add_texture_end("files_0/0001.png");
    algorithm.prepare();


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
                
                algorithm.set_cell_weight(mouse_x_mapped + x, mouse_y_mapped + y, 0.0f);
                
            }
        }
    }
}


void keyPressed() {
    if (key == 's') algorithm.solve();
    if (key == 'p') paint =! paint;
    if (key == 'f') algorithm.save_image();
    if (key == 'i') algorithm.load_image();
    if (key == 'c') algorithm.clean(); 

    algorithm.render();
}


void draw() {
}