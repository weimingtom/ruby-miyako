/*
--
Miyako v2.1 Extend Library "Miyako no Katana"
Copyright (C) 2009  Cyross Makoto

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
*/

/*
=miyako_no_katana
Authors:: Cyross Makoto
Version:: 2.1
Copyright:: 2007-2008 Cyross Makoto
License:: LGPL2.1
 */
#include "defines.h"

static VALUE mSDL = Qnil;
static VALUE mMixer = Qnil;
static VALUE mMiyako = Qnil;
static VALUE mAudio = Qnil;
static VALUE mInput = Qnil;
static VALUE mScreen = Qnil;
static VALUE cJoystick = Qnil;
static VALUE cMusic = Qnil;
static VALUE cEvent = Qnil;
static VALUE cBGM = Qnil;
static VALUE cSE = Qnil;
static VALUE nOne = Qnil;
static VALUE nZero = Qnil;
static volatile ID id_update_all = Qnil;
static volatile ID id_is_playing = Qnil;
static volatile ID id_is_fade_out = Qnil;
static volatile ID id_in_the_loop = Qnil;
static volatile ID id_is_playing_wo_loop = Qnil;
static volatile ID id_is_allow_countup = Qnil;
static volatile ID id_allow_countup = Qnil;
static volatile ID id_countup = Qnil;
static volatile ID id_poll = Qnil;
static volatile ID id_call = Qnil;
static volatile ID id_reset_ticks = Qnil;
static volatile ID id_setup_ticks = Qnil;
static volatile ID id_after = Qnil;
static volatile int zero = 0;
static volatile int one = 1;
static volatile VALUE sy_pushed = Qnil;
static volatile VALUE sy_pos = Qnil;
static volatile VALUE sy_dx = Qnil;
static volatile VALUE sy_dy = Qnil;
static volatile VALUE sy_click = Qnil;
static volatile VALUE sy_drop = Qnil;
static volatile VALUE sy_inner = Qnil;
static volatile VALUE sy_focus = Qnil;
static volatile VALUE sy_mini = Qnil;
static volatile VALUE sy_left = Qnil;
static volatile VALUE sy_right = Qnil;
static volatile VALUE sy_middle = Qnil;
static volatile VALUE sy_trigger = Qnil;
static volatile VALUE sy_alt = Qnil;
static volatile VALUE sy_ent = Qnil;

/*
:nodoc:
*/
static VALUE input_update(VALUE self)
{
#if 0
  int i, len;
  VALUE *ptr;
  VALUE keys, e_list, e;
#else
  int i;
  VALUE *ptr;
  VALUE keys, e, proc;
#endif

  VALUE btn = rb_iv_get(self, "@@btn");
  VALUE mouse = rb_iv_get(self, "@@mouse");
  VALUE process = rb_iv_get(self, "@@process");
  VALUE toggle = rb_iv_get(self, "@@toggle_screen_mode");

  VALUE trigger = rb_hash_lookup(btn, sy_trigger);
  VALUE pushed  = rb_hash_lookup(btn, sy_pushed);
  VALUE click   = rb_hash_lookup(mouse, sy_click);
  VALUE drop    = rb_hash_lookup(mouse, sy_drop);
  VALUE pos     = rb_hash_lookup(mouse, sy_pos);

  rb_funcall(cJoystick, id_update_all, 0);

  keys = rb_funcall(pushed, rb_intern("keys"), 0);
  ptr = RARRAY_PTR(keys);
  for(i=0; i<RARRAY_LEN(keys); i++)
  {
    rb_hash_aset(pushed, *(ptr+i), nZero);
  }
  rb_hash_aset(pos, sy_dx, nZero);
  rb_hash_aset(pos, sy_dy, nZero);

  rb_hash_aset(click, sy_left, Qfalse);
  rb_hash_aset(click, sy_middle, Qfalse);
  rb_hash_aset(click, sy_right, Qfalse);
  rb_hash_aset(drop, sy_left, Qfalse);
  rb_hash_aset(drop, sy_middle, Qfalse);
  rb_hash_aset(drop, sy_right, Qfalse);
  rb_hash_aset(mouse, sy_inner, Qfalse);
  rb_hash_aset(mouse, sy_focus, Qfalse);
  rb_hash_aset(mouse, sy_mini, Qfalse);

#if 0
  e_list = rb_ary_new();
  e = rb_funcall(cEvent, id_poll, 0);
  while(e != Qnil)
  {
    rb_ary_push(e_list, e);
    e = rb_funcall(cEvent, id_poll, 0);
  }

  ptr = RARRAY_PTR(e_list);
  len = RARRAY_LEN(e_list);
  for(i=0; i<len; i++)
  {
    VALUE e2 = *(ptr + len - i - 1);
    VALUE proc = rb_hash_lookup(process, CLASS_OF(e2));
    if(proc != Qnil){ rb_funcall(proc, id_call, 1, e2); }
    if(rb_hash_lookup(trigger, sy_alt) == nOne &&
       rb_hash_lookup(pushed, sy_ent) == nOne &&
       toggle == Qtrue)
    {
      rb_funcall(mScreen, rb_intern("toggle_mode"), 0);
      rb_hash_aset(trigger, sy_alt, nZero);
      rb_hash_aset(pushed, sy_ent, nZero);
    }
  }
#else
  e = rb_funcall(cEvent, id_poll, 0);
  while(e != Qnil)
  {
    proc = rb_hash_lookup(process, CLASS_OF(e));
    if(proc != Qnil){ rb_funcall(proc, id_call, 1, e); }
    if(rb_hash_lookup(trigger, sy_alt) == nOne &&
       rb_hash_lookup(pushed, sy_ent) == nOne &&
       toggle == Qtrue)
    {
      rb_funcall(mScreen, rb_intern("toggle_mode"), 0);
      rb_hash_aset(trigger, sy_alt, nZero);
      rb_hash_aset(pushed, sy_ent, nZero);
    }
    e = rb_funcall(cEvent, id_poll, 0);
  }
#endif
  rb_funcall(self, id_after, 0);

  return Qnil;
}

void _miyako_input_update()
{
  input_update(mInput);
}

/*
:nodoc:
*/
static VALUE bgm_update(VALUE self)
{
  VALUE nua, pb;
  nua = rb_gv_get("$not_use_audio");
  if(nua == Qfalse) return Qnil;

  pb = rb_iv_get(self, "@@playin_bgm");
  if(pb == Qnil) return Qnil;

  if(rb_funcall(pb, id_is_playing_wo_loop, 0) == Qfalse &&
     rb_funcall(pb, id_in_the_loop, 0) == Qtrue)
  {
    rb_funcall(pb, id_countup, 0);
    rb_funcall(pb, id_setup_ticks, 0);
    if(rb_funcall(pb, id_in_the_loop, 0) == Qfalse){
      rb_funcall(pb, id_reset_ticks, 0);
      rb_iv_set(self, "@@playin_bgm", Qnil);
    }
  }
  else if(rb_funcall(pb, id_is_playing, 0) == Qfalse &&
          rb_funcall(pb, id_is_fade_out, 0) == Qfalse)
  {
    rb_funcall(pb, id_reset_ticks, 0);
    rb_iv_set(self, "@@playin_bgm", Qnil);
  }
  else if(rb_funcall(pb, id_is_allow_countup, 0) == Qfalse)
  {
     rb_funcall(pb, id_allow_countup, 0);
  }

  return Qnil;
}

/*
:nodoc:
*/
static VALUE se_update(VALUE self)
{
  int i;
  VALUE nua, playings, *ptr;
  nua = rb_gv_get("$not_use_audio");
  if(nua == Qfalse) return Qnil;

  playings = rb_iv_get(self, "@@playings");
  ptr = RARRAY_PTR(playings);
  for(i=0; i<RARRAY_LEN(playings); i++)
  {
    VALUE pl = *(ptr+i);

    if(rb_funcall(pl, id_is_playing_wo_loop, 0) == Qfalse &&
       rb_funcall(pl, id_in_the_loop, 0) == Qtrue)
    {
      rb_funcall(pl, id_countup, 0);
      if(rb_funcall(pl, id_in_the_loop, 0) == Qfalse)
        rb_ary_delete(playings, pl);
    }
    else if(rb_funcall(pl, id_is_playing, 0) == Qfalse &&
            rb_funcall(pl, id_is_fade_out, 0) == Qfalse)
    {
      rb_ary_delete(playings, pl);
    }
    else if(rb_funcall(pl, id_is_allow_countup, 0) == Qfalse)
    {
      rb_funcall(pl, id_allow_countup, 0);
    }
  }

  return Qnil;
}

/*
:nodoc:
*/
static VALUE audio_update(VALUE self)
{
  bgm_update(cBGM);
  se_update(cSE);
  return self;
}

void _miyako_audio_update()
{
  audio_update(mAudio);
}

/*
:nodoc:
*/
static VALUE bgm_set_offset(VALUE self, VALUE val)
{
  double pos = (double)(NUM2INT(val))/1000.0;
  Mix_SetMusicPosition(pos);
  rb_iv_set(self, "@offset_ticks", val);
  return Qnil;
}

void Init_miyako_input_audio()
{
  mSDL = rb_define_module("SDL");
  mMixer = rb_define_module_under(mSDL, "Mixer");
  mMiyako = rb_define_module("Miyako");
  mAudio = rb_define_module_under(mMiyako, "Audio");
  mInput = rb_define_module_under(mMiyako, "Input");
  mScreen = rb_define_module_under(mMiyako, "Screen");
  cJoystick = rb_define_class_under(mSDL, "Joystick", rb_cObject);
  cMusic = rb_define_class_under(mMixer, "Music", rb_cObject);
  cEvent = rb_define_class_under(mSDL, "Event", rb_cObject);
  cBGM = rb_define_class_under(mAudio, "BGM", rb_cObject);
  cSE = rb_define_class_under(mAudio, "SE", rb_cObject);

  id_update_all = rb_intern("updateAll");
  id_poll = rb_intern("poll");
  id_call = rb_intern("call");
  id_is_playing = rb_intern("playing?");
  id_is_fade_out = rb_intern("fade_out?");
  id_in_the_loop = rb_intern("in_the_loop?");
  id_is_playing_wo_loop = rb_intern("playing_without_loop?");
  id_is_allow_countup = rb_intern("allow_loop_count_up?");
  id_allow_countup = rb_intern("allow_loop_count_up");
  id_countup = rb_intern("loop_count_up");
  id_reset_ticks = rb_intern("reset_ticks");
  id_setup_ticks = rb_intern("setup_ticks");
  id_after = rb_intern("after_exec");

  sy_pushed  = ID2SYM(rb_intern("pushed"));
  sy_pos     = ID2SYM(rb_intern("pos"));
  sy_dx      = ID2SYM(rb_intern("dx"));
  sy_dy      = ID2SYM(rb_intern("dy"));
  sy_click   = ID2SYM(rb_intern("click"));
  sy_drop    = ID2SYM(rb_intern("drop"));
  sy_inner   = ID2SYM(rb_intern("inner"));
  sy_focus   = ID2SYM(rb_intern("focus"));
  sy_mini    = ID2SYM(rb_intern("mini"));
  sy_left    = ID2SYM(rb_intern("left"));
  sy_right   = ID2SYM(rb_intern("right"));
  sy_middle  = ID2SYM(rb_intern("middle"));
  sy_trigger = ID2SYM(rb_intern("trigger"));
  sy_alt     = ID2SYM(rb_intern("alt"));
  sy_ent     = ID2SYM(rb_intern("ent"));

  zero = 0;
  nZero = INT2NUM(zero);
  one = 1;
  nOne = INT2NUM(one);

  rb_define_singleton_method(mInput, "update", input_update, 0);
  rb_define_singleton_method(mAudio, "update", audio_update, 0);
  rb_define_singleton_method(mAudio, "update", audio_update, 0);
  rb_define_singleton_method(cBGM, "update", bgm_update, 0);
  rb_define_singleton_method(cSE, "update", se_update, 0);

  rb_define_method(cBGM, "offset=", bgm_set_offset, 1);
}
