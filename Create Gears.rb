require 'sketchup.rb'

UI.menu("Plugins").add_item("Gears") {
  UI.messagebox("Gear Ratio Time!")
	gears
	Sketchup.send_action("viewTop:")
}

def gears
  model = Sketchup.active_model
  entities = model.entities
  
  prompts = ["Name", "Teeth", "Circular Thickness", "Addendum", "Dedendum", "Top Island", "Fillet Radius", "Face Width"]
  defaults = ["", "60", "0.5", "0.5", "0.5", "0.25", "0.125", "0.75"]
  inputs = UI.inputbox(prompts, defaults, "Give me some dimensions!")
  
  name = inputs[0]
  teeth = inputs[1].to_f
  circular_thickness = inputs[2].to_f
  addendum = inputs[3].to_f
  dedendum = inputs[4].to_f
  island = inputs[5].to_f
  radius = inputs[6].to_f
  thickness = inputs[7].to_f
 
  new_comp_def = Sketchup.active_model.definitions.add(name)
  
  #dimensions to points around the gear
  middle_circumference = (circular_thickness * 2 * teeth)
  outside_diameter =  middle_circumference/(Math::PI) + addendum*2
  outside_radius = outside_diameter/2
  middle_radius = outside_radius-addendum
  base_radius = outside_radius-addendum-dedendum
  top_fillet_radius = base_radius+radius
  
  #Formulas for the radians at points along the top tooth, divided by two because it splits the y axis
  one_radians = (island/outside_radius)/2
  three_radians = (circular_thickness/middle_radius)/2
  five_radians = (circular_thickness/top_fillet_radius)/2
  seven_radians = ((circular_thickness+(radius*2))/top_fillet_radius)/2
  nine_radians = ((circular_thickness+(radius*2))/base_radius)/2
  eleven_radians = ((circular_thickness+(island*2))/base_radius)/2
  
  #x,y coordinates for the points on the first tooth. x=radius*cos(radians) where radians=opposite/radius,  
  #y is the same except sin is exchanged for cos. The first tooth is at 90 degrees which is why pi/2 is inside the cos/sin
  x = outside_radius*Math.cos(Math::PI/2-one_radians)
  y = outside_radius*Math.sin(Math::PI/2-one_radians)
  x1 = middle_radius*Math.cos(Math::PI/2-three_radians)
  y1 = middle_radius*Math.sin(Math::PI/2-three_radians)
  x2 = top_fillet_radius*Math.cos(Math::PI/2-five_radians)
  y2 = top_fillet_radius*Math.sin(Math::PI/2-five_radians)
  x3 = top_fillet_radius*Math.cos(Math::PI/2-seven_radians)
  y3 = top_fillet_radius*Math.sin(Math::PI/2-seven_radians)
  x4 = base_radius*Math.cos(Math::PI/2-nine_radians)
  y4 = base_radius*Math.sin(Math::PI/2-nine_radians)
  x5 = base_radius*Math.cos(Math::PI/2-eleven_radians)
  y5 = base_radius*Math.sin(Math::PI/2-eleven_radians)
  
  #odd points are on right side of tooth, 1 corner of island, 3 at addendum base, 5 at top of fillet radius, 7 at center of fillet radius arc
  #9 at base of fillet radius, and 11 half way between the next tooth at the base
  point1 = [ x, y, 0]
  point2 = [ -x, y, 0]
  point3 = [ x1, y1, 0]
  point4 = [ -x1, y1, 0]
  point5 = [ x2, y2, 0]
  point6 = [ -x2, y2, 0]
  point7 = [ x3, y3, 0]
  point8 = [ -x3, y3, 0]
  point9 = [ x4, y4, 0]
  point10 = [ -x4, y4, 0]
  point11 = [ x5, y5, 0]
  point12 = [ -x5, y5, 0]
  
  lines = Array.new
  lines1 = new_comp_def.entities.add_line(point1, point2)
  lines2 = new_comp_def.entities.add_line(point1, point3)
  lines3 = new_comp_def.entities.add_line(point2, point4)
  lines4 = new_comp_def.entities.add_line(point3, point5)
  lines5 = new_comp_def.entities.add_line(point4, point6)
  lines6 = new_comp_def.entities.add_line(point9, point11)
  lines6 = new_comp_def.entities.add_line(point10, point12)
  
  normal = Geom::Vector3d.new 0,0,1
  xaxis = Geom::Vector3d.new 1,0,0
  start_a = (180-(360/teeth/3)).degrees
  end_a = 270.degrees
  fillet = new_comp_def.entities.add_arc( point7, xaxis, normal, radius, start_a, end_a)
  
  normal = Geom::Vector3d.new 0,0,1
  xaxis = Geom::Vector3d.new 1,0,0
  start_a = 270.degrees
  end_a = (360+(360/teeth/3)).degrees
  fillet1 = new_comp_def.entities.add_arc( point8, xaxis, normal, radius, start_a, end_a)
 
  for tooth in 1..teeth
    trans = Geom::Transformation.rotation([0,0,0],[0,0,1],(360/teeth*tooth).degrees)
    Sketchup.active_model.active_entities.add_instance( new_comp_def, trans )
  end
 
end
