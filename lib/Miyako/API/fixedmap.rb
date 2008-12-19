# -*- encoding: utf-8 -*-
=begin
--
Miyako v2.0
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

require 'csv'
require 'forwardable'

module Miyako
  #==スクロールしないマップクラス
  class FixedMap
    include Layout
    
    @@idx_ix = [-1, 2, 4]
    @@idx_iy = [-1, 0, 6]

    attr_reader :name, :map_layers, :pos, :w, :h

    #==あとで書く
    class FixedMapLayer #:nodoc: all
      extend Forwardable

      @@use_chip_list = Hash.new(nil)
      
      attr_accessor :mapchip_units
      attr_reader :pos

      def round(v, max) #:nodoc:
        v = max + (v % max) if v < 0
        v %= max if v >= max
        return v
      end

      def reSize #:nodoc:
        @cw = @real_size.w % @ow == 0 ? @real_size.w / @ow : (@real_size.w + @ow - 1)/ @ow + 1
        @ch = @real_size.h % @oh == 0 ? @real_size.h / @oh : (@real_size.h + @oh - 1)/ @oh + 1
      end

      def initialize(mapchip, mapdat, layer_size, pos) #:nodoc:
        @mapchip = mapchip
        @pos = pos.dup
        @size = layer_size.dup
        @ow = @mapchip.chip_size.w
        @oh = @mapchip.chip_size.h
        @real_size = Size.new(@size.w * @ow, @size.h * @oh)
        @mapdat = mapdat
        @baseimg = nil
        @baseimg = @mapchip.chip_image
        @units = nil
        @visible = false
        @divpx = get_div_array(0, @real_size.w, @ow)
        @divpy = get_div_array(0, @real_size.h, @oh)
        @modpx = get_mod_array(0, @real_size.w, @ow)
        @modpy = get_mod_array(0, @real_size.h, @oh)
        @modpx2 = get_mod_array(0, @size.w * 2 + 1, @size.w)
        @modpy2 = get_mod_array(0, @size.h * 2 + 1, @size.h)
        @cdivsx = get_div_array(0, @mapchip.chips, @mapchip.size.w)
        @cmodsx = get_mod_array(0, @mapchip.chips, @mapchip.size.w)
        @cdivsy = get_div_array(0, @mapchip.chips, @mapchip.size.h)
        @cmodsy = get_mod_array(0, @mapchip.chips, @mapchip.size.h)
        @cdivsx = @cdivsx.map{|v| v * @ow }
        @cdivsy = @cdivsy.map{|v| v * @oh }
        @cmodsx = @cmodsx.map{|v| v * @ow }
        @cmodsy = @cmodsy.map{|v| v * @oh }
        @mapchip_units = Array.new(@mapchip.chips){|idx|
          SpriteUnitFactory.create(:bitmap=>@baseimg.bitmap,
                                   :ox => (idx % @mapchip.size.w) * @ow, :oy => (idx / @mapchip.size.w) * @oh,
                                   :ow => @ow, :oh => @oh)
        }
        reSize
      end

      def get_div_array(s, t, v) #:nodoc:
        a = Array.new
        (s..t).each{|i| a.push(i / v)}
        return a
      end

      def get_mod_array(s, t, v) #:nodoc:
        a = Array.new
        (s..t).each{|i| a.push(i % v)}
        return a
      end

      def convert_position(x, y) #:nodoc:
        return Point.new(@modpx2[round(x, @size.w)],
                         @modpy2[round(y, @size.h)])
      end

      def get_code(x, y) #:nodoc:
        pos = convert_position(x, y)
        return @mapdat[pos.y][pos.x]
      end

      def dispose #:nodoc:
        @mapdat = nil
        @baseimg = nil
      end

      def_delegators(:@size, :w, :h)
    end

    #===あとで書く
    #_mapchip_:: あとで書く
    #_layer_csv_:: あとで書く
    #_event_manager_:: MapEventManagerクラスのインスタンス
    #_pos_:: あとで書く
    #返却値:: あとで書く
    def initialize(mapchip, layer_csv, event_manager, pos = Point.new(0, 0))
      init_layout
      @em = event_manager.dup
      @em.set(self)
      @mapchip = mapchip
      @pos = Point.new(*(pos.to_a))
      @coll = Collision.new(Rect.new(0, 0, 0, 0), Point.new(0, 0))
      layer_data = CSV.readlines(layer_csv)

      raise MiyakoError, "This file is not Miyako Map Layer file! : #{layer_csv}" unless layer_data.shift[0] == "Miyako Maplayer"

      tmp = layer_data.shift # 空行の空読み込み

      layer_size = Size.new(tmp[0].to_i, tmp[1].to_i)
      @w = layer_size.w * @mapchip.chip_size.w
      @h = layer_size.h * @mapchip.chip_size.h

      layers = layer_data.shift[0].to_i

      brlist = {}
      layers.times{|n|
        name = layer_data.shift[0]
        if name == "<event>"
          name = :event
        else
          name = /\<(\d+)\>/.match(name).to_a[1].to_i
        end
        values = []
        layer_size.h.times{|y|
          values << layer_data.shift.map{|m| m.to_i}
        }
        brlist[name] = values
      }

      @map_layers = Array.new
      @event_layer = nil

      if brlist.has_key?(:event)
        @event_layer = Array.new
        brlist[:event].each_with_index{|ly, y|
          ly.each_with_index{|code, x|
            next unless @em.include?(code)
            @event_layer.push(@em.create(code, x * @mapchip.chip_size.w, y * @mapchip.chip_size.h))
          }
        }
        layers -= 1
      end
      @map_layers = []
      layers.times{|i|
        br = brlist[i].map{|b| b.map{|bb| bb >= @mapchip.chips ? -1 : bb } }
        @map_layers.push(FixedMapLayer.new(@mapchip, br, layer_size, pos))
      }
      set_layout_size(@w, @h)
    end

    #===マップにイベントを追加する
    #_code_:: イベント番号(FixedMap.newメソッドで渡したイベント番号に対応)
    #_x_:: マップ上の位置(x方向)
    #_y_:: マップ常温位置(y方向)
    #返却値:: 自分自身を返す
    def add_event(code, x, y)
      return self unless @em.include?(code)
      @event_layer.push(@em.create(code, x, y))
      return self
    end

    def update_layout_position #:nodoc:
      d = Point.new(@layout.pos[0]-@pos.x, @layout.pos[1]-@pos.y)
      @pos.move_to(*@layout.pos)
      @map_layers.each{|ml| ml.pos.move_to(*@pos) }
    end

    def [](idx) #:nodoc:
      return @map_layers[idx]
    end

    #===あとで書く
    #_idx_:: あとで書く
    #_x_:: あとで書く
    #_y_:: あとで書く
    #返却値:: あとで書く
    def get_code_real(idx, x, y)
      code = @map_layers[idx].get_code((x-@pos[0]) / @mapchip.chip_size[0], (y-@pos[1]) / @mapchip.chip_size[1])
      yield code if block_given?
      return code
    end

    #===あとで書く
    #_idx_:: あとで書く
    #_x_:: あとで書く
    #_y_:: あとで書く
    #返却値:: あとで書く
    def get_code(idx, x, y)
      code = @map_layers[idx].get_code(x, y)
      yield code if block_given?
      return code
    end

    #===あとで書く
    #_idx_:: あとで書く
    #_code_:: あとで書く
    #_base_:: あとで書く
    #返却値:: あとで書く
    def set_mapchip_base(idx, code, base)
      @map_layers[idx].mapchip_units[code] = base
      return self
    end

    #===あとで書く
    #_type_:: あとで書く
    #_rect_:: あとで書く
    #_collision_:: あとで書く
    #返却値:: あとで書く
    def get_amount_by_rect(type, rect, collision)
      mma = MapMoveAmount.new([], collision.direction.dup)
      return mma if(mma.amount[0] == 0 && mma.amount[1] == 0)
      dx, dy = collision.direction[0]*collision.amount[0], collision.direction[1]*collision.amount[1]
      x, y = rect[0]-@pos[0], rect[1]-@pos[1]
      collision.pos = Point.new(x, y)
      px1, px2 = (x+dx) / @mapchip.chip_size[0], (x+rect[2]-1+dx) / @mapchip.chip_size[0]
      py1, py2 = (y+dy) / @mapchip.chip_size[1], (y+rect[3]-1+dy) / @mapchip.chip_size[1]
      (py1..py2).each{|py|
        rpy = py * @mapchip.chip_size[1]
        (px1..px2).each{|px|
          rpx = px * @mapchip.chip_size[0]
          @map_layers.each_with_index{|ml, idx|
            code = ml.get_code(px, py)
            next if code == -1 # not use chip
            @coll = @mapchip.collision_table[type][code].dup
            @coll.pos  = Point.new(rpx, rpy)
            atable = @mapchip.access_table[type][code]
            if @coll.into?(collision)
              mma.amount[0] = mma.amount[0] & atable[@@idx_ix[collision.direction[0]]]
              mma.amount[1] = mma.amount[1] & atable[@@idx_iy[collision.direction[1]]]
              mma.collisions << [idx, code, :into]
            end
          }
        }
      }
      mma.amount[0] *= collision.amount[0]
      mma.amount[1] *= collision.amount[1]
      yield mma if block_given?
      return mma
    end

    #===現在の画面の最大の大きさを矩形で取得する
    #但し、FixedMapの場合は最大の大きさ=画面の大きさなので、rectと同じ値が得られる
    #返却値:: 画像の大きさ(Rect構造体のインスタンス)
    def broad_rect
      return self.rect
    end

    #===スプライトに変換した画像を表示する
    #すべてのパーツを貼り付けた、１枚のスプライトを返す
    #引数1個のブロックを渡せば、スプライトに補正をかけることが出来る
    #返却値:: 描画したスプライト
    def to_sprite
      rect = self.broad_rect
      sprite = Sprite.new(:size=>rect.to_a[2,2], :type=>:ac)
      self.render_to(sprite){|sunit, dunit| sunit.x -= rect.x; sunit.y -= rect.y }
      yield sprite if block_given?
      return sprite
    end

    #===SpriteUnit構造体を生成する
    #いったんSpriteインスタンスを作成し、それをもとにSpriteUnit構造体を生成する。
    #返却値:: 生成したSpriteUnit構造体
    def to_unit
      return self.to_sprite.to_unit
    end

    #===あとで書く
    #返却値:: あとで書く
    def chipSize
      return @mapchip.chip_size
    end

    #===あとで書く
    #返却値:: あとで書く
    def final
      @event_layer.each{|e| e.final } if @event_layer
    end

    #===あとで書く
    #返却値:: あとで書く
    def dispose
      @map_layers.each{|l|
        l.dispose
        l = nil
      }
      @map_layers = Array.new
      if @event_layer
        @event_layer.each{|e| e.dispose }
        @event_layer = nil
      end
    end

    def re_size #:nodoc:
      @map_layers.each{|l| l.reSize }
      return self
    end

    #===マップに登録しているイベントインスタンス(マップイベント)を取得する
    #返却値:: マップイベントの配列
    def events
      return @event_layer || []
    end
  end
end
