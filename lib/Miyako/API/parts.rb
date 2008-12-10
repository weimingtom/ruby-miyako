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

module Miyako
  #==パーツ構成クラス
  #複数のスプライト・アニメーションをまとめて一つの部品として構成できるクラス
  #
  #最初に、基準となる「レイアウト空間(LayoutSpaceクラスのインスタンス)」を登録し、その上にパーツを加える
  #
  #すべてのパーツは、すべてレイアウト空間にスナップされる
  #(登録したパーツのレイアウト情報が変わることに注意)
  class Parts
    include Enumerable
    include Layout
    extend Forwardable

    #===Partsクラスインスタンスを生成
    #_size_:: パーツ全体の大きさ。Size構造体のインスタンスもしくは要素数が2の配列
    def initialize(size)
      init_layout
      set_layout_size(size[0], size[1])

      @parts = {}
      @parts_list = []
    end

    #===nameで示した補助パーツを返す
    #_name_:: 補助パーツに与えた名前(シンボル)
    #返却値:: 自分自身
    def [](name)
      return @parts[name]
    end

    #===補助パーツvalueをnameに割り当てる
    #_name_:: 補助パーツに与える名前(シンボル)
    #_value_:: 補助パーツのインスタンス(スプライト、テキストボックス、アニメーション、レイアウトボックスなど)
    #返却値:: 自分自身
    def []=(name, value)
      @parts_list.push(name)
      @parts[name] = value
      @parts[name].snap(self)
      return self
    end

    #===すべての補助パーツの一覧を配列で返す
    #返却値:: パーツ名の配列(登録順)
    def parts
      return @parts_list
    end

    #===指定の補助パーツを除外する
    #_name_:: 除外するパーツ名(シンボル)
    #返却値:: 自分自身
    def remove(name)
      self.delete_snap_child(@parts[name])
      @parts.delete(name)
      return self
    end

    #===メインパーツと補助パーツに対してブロックを評価する
    #返却値:: 自分自身
    def each
      @parts_list.each{|k| yield @parts[k] }
      return self
    end

    #===メインパーツと補助パーツのすべてのアニメーションを開始する
    #返却値:: 自分自身
    def start
      self.each{|parts| parts.start }
      return self
    end

    #===メインパーツと補助パーツのすべてのアニメーションを停止する
    #返却値:: 自分自身
    def stop
      self.each{|parts| parts.stop }
      return self
    end

    #===メインパーツと補助パーツのすべてのアニメーションを更新する(自動実行)
    #返却値:: 自分自身
    def update_animation
      self.each{|parts| parts.update_animation }
    end

    #===メインパーツと補助パーツのすべてのアニメーションを、最初のパターンに巻き戻す
    #返却値:: 自分自身
    def reset
      self.each{|parts| parts.reset }
      return self
    end

    #===メインパーツと補助パーツのすべてのアニメーションを更新する(自動実行)
    #返却値:: 自分自身
    def update
      self.update_animation
      return self
    end

    #===スプライトに変換した画像を表示する
    #すべてのパーツを貼り付けた、１枚のスプライトを返す
    #返却値:: 描画したスプライト
    def to_sprite
      rect = self.broad_rect
      sprite = Sprite.new(:size=>rect.to_a[2,2], :type=>:ac)
      self.render_to(sprite){|sunit, dunit| sunit.x -= rect.x; sunit.y -= rect.y }
      return sprite
    end

    #===現在の画面の最大の大きさを矩形で取得する
    #各パーツの位置により、取得できる矩形の大きさが変わる
    #但し、パーツ未登録の時は、インスタンス生成時の大きさから矩形を生成する
    #返却値:: 生成された矩形(Rect構造体のインスタンス)
    def broad_rect
      rect = self.rect.to_a
      return self.rect if @parts_list.length == 0
      rect_list = rect.zip(*(self.map{|parts| parts.broad_rect.to_a}))
      # width -> right
      rect_list[2] = rect_list[2].zip(rect_list[0]).map{|xw| xw[0] + xw[1]}
      # height -> bottom
      rect_list[3] = rect_list[3].zip(rect_list[1]).map{|xw| xw[0] + xw[1]}
      x, y = rect_list[0].min, rect_list[1].min
      return Rect.new(x, y, rect_list[2].max - x, rect_list[3].max - y)
    end

    #===パーツに登録しているインスタンスを解放する
    def dispose
      @parts_list.clear
      @parts_list = nil
      @parts.clear
      @parts = nil
    end
  end

  #==選択肢構造体
  #選択肢を構成する要素の集合
  #
  #複数のChoice構造体のインスタンスをまとめて、配列として構成されている
  #選択肢を表示させるときは、body 自体の表示位置を変更させる必要がある
  #
  #_body_:: 選択肢を示す画像
  #_body_selected_:: 選択肢を示す画像(選択時) 
  #_condition_:: 選択肢が選択できる条件を記述したブロック
  #_selected_:: 選択肢が選択されているときはtrue、選択されていないときはfalse
  #_result_:: 選択した結果を示すインスタンス
  #_left_:: 左方向を選択したときに参照するChoice構造体のインスタンス
  #_right_:: 右方向を選択したときに参照するChoice構造体のインスタンス
  #_up_:: 上方向を選択したときに参照するChoice構造体のインスタンス
  #_down_:: 下方向を選択したときに参照するChoice構造体のインスタンス
  #_base_:: 構造体が要素となっている配列
  Choice = Struct.new(:body, :body_selected, :condition, :selected, :result, :left, :right, :up, :down, :base)

  #==選択肢を管理するクラス
  #選択肢は、Shapeクラスから生成したスプライトもしくは画像で構成される
  class Choices
    include Layout
    include SpriteBase
    include Animation
    include Enumerable
    extend Forwardable

    # インスタンスを生成する
    # 返却値:: 生成された Choices クラスのインスタンス
    def initialize
      @choices = []
      @now = nil
      @non_select = false
      @last_selected = nil
    end

    # 選択肢を作成する
    # Choice 構造体のインスタンスを作成する
    # 
    # 構造体には、引数bodyと、必ず true を返す条件ブロックが登録されている。残りは nil
    #_body_:: 選択肢を示す画像
    #_body_selected_:: 選択肢を示す画像(選択時)。デフォルトはnil
    #_selected_:: 生成時に選択されているときはtrue、そうでないときはfalseを設定する
    #返却値:: 生成された Choice構造体のインスタンス
    def Choices.create_choice(body, body_selected = nil, selected = false)
      choice = Choice.new(body, body_selected, Proc.new{ true }, selected,
                          nil, nil, nil, nil, nil, nil)
      choice.left = choice
      choice.right = choice
      choice.up = choice
      choice.down = choice
      return choice
    end

    # 選択肢集合(Choice 構造体の配列)を選択肢リストに登録する
    def create_choices(choices)
      choices.each{|v| v.base = choices}
      @choices.push(choices)
      @last_selected = @choices[0][0] if (@choices.length == 1 && @last_selcted == nil)
      return self
    end

    # 選択肢データを解放する
    def dispose
      @choices.each{|c| c.clear }
      @choices.clear
      @choices = []
    end

    def each #:nodoc:
      @choices.each{|ch| yield ch }
    end

    def_delegators(:@choices, :push, :pop, :shift, :unshift, :[], :[]=, :clear, :length)

    #===選択を開始する
    #選択肢の初期位置を指定することができる
    #_x_:: 初期位置(x 座標)。規定値は 0。nilを渡すと、最後に選択した選択肢が選ばれる。
    #_y_:: 初期位置(y 座標)。規定値は 0
    def start_choice(x = 0, y = 0)
      raise MiyakoError, "Illegal choice position! [#{x}][#{y}]" if (x != nil && x < 0 || x >= @choices.length || y < 0 || y >= @choices[x].length)
      @now = x ? @choices[x][y] : @last_selected
      @now.selected = true
      @last_selected = @now
      @non_select = false
    end

    #===選択肢本体を取得する
    #選択肢の表示対象となる
    #返却値::
    def body
      return @now.body_selected ? @now.body_selected : @now.body
    end

    #===選択結果を取得する
    #現在の選択肢が所持している結果インスタンスを返す
    #返却値:: 選択結果
    def result
      return @now.result
    end

    def update_choices(org, nxt) #:nodoc:
      obase = org.base
      nbase = nxt.base
      unless obase.eql?(nbase)
        obase.each{|b|
          b.body.stop
          b.body_selected.stop if b.body_selected
        }
        nbase.each{|b|
          b.body.start
          b.body_selected.start if b.body_selected
        }
      end
    end

    private :update_choices

    #===選択肢を非選択状態に変更する
    #現在の選択状態を、全部選択していない状態にする
    #返却値:: 自分自身を返す
    def non_select
      @now.base.each{|c| c.selected = false }
      @non_select = true
      return self
    end

    #===選択肢を変更する
    #現在の選択状態を、全部選択していない状態にする
    #_x_:: x方向位置
    #_y_:: y方向位置
    #返却値:: 自分自身を返す
    def select(x, y)
      raise MiyakoError, "Illegal choice position! [#{x}][#{y}]" if (x < 0 || x >= @choices.length || y < 0 || y >= @choices[x].length)
      @now = @choices[x][y]
      return self
    end

    #===選択肢を非選択状態に変更する
    #現在の選択状態を、全部選択していない状態にする
    #返却値:: 自分自身を返す
    def non_select
      @now.base.each{|c| c.selected = false }
      @non_select = true
      return self
    end

    #===画面に描画を指示する
    #現在表示できる選択肢を、現在の状態で描画するよう指示する
    #ブロック付きで呼び出し可能(レシーバに対応したSpriteUnit構造体が引数として得られるので、補正をかけることが出来る。
    #ブロックの引数は、|インスタンスのSpriteUnit, 画面のSpriteUnit|となる。
    #返却値:: 自分自身を返す
    def render(&block)
      @now.base.each{|c|
        ((c.body_selected && c.selected) ?
          c.body_selected.render(&block) :
          c.body.render(&block)) if c.condition.call
      }
      return self
    end

    #===画像に描画を指示する
    #現在表示できる選択肢を、現在の状態で描画するよう指示する
    #ブロック付きで呼び出し可能(レシーバに対応したSpriteUnit構造体が引数として得られるので、補正をかけることが出来る。
    #ブロックの引数は、|インスタンスのSpriteUnit, 画像のSpriteUnit|となる。
    #_dst_:: 描画対象の画像インスタンス
    #返却値:: 自分自身を返す
    def render_to(dst, &block)
      @now.base.each{|c|
        ((c.body_selected && c.selected) ?
          c.body_selected.render_to(dst, &block) :
          c.body.render_to(dst, &block)) if c.condition.call
      }
      return self
    end

    #===スプライトに変換した画像を表示する
    #すべてのパーツを貼り付けた、１枚のスプライトを返す
    #返却値:: 生成したスプライト
    def to_sprite
      rect = self.broad_rect
      sprite = Sprite.new(:size=>rect.to_a[2,2], :type=>:ac)
      self.render_to(sprite){|sunit, dunit| sunit.x -= rect.x; sunit.y -= rect.y }
      return sprite
    end

    #===現在の画面の最大の大きさを矩形で取得する
    #選択肢の状態により、取得できる矩形の大きさが変わる
    #但し、選択肢が一つも見つからなかったときはnilを返す
    #返却値:: 生成された矩形(Rect構造体のインスタンス)
    def broad_rect
      choice_list = @now.base.find_all{|c| c.condition.call }.map{|c| (c.body_selected && c.selected) ? c.body_selected : c.body}
      return nil if choice_list.length == 0
      return Rect.new(*(choice_list[0].rect.to_a)) if choice_list.length == 1
      rect = choice_list.shift.to_a
      rect_list = rect.zip(*(choice_list.map{|c| c.broad_rect.to_a}))
      # width -> right
      rect_list[2] = rect_list[2].zip(rect_list[0]).map{|xw| xw[0] + xw[1]}
      # height -> bottom
      rect_list[3] = rect_list[3].zip(rect_list[1]).map{|xw| xw[0] + xw[1]}
      x, y = rect_list[0].min, rect_list[1].min
      return Rect.new(x, y, rect_list[2].max - x, rect_list[3].max - y)
    end

    # 選択肢を左移動させる
    # 返却値:: 自分自身を返す
    def left
      @last_selected = @now
      @now.selected = false
      obj = @now.left
      update_choices(@now, obj)
      @now = obj
      @now.selected = true
      return self
    end

    # 選択肢を右移動させる
    # 返却値:: 自分自身を返す
    def right
      @last_selected = @now
      @now.selected = false
      obj = @now.right
      update_choices(@now, obj)
      @now = obj
      @now.selected = true
      return self
    end

    # 選択肢を上移動させる
    # 返却値:: 自分自身を返す
    def up
      @last_selected = @now
      @now.selected = false
      obj = @now.up
      update_choices(@now, obj)
      @now = obj
      @now.selected = true
      return self
    end

    # 選択肢を下移動させる
    # 返却値:: 自分自身を返す
    def down
      @last_selected = @now
      @now.selected = false
      obj = @now.down
      update_choices(@now, obj)
      @now = obj
      @now.selected = true
      return self
    end

    # 選択肢のアニメーションを開始する
    # 返却値:: 自分自身を返す
    def start
      @now.base.each{|c| c.body.start if c.condition.call }
      return self
    end

    # 選択肢のアニメーションを終了させる
    # 返却値:: 自分自身を返す
    def stop
      @now.base.each{|c| c.body.stop if c.condition.call }
      return self
    end

    # 選択肢のアニメーションの再生位置を最初に戻す
    # 返却値:: 自分自身を返す
    def reset
      @now.base.each{|c| c.body.reset if c.condition.call }
      return self
    end

    # 選択肢のアニメーションを更新させる
    # (手動で更新する必要があるときに呼び出す)
    # 返却値:: 自分自身を返す
    def update_animation
      @now.base.each{|c|
        ((c.body_selected && c.selected) ?
         c.body_selected.update_animation :
         c.body.update_animation) if c.condition.call
      }
    end
  end
end
