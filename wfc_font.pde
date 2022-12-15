final int TILES = 12;

final int WIDTH = 160;
final int HEIGHT = 160;
final int CELL_SIZE = 5;

final int PEN_RADIUS = 9;


/*
// store texture and possible connections
class Texture {
  // up, right, down, left
  public boolean connections[];
  public PImage texture_file;

  public Texture(boolean up, boolean right, boolean down, boolean left, PImage texture_file) {
    this.connections = new boolean[] {up, right, down, left};
    this.texture_file = texture_file;
  }
}

// class to store the position and possible states of a tile
class Tile {
  public int x;
  public int y;
  public Texture state;
  public ArrayList<Texture> states;
  public boolean collapsed;
  public float chance_blank;
  
  public Tile(int x, int y) {
    this.x = x;
    this.y = y;
    this.state = null;
    this.states = new ArrayList<Texture>();
    this.collapsed = false;
    this.chance_blank = 1.0f;
  }
  
  public boolean can_collapse() {
    boolean c_old[] = this.states.get(0).connections;
    
    for(int i = 0; i < this.states.size(); ++i) {
      boolean c_current[] = this.states.get(i).connections;
      for(int j = 0; j < 4; ++j) if(c_old[j] != c_current[j]) return false;
    }
    
    return true;
  }
}

// contains a list of all tiles and the wfc algorithm
class Tile_List {
  private ArrayList<Tile> tile_list;
  private ArrayList<Texture> textures;
  private int cells_x;
  private int cells_y;


  public Tile_List(int cells_x, int cells_y, ArrayList<Texture> textures) {
    this.cells_x = cells_x;
    this.cells_y = cells_y;
    this.tile_list = new ArrayList<Tile>();
    this.textures = new ArrayList<Texture>();
    
    for(int y = 0; y < cells_y; ++y) {
      for(int x = 0; x < cells_x; ++x) {
        Tile t_add = new Tile(x, y);
        
        for(Texture t : textures) t_add.states.add(t);
        this.tile_list.add(t_add);
      }
    }
  }



  // called once, solves the field
  public void solve() {
    ArrayList<Tile> uncollapsed = new ArrayList<Tile>();
    for(Tile t : this.tile_list) if(!t.collapsed) uncollapsed.add(t);
    
    while(uncollapsed.size() > 0) {
      Tile t = uncollapsed.get(int(random(uncollapsed.size() - 1)));
      this.collapse_tile(t);
      uncollapsed.remove(t);
      this.update_tiles();
    }
    
    paint = false;
    this.clean();
  }


  // find all tiles that end in nothing and plase end-caps
  // very hacky
  private void clean() {
    for(Tile t : this.tile_list) {
      if(t.state != TEXTURES.get(0)) {
        
        for(int dir = 0; dir < 4; ++dir) {
          Tile neighbor = get_neighbor(t, dir);
          
          if(neighbor != null) {
            
            // check if tile connects to dir
            if(t.state.connections[dir]) {
              
              if(neighbor.state == TEXTURES.get(0)) {
                
                int neighbor_dir_check = 0;
                if(dir == 0) neighbor.state = TEXTURES_END.get(2);
                if(dir == 1) neighbor.state = TEXTURES_END.get(3);
                if(dir == 2) neighbor.state = TEXTURES_END.get(0);
                if(dir == 3) neighbor.state = TEXTURES_END.get(1);
              }
            }
          }
        }
      } 
    }
  }


  // get tile at position
  private Tile get_tile(int x, int y) {
    if(x < 0 || x >= this.cells_x) return null;
    if(y < 0 || y >= this.cells_y) return null;
    //println(x + " " + y + " " + (this.cells_x * y + x));
    return this.tile_list.get(this.cells_x * y + x);
  }
  
  

  // get the neighbor Tile in the specified direction
  private Tile get_neighbor(Tile source, int direction) {
    if(direction == 0) return this.get_tile(source.x, source.y - 1);
    if(direction == 1) return this.get_tile(source.x + 1, source.y);
    if(direction == 2) return this.get_tile(source.x, source.y + 1);
    if(direction == 3) return this.get_tile(source.x - 1, source.y);
    return null;
  }



  // update the given tile, returns True if it's possible states have changed
  private boolean update_tile(Tile t) {
    boolean changed = false;
    
    //println("UPDATE TILE [" + t.x + " " + t.y + "]");
    
    for(int dir = 0; dir < 4; ++dir) {
      Tile neighbor = get_neighbor(t, dir);
      
      if(neighbor != null) if(!neighbor.collapsed) {
        
        boolean connect_neighbor = false;
        boolean connect_neighbor_force = false;
        
        if(!t.collapsed) {
          for(Texture tt : t.states) if(tt.connections[dir]) connect_neighbor = true;
        }
        else if(t.state.connections[dir]) {
          connect_neighbor = true;
          connect_neighbor_force = true;
        }
        
        int neighbor_dir_check = 0;
        if(dir == 0) neighbor_dir_check = 2;
        if(dir == 1) neighbor_dir_check = 3;
        if(dir == 2) neighbor_dir_check = 0;
        if(dir == 3) neighbor_dir_check = 1;
        
        // if the tile does not connect to the neighbor, make the neighbor unable to do so
        if(!connect_neighbor) {
          
          //println("Tile [" + t.x + " " + t.y + "] does not connect to " + dir);
          
          for(int i = neighbor.states.size() - 1; i >= 0; i--) {
            Texture n_tt = neighbor.states.get(i);
            if(n_tt.connections[neighbor_dir_check]) {
              neighbor.states.remove(n_tt);
              changed = true;
            }
          }
        }
        
        else if(connect_neighbor_force) {
          
          //println("Tile [" + t.x + " " + t.y + "] does connect to " + dir);
          
          for(int i = neighbor.states.size() - 1; i >= 0; i--) {
            Texture n_tt = neighbor.states.get(i);
            if(!n_tt.connections[neighbor_dir_check]) {
              neighbor.states.remove(n_tt);
              changed = true;
            }
          }
        }
        
        if(neighbor.can_collapse()) this.collapse_tile(neighbor);
        
      }
      
    }
    return changed;
  }
  
  

  // updates all tiles
  // -> check if something has changed
  // -> if so, go on until nothing changes
  public void update_tiles() {
    boolean changed = true;
    
    while(changed) {
      changed = false;
      for(Tile t : this.tile_list) {
        if(update_tile(t)) {
          changed = true;
        }
      }
    }
  }

  // sets a tile to one of it's possible states
  public void collapse_tile(Tile t) {
    if(random(1) <= t.chance_blank) {
      t.state = t.states.get(0);
      t.collapsed = true;
      return;
    }
    
    t.state = t.states.get(int(random(t.states.size())));
    t.collapsed = true;
    println("Tile [" + t.x + " " + t.y + "] -> ");
    for(boolean b : t.state.connections) print(b + " ");
    println();
  }
}*/


Tile_List grid;
ArrayList<Texture> TEXTURES;
ArrayList<Texture> TEXTURES_END;
boolean paint = false;


void settings() {
  size(HEIGHT * CELL_SIZE, WIDTH * CELL_SIZE);
}


void setup() {
  frameRate(10);
  
  TEXTURES = new ArrayList<Texture>();
  TEXTURES_END = new ArrayList<Texture>();
  
  TEXTURES.add(new Texture(false, false, false, false, loadImage("files_7/0000.png")));
  
  TEXTURES.add(new Texture(true, true, false, false, loadImage("files_7/1100.png")));
  TEXTURES.add(new Texture(false, true, true, false, loadImage("files_7/0110.png")));
  TEXTURES.add(new Texture(false, false, true, true, loadImage("files_7/0011.png")));
  TEXTURES.add(new Texture(true, false, false, true, loadImage("files_7/1001.png")));
  
  TEXTURES.add(new Texture(true, true, true, false, loadImage("files_7/1110.png")));
  TEXTURES.add(new Texture(false, true, true, true, loadImage("files_7/0111.png")));
  TEXTURES.add(new Texture(true, false, true, true, loadImage("files_7/1011.png")));
  TEXTURES.add(new Texture(true, true, false, true, loadImage("files_7/1101.png")));
  
  TEXTURES.add(new Texture(true, false, true, false, loadImage("files_7/1010.png")));
  TEXTURES.add(new Texture(false, true, false, true, loadImage("files_7/0101.png")));
  
  TEXTURES.add(new Texture(true, false, true, false, loadImage("files_7/1010.png")));
  TEXTURES.add(new Texture(false, true, false, true, loadImage("files_7/0101.png")));
  
  TEXTURES.add(new Texture(true, true, true, true, loadImage("files_7/1111.png")));
  
  TEXTURES_END.add(new Texture(true, false, false, false, loadImage("files_7/1000.png")));
  TEXTURES_END.add(new Texture(false, true, false, false, loadImage("files_7/0100.png")));
  TEXTURES_END.add(new Texture(false, false, true, false, loadImage("files_7/0010.png")));
  TEXTURES_END.add(new Texture(false, false, false, true, loadImage("files_7/0001.png")));
  
  grid = new Tile_List(WIDTH, HEIGHT, TEXTURES);
  for(int x = 0; x < WIDTH; ++x) {
    for(int y = 0; y < HEIGHT; ++y) {
      rect(x * CELL_SIZE, y * CELL_SIZE, x * CELL_SIZE + CELL_SIZE, y * CELL_SIZE + CELL_SIZE);
    }
  }
}


void mouseClicked() {
  int mouse_x_mapped = int(map(mouseX, 0, WIDTH * CELL_SIZE, 0, WIDTH));
  int mouse_y_mapped = int(map(mouseY, 0, WIDTH * CELL_SIZE, 0, WIDTH));
  
  Tile t = grid.get_tile(mouse_x_mapped, mouse_y_mapped);
  grid.collapse_tile(t);
  
  grid.update_tiles();
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
        //TODO: NO TRY CATCH
        try {
          grid.get_tile(mouse_x_mapped + x, mouse_y_mapped + y).chance_blank = 0;
        } catch(Exception e) {}
      }
    }
  }
}


void keyPressed() {
  if (key == 's') grid.solve();
  if (key == 'p') paint =! paint;
  if (key == 'f') save(hour() + "-" + minute() + "-" + second() + ".png");
}


void draw() {
  if(!paint) {
    int mouse_x_mapped = int(map(mouseX, 0, WIDTH * CELL_SIZE, 0, WIDTH));
    int mouse_y_mapped = int(map(mouseY, 0, WIDTH * CELL_SIZE, 0, WIDTH));
    
    for(int x = 0; x < WIDTH; ++x) {
      for(int y = 0; y < HEIGHT; ++y) {
        fill(100);
        if(mouse_x_mapped == x && mouse_y_mapped == y) fill(255);
        rect(x * CELL_SIZE, y * CELL_SIZE, x * CELL_SIZE + CELL_SIZE, y * CELL_SIZE + CELL_SIZE);
        
        Tile t = grid.get_tile(x, y);
        if(t.collapsed) image(t.state.texture_file, x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE);
      }
    }
  } else {
    // draw grid
    stroke(255, 0, 0);
    strokeWeight(5);
    fill(0, 0, 0, 0);
    
    int scale = width / 5;
    
    for(int x = 0; x < 5; ++x) {
      for(int y = 0; y < 5; ++y) {
        rect(x*scale, y*scale, scale + x*scale, scale + y*scale);
      }
    }
    
    strokeWeight(1);
    stroke(0);
  }
}
