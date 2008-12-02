=begin
--
Miyako v1.5
Copyright (C) 2007-2008  Cyross Makoto

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
++
=end

module Miyako

  #==シーン実行クラス
  #用意したシーンインスタンスを実行
  class Story
    @@draw_types = [:auto_update, :auto_render, :manual_render]

    attr_reader :draw_mode
    
    #===あとで書く
    #返却値:: あとで書く
    def prev_label
      return @prev_label
    end

    #===あとで書く
    #返却値:: あとで書く
    def next_label
      return @next_label
    end

    #===あとで書く
    #返却値:: あとで書く
    def upper_label
      return @stack.empty? ? nil : @stack.last[0]
    end

    #===インスタンスの作成
    #_draw_mode_:: 画面描画モード。モードは次の3種類。
    #
    #:auto_update : 従来通り、Screen.updateを使用
    #:auto_render : シーンクラスのrenderメソッドを呼び出す。
    #自動的にScreen.clearとScreen.renderを呼び出す
    #:manual_render : シーンクラスのrenderメソッドを呼び出す。
    #返却値:: あとで書く
    def initialize(draw_mode = :auto_update)
      @draw_mode = draw_mode

      @prev_label = nil
      @next_label = nil

	  @stack = Array.new

      @scene_cache = Hash.new
      @scene_cache_list = Array.new
      @scene_cache_max = 20
    end
    
    def get_scene(n, s) #:nodoc:
      class_symbol = n.to_s
      if @scene_cache_list.length == @scene_cache_max
        del_symbol = @scene_cache_list.shift
        @scene_cache[del_symbol].dispose
        @scene_cache.delete(del_symbol)
      end
      @scene_cache_list.delete(class_symbol)
      @scene_cache_list.push(class_symbol)
      @scene_cache[class_symbol] ||= n.new(self)
      return @scene_cache[class_symbol]
    end

    #===あとで書く
    #_n_:: あとで書く
    #返却値:: あとで書く
    def run(n)
      return nil if n == nil
      u = nil
      on = nil
      @stack = Array.new # reset
      while n != nil
        @prev_label = on
        on = n

        raise MiyakoError, "Illegal Script-label name! : #{n}" unless Scene.has_scene?(n.to_s)
        u = get_scene(n, @stack.size) if u == nil
        u.init_inner(@prev_label, self.upper_label)
        u.setup
        
        methods = {}
        @@draw_types.each{|dt| methods[dt] = self.method(dt) }
        
        f = true
        loop do
          Input.update
          f = u.view_in
          break unless f
          methods[@draw_mode].call(u)
        end
        u.view_in_to_update
        loop do
          Input.update
          n = u.update
          break unless n && on.eql?(n)
          methods[@draw_mode].call(u)
        end
        u.next = n
        @next_label = n
        u.update_to_view_out
        f = true
        loop do
          Input.update
          f = u.view_out
          break unless f
          methods[@draw_mode].call(u)
        end
        u.final
        if n == nil
          if u.scene_type == :sub_routine && @stack.empty? == false
            n, u = @stack.pop
            next
          end
          break
        elsif n.new(self, false).scene_type == :sub_routine
          @stack.push([on, u])
          u = nil
        else
          u = nil
        end
      end
      @scene_cache_list.each{|sy| @scene_cache[sy].dispose }
      @scene_cache.clear
      @scene_cache_list.clear
    end

    def auto_update(scene)
      Screen.update
    end
    
    def auto_render(scene)
      Screen.clear
      scene.render
      Screen.render
    end
    
    def manual_render(scene)
      scene.render
    end
    
    #===あとで書く
    def dispose
      @scene_cache.keys.each{|k| @scene_cache[del_symbol].dispose }
    end

    #==シーンモジュール
    #本モジュールをmixinすることにより、シーンを示すインスタンスを作??することができる
    module Scene
	  @@scenes = {}

      def Scene.included(c) #:nodoc:
        @@scenes[c.to_s] = c
      end

      def Scene.scenes #:nodoc:
        return @@scenes
      end

      def Scene.has_scene?(s) #:nodoc:
        return @@scenes.has_key?(s)
      end

      #===あとで書く
      #返却値:: あとで書く
      def scene_type
        return :scene
      end
      
      def initialize(story, check_only=false) #:nodoc:
        return if check_only
        @story = story
        @now = self.class
        @prev = nil
        @upper = nil
        @next = nil
        self.init
      end

      def init_inner(p, u) #:nodoc:
        @prev = p
        @upper = u
      end

      #===あとで書く
      #返却値:: あとで書く
      def init
      end

      #===あとで書く
      #返却値:: あとで書く
      def setup
      end

      #===あとで書く
      #返却値:: あとで書く
      def view_in
        return false
      end

      #===あとで書く
      #返却値:: あとで書く
      def render_view_in
      end
      
      #===あとで書く
      #返却値:: あとで書く
      def view_in_to_update
      end

      #===あとで書く
      #返却値:: あとで書く
      def update
        return @now
      end

      #===あとで書く
      #返却値:: あとで書く
      def render_update
      end
      
      #===あとで書く
      #返却値:: あとで書く
      def update_to_view_out
      end

      #===あとで書く
      #返却値:: あとで書く
      def view_out
        return false
      end

      #===あとで書く
      #返却値:: あとで書く
      def render_view_out
      end
      
      #===あとで書く
      #返却値:: あとで書く
      def final
      end

      #===あとで書く
      #返却値:: あとで書く
      def dispose
      end
      
      def next=(label) #:nodoc:
        @next = label
      end

      #===あとで書く
      #返却値:: あとで書く
      def notice
        return ""
      end

      #===あとで書く
      #返却値:: あとで書く
      def Scene.listup
        list = Array.new
        sns = @@scenes
        sns.keys.sort.each{|k| list.push("#{k}, #{sns[k]}, \"#{sns[k].notice}\"\n") }
        return list
      end

      #===あとで書く
      #_csvname_:: あとで書く
      #返却値:: あとで書く
      def Scene.listup2csv(csvfname)
        csvfname += ".csv" if csvfname !~ /\.csv$/
        list = self.listup
        File.open(csvfname, "w"){|f| list.each{|l| f.print l } }
      end

    end
  end
end