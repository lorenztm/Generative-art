/**
 * Referencias
 * PixelFlow | 
 * 
 * A Processing/Java library for high performance GPU-Computing (GLSL).
 * MIT License: https://opensource.org/licenses/MIT
 * 
 */
import oscP5.*;
import netP5.*;


import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;

import controlP5.Accordion;
import controlP5.ControlP5;
import controlP5.Group;
import controlP5.RadioButton;
import controlP5.Toggle;
import processing.core.*;
import processing.opengl.PGraphics2D;
import processing.opengl.PJOGL;


 
  // controls:
  //
  // LMB: add Particles + Velocity
  // MMB: add Particles
  // RMB: add Particles
  
  
  
  private class MyFluidData implements DwFluid2D.FluidData{
    
    // update() is called during the fluid-simulation update step.
    @Override
    public void update(DwFluid2D fluid) {
    
      float px, py, vx, vy, radius, vscale, temperature;
 
      radius = 50;
      vscale = 2;
      px     = width/2;
      py     = 50;
      vx     = 1 * +vscale;
      vy     = 1 *  vscale;
      radius = 100;
      temperature = 4f;
      fluid.addDensity(px, py, radius, 0.2f, 0.3f, 0.5f, 1.0f);
      fluid.addTemperature(px, py, radius, temperature);
      particles.spawn(fluid, px, py, radius, 100);
 
      

    //  boolean haycara =  true;
      
    //  // add impulse: density + velocity, particles
      if(haycara == true){
        radius = 50;
        vscale = 10;
        px     = posx;
        py     = posy;
        vx     = 1 * +vscale;
        vy     = 1 * -vscale;
        fluid.addDensity (px, py, radius, 0.25f, 0.3f, 0.1f, 0.5f);
        fluid.addVelocity(px, py, radius, vx, vy);
        particles.spawn(fluid, px, py, radius*2, 300);
      }
      
    //  // add impulse: density + temperature, particles
      //if(haycara == true){
      //  radius = 15;
      //  vscale = 15;
      //  px     = posx;
      //  py     = height-posy;
      //  temperature = 2f;
      //  fluid.addDensity(px, py, radius, 0.25f, 0.0f, 0.1f, 1.0f);
      //  fluid.addTemperature(2*px, py, radius, temperature);
      //  particles.spawn(fluid, px, py, radius, 100);
      //}
      
      // particles
      if(haycara == true){
        px     = posx ;
        py     = height - 1 - posy; // invert
        radius = 50;
        particles.spawn(fluid, px, py, radius, 300);
      }
       
    }
  }
  
  
OscP5 oscP5;
boolean haycara = true;
float posx = 450;
float posy = 300;

float[] caraX = new float[66];
float[] caraY = new float[66];

  
  int viewport_w = 1280;
  int viewport_h = 720;
  int viewport_x = 230;
  int viewport_y = 0;
  
  int gui_w = 200;
  int gui_x = 20;
  int gui_y = 20;
  
  int fluidgrid_scale = 3;
  
  DwFluid2D fluid;

  // render targets
  PGraphics2D pg_fluid;
  //texture-buffer, for adding obstacles
  PGraphics2D pg_obstacles;
  
  // custom particle system
  MyParticleSystem particles;
  
  // some state variables for the GUI/display
  int     BACKGROUND_COLOR           = 0;
  boolean UPDATE_FLUID               = true;
  boolean DISPLAY_FLUID_TEXTURES     = false;
  boolean DISPLAY_FLUID_VECTORS      = false;
  int     DISPLAY_fluid_texture_mode = 0;
  boolean DISPLAY_PARTICLES          = true;
  
  
  public void settings() {
    size(viewport_w, viewport_h, P2D);
    smooth(4);
    PJOGL.profile = 3;
  }
  

  
  public void setup() {
 oscP5 = new OscP5(this,8338);
 for(int i=0;i < 66; i++){
   caraX[i] = 0;
   caraY[i] = 0;
 }
    
    surface.setLocation(viewport_x, viewport_y);
    
    // main library context
    DwPixelFlow context = new DwPixelFlow(this);
    context.print();
    context.printGL();

    // fluid simulation
    fluid = new DwFluid2D(context, viewport_w, viewport_h, fluidgrid_scale);
  
    // set some simulation parameters
    fluid.param.dissipation_density     = 0.999f;
    fluid.param.dissipation_velocity    = 0.99f;
    fluid.param.dissipation_temperature = 0.80f;
    fluid.param.vorticity               = 0.10f;
    
    // interface for adding data to the fluid simulation
    MyFluidData cb_fluid_data = new MyFluidData();
    fluid.addCallback_FluiData(cb_fluid_data);
   
    // pgraphics for fluid
    pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_fluid.smooth(4);
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    
        // pgraphics for obstacles
    pg_obstacles = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
    pg_obstacles.smooth(4);
    pg_obstacles.beginDraw();
    pg_obstacles.clear();
    float radius;
    radius = 200;
    pg_obstacles.stroke(64);
    pg_obstacles.strokeWeight(10);
    pg_obstacles.noFill();
    pg_obstacles.rect(1*width/2f,  1*height/4f, radius, radius, 20);
    // border-obstacle
    pg_obstacles.strokeWeight(20);
    pg_obstacles.stroke(64);
    pg_obstacles.noFill();
    pg_obstacles.rect(0, 0, pg_obstacles.width, pg_obstacles.height);
    pg_obstacles.endDraw();
    
    fluid.addObstacles(pg_obstacles);
    
    // custom particle object
    particles = new MyParticleSystem(context, 1000 * 1000);

    //createGUI();
    
    background(0);
    frameRate(60);
  }
  



  public void draw() {    
  
    // update simulation
    if(haycara && UPDATE_FLUID){
      fluid.addObstacles(pg_obstacles);
      fluid.update();
      particles.update(fluid);
    }
    if(haycara  && UPDATE_FLUID){
      
    }
    
    // clear render target
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    
    
    // render fluid stuff
    if(DISPLAY_FLUID_TEXTURES){
      // render: density (0), temperature (1), pressure (2), velocity (3)
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
    }
    
    if(DISPLAY_FLUID_VECTORS){
      // render: velocity vector field
      fluid.renderFluidVectors(pg_fluid, 10);
    }
    
    if( DISPLAY_PARTICLES){
      // render: particles; 0 ... points, 1 ...sprite texture, 2 ... dynamic points
      particles.render(pg_fluid, BACKGROUND_COLOR);
    }
    

    //// display
    image(pg_fluid    , 0, 0);
    image(pg_obstacles, 0, 0);
    
  

 // for(int k=0; k<66; k++){
   
 //  // display
 //   image(pg_fluid    ,caraX[k], caraY[k]);
 //   //image(pg_obstacles, caraX[33], caraY[33]);
    
 //}
    // display number of particles as text
    //String txt_num_particles = String.format("Particles  %,d", particles.ALIVE_PARTICLES);
    //fill(0, 0, 0, 220);
    //noStroke();
    //rect(10, height-10, 160, -30);
    //fill(255,128,0);
    //text(txt_num_particles, 20, height-20);
 
    //// info
    //String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frameRate);
    //surface.setTitle(txt_fps);
  }
  



  
  public void fluid_resizeUp(){
    fluid.resize(width, height, fluidgrid_scale = max(1, --fluidgrid_scale));
  }
  public void fluid_resizeDown(){
    fluid.resize(width, height, ++fluidgrid_scale);
  }

void oscEvent(OscMessage theOscMessage) {
  
  if(theOscMessage.checkAddrPattern("/found")==true){
    
   int valor = theOscMessage.get(0).intValue();
   println("FFOUND");
   println(valor);
   if(valor ==1){
    haycara = true; 
   }
   if(valor==0){
    haycara = false; 
    
   }
  }

  
  
   if(theOscMessage.checkAddrPattern("/pose/position")==true){
     
     posx = 900 - theOscMessage.get(0).floatValue();
     posy = theOscMessage.get(1).floatValue();
     
   }
   
   
}
void keyPressed() {
if(key == 'a'){
 save("polen.png");
}
  
}
