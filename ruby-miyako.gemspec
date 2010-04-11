Gem::Specification.new do |s|
  s.name = "ruby-miyako"
  s.version = "2.1.10"
#  s.date = "2009-4-26"
  s.summary = "Game programming library for Ruby"
  s.email = "cyross@po.twin.ne.jp"
  s.homepage = "http://www.twin.ne.jp/~cyross/Miyako/"
  s.description = "Miyako is Ruby library for programming game or rich client"
  s.required_ruby_version = Gem::Requirement.new('>= 1.9.1')
  s.has_rdoc = true
  s.rdoc_options = "-c utf-8"
  s.authors = ["Cyross Makoto"]
  s.test_files = []
  s.extensions = ["extconf.rb"]
  s.files = [
"./defines.h",
"./extconf.rb",
"./extern.h",
"./img/cursor.png",
"./img/cursors.png",
"./img/dice.png",
"./img/wait_cursor.png",
"./img/window.png",
"./img/win_base.png",
"./install_miyako.rb",
"./lib/Miyako/API/audio.rb",
"./lib/Miyako/API/basic_data.rb",
"./lib/Miyako/API/bitmap.rb",
"./lib/Miyako/API/choices.rb",
"./lib/Miyako/API/collision.rb",
"./lib/Miyako/API/color.rb",
"./lib/Miyako/API/diagram.rb",
"./lib/Miyako/API/drawing.rb",
"./lib/Miyako/API/exceptions.rb",
"./lib/Miyako/API/fixedmap.rb",
"./lib/Miyako/API/font.rb",
"./lib/Miyako/API/i_yuki.rb",
"./lib/Miyako/API/input.rb",
"./lib/Miyako/API/layout.rb",
"./lib/Miyako/API/map_struct.rb",
"./lib/Miyako/API/map.rb",
"./lib/Miyako/API/map_event.rb",
"./lib/Miyako/API/modules.rb",
"./lib/Miyako/API/movie.rb",
"./lib/Miyako/API/parts.rb",
"./lib/Miyako/API/plane.rb",
"./lib/Miyako/API/screen.rb",
"./lib/Miyako/API/shape.rb",
"./lib/Miyako/API/sprite.rb",
"./lib/Miyako/API/spriteunit.rb",
"./lib/Miyako/API/sprite_animation.rb",
"./lib/Miyako/API/sprite_list.rb",
"./lib/Miyako/API/story.rb",
"./lib/Miyako/API/simple_story.rb",
"./lib/Miyako/API/struct_point.rb",
"./lib/Miyako/API/struct_size.rb",
"./lib/Miyako/API/struct_rect.rb",
"./lib/Miyako/API/struct_square.rb",
"./lib/Miyako/API/struct_segment.rb",
"./lib/Miyako/API/textbox.rb",
"./lib/Miyako/API/utility.rb",
"./lib/Miyako/API/viewport.rb",
"./lib/Miyako/API/wait_counter.rb",
"./lib/Miyako/API/yuki.rb",
"./lib/Miyako/EXT/raster_scroll.rb",
"./lib/Miyako/EXT/slides.rb",
"./lib/Miyako/miyako.rb",
"./lib/Miyako/miyako_require_only.rb",
"./lib/miyako.rb",
"./lib/miyako_require_only.rb",
"./logo/EGSR_logo.png",
"./logo/EGSR_logo_bg.png",
"./logo/EGSR_logo_fg.png",
"./logo/EGSR_title_banner.png",
"./logo/EGSR_title_logo.png",
"./logo/miyako.png",
"./logo/miyako_banner.png",
"./logo/space.png",
"./miyako_basicdata.c",
"./miyako_bitmap.c",
"./miyako_collision.c",
"./miyako_drawing.c",
"./miyako_font.c",
"./miyako_hsv.c",
"./miyako_input_audio.c",
"./miyako_layout.c",
"./miyako_no_katana.c",
"./miyako_sprite2.c",
"./miyako_transform.c",
"./miyako_utility.c",
"./miyako_yuki.c",
"./miyako_diagram.c",
"./Rakefile",
"./README",
"./sample/Animation1/m1ku.rb",
"./sample/Animation1/m1ku_arm_0.png",
"./sample/Animation1/m1ku_arm_1.png",
"./sample/Animation1/m1ku_arm_2.png",
"./sample/Animation1/m1ku_arm_3.png",
"./sample/Animation1/m1ku_back.jpg",
"./sample/Animation1/m1ku_body.png",
"./sample/Animation1/m1ku_eye_0.png",
"./sample/Animation1/m1ku_eye_1.png",
"./sample/Animation1/m1ku_eye_2.png",
"./sample/Animation1/m1ku_eye_3.png",
"./sample/Animation1/m1ku_hair_front.png",
"./sample/Animation1/m1ku_hair_rear.png",
"./sample/Animation1/readme.txt",
"./sample/Animation2/lex.rb",
"./sample/Animation2/lex_back.png",
"./sample/Animation2/lex_body.png",
"./sample/Animation2/lex_roadroller.png",
"./sample/Animation2/lex_wheel_0.png",
"./sample/Animation2/lex_wheel_1.png",
"./sample/Animation2/lex_wheel_2.png",
"./sample/Animation2/readme.txt",
"./sample/Animation2/song_title.png",
"./sample/ball_action_sample.rb",
"./sample/blit_rop.rb",
"./sample/circle_collision_test.rb",
"./sample/collision_test.rb",
"./sample/collision_test2.rb",
"./sample/Diagram_sample/back.png",
"./sample/Diagram_sample/chr01.png",
"./sample/Diagram_sample/chr02.png",
"./sample/Diagram_sample/cursor.png",
"./sample/Diagram_sample/diagram_sample_yuki2.rb",
"./sample/Diagram_sample/readme.txt",
"./sample/Diagram_sample/wait_cursor.png",
"./sample/fixed_map_test/cursor.png",
"./sample/fixed_map_test/fixed_map_sample.rb",
"./sample/fixed_map_test/map.csv",
"./sample/fixed_map_test/mapchip.csv",
"./sample/fixed_map_test/map_01.png",
"./sample/fixed_map_test/monster.png",
"./sample/fixed_map_test/readme.txt",
"./sample/map_test/chara.rb",
"./sample/map_test/chr1.png",
"./sample/map_test/cursor.png",
"./sample/map_test/main_parts.rb",
"./sample/map_test/main_scene.rb",
"./sample/map_test/map.png",
"./sample/map_test/map2.png",
"./sample/map_test/mapchip.csv",
"./sample/map_test/map_layer.csv",
"./sample/map_test/map_manager.rb",
"./sample/map_test/map_test.rb",
"./sample/map_test/oasis.rb",
"./sample/map_test/readme.txt",
"./sample/map_test/route.rb",
"./sample/map_test/sea.png",
"./sample/map_test/town.rb",
"./sample/map_test/wait_cursor.png",
"./sample/map_test/window.png",
"./sample/polygon_test.rb",
"./sample/rasterscroll.rb",
"./sample/Room3/blue.rb",
"./sample/Room3/ending.rb",
"./sample/Room3/green.rb",
"./sample/Room3/image/akamatsu.png",
"./sample/Room3/image/aoyama.png",
"./sample/Room3/image/congra.png",
"./sample/Room3/image/congratulation.png",
"./sample/Room3/image/congratulation_bg.png",
"./sample/Room3/image/cursor.png",
"./sample/Room3/image/midori.png",
"./sample/Room3/image/mittsu_no_oheya.png",
"./sample/Room3/image/mittsu_no_oheya_logo.png",
"./sample/Room3/image/room_blue.png",
"./sample/Room3/image/room_green.png",
"./sample/Room3/image/room_red.png",
"./sample/Room3/image/start.png",
"./sample/Room3/image/three_doors.png",
"./sample/Room3/image/wait_cursor.png",
"./sample/Room3/main.rb",
"./sample/Room3/main_component.rb",
"./sample/Room3/readme.txt",
"./sample/Room3/red.rb",
"./sample/Room3/room3.rb",
"./sample/Room3/title.rb",
"./sample/takahashi.rb",
"./sample/text.png",
"./sample/textbox_sample.rb",
"./sample/transform.rb",
"./sample/utility_test.rb",
"./sample/utility_test2.rb",
"./sample/utility_test3.rb",
"./sample/utility_test4.rb",
"./uninstall_miyako.rb",
"./win/miyako_no_katana.so"
  ]
  s.require_paths = ["lib/Miyako", "lib"]
end