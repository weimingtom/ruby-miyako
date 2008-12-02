# 共通部品クラス
# メッセージテキストボックス、コマンドボックスを定義
module MainComponent
  def self.create_textbox(size, dp, font, color)
    # ポーズカーソル作成
    wc = Sprite.new(:file=>"image/wait_cursor.png", :type=>:ac)
    wc.oh = wc.w
    wc = SpriteAnimation.new(:sprite => wc, :wait => 0.2, :pattern_list => [0, 1, 2, 3, 2, 1])

    # 選択カーソル作成
    sc = Sprite.new(:file=>"image/cursor.png", :type=>:ac)
    sc.oh = sc.w
    sc = SpriteAnimation.new(:sprite => sc, :wait => 0.2, :pattern_list => [0, 1, 2, 3, 2, 1])

    tb = TextBox.new(:size=>size, :font=>font, :wait_cursor=>wc, :select_cursor=>sc)
    tb.dp = dp
    tb.pause_type = :out # ウェイトカーソルとボックスの真下に

    bg = Sprite.new(:size=>tb.size, :type=>:ac)
    bg.dp = dp - 1
    bg.fill(color)
    
    box = Parts.new(bg)
    box[:box] = tb

    return box
  end

  # 共通変数
  @@vars = { }
  
  def var
    return @@vars
  end
  
  # フォント作成
  font = Font.sans_serif
  font.size = 24
  font.use_shadow = true

  # メッセージボックス作成
  @@message_box = self.create_textbox(Size.new(24, 4), 1000, font, [0, 0, 255, 128])
  @@message_box.center.bottom{|body| (0.1).ratio(body) }

  @@command_box = self.create_textbox(Size.new( 8, 4), 1200, font, [0, 255, 0, 128])
  @@command_box.right{|body| (0.05).ratio(body) }.top{|body| (0.05).ratio(body) }

  # メッセージボックスを動かさないこと前提
  def message_box
    return @@message_box
  end
  
  # メッセージボックスを動かさないこと前提
  def command_box
    return @@command_box
  end
end