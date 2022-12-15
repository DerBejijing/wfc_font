public class WFC_Algorithm {
    
    public WFC_Algorithm(int cells_x, int cells_y) {

    }

    // add a texture, specifying connections and a weight to be used
    public void add_texture(String file, boolean up, boolean right, boolean down, boolean left, float weight) {}

    // add a texture, specifying where it connects to
    // used to prohibit some paths from going to nowhere
    public void add_texture_end(String file, int direction) {}

    // set the weight for a cell to be populated
    public void set_cell_weight(int x, int y, float weight) {}


    // store texture and possible connections
    class Texture {
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
        // TODO: find tile with lowest entropy
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
        private void clean() {
            for(Tile t : this.tile_list) {
                if(t.state != TEXTURES.get(0)) {
                    
                    for(int dir = 0; dir < 4; ++dir) {
                        Tile neighbor = get_neighbor(t, dir);
                        
                        if(neighbor != null) {
                            
                            // check if tile connects to dir
                            if(t.state.connections[dir]) {
                                if(neighbor.state == TEXTURES.get(0)) {
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
                // this can be done better
                if(!connect_neighbor) {    
                    for(int i = neighbor.states.size() - 1; i >= 0; i--) {
                        Texture n_tt = neighbor.states.get(i);
                        if(n_tt.connections[neighbor_dir_check]) {
                            neighbor.states.remove(n_tt);
                            changed = true;
                        }
                    }
                }
                else if(connect_neighbor_force) { 
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
        }
    }
}