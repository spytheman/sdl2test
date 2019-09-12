// Copyright(C) 2019 Nicolas Sauzede. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE_v file.
module main

//import vsdl2
import vsdl2gl
fn sdl_fill_rect(screen &SdlSurface, rect &SdlRect, col &SdlColor) {
	vsdl2gl.fill_rect(screen, rect, col)
}

type atexit_func_t fn ()
fn C.atexit(atexit_func_t)

const (
        Colors = [
                SdlColor{byte(255), byte(255), byte(255), byte(0)},
                SdlColor{byte(255), byte(0), byte(0), byte(0)}
        ]
)

struct AudioContext {
mut:
//        audio_pos *byte
        audio_pos voidptr
        audio_len u32
        wav_spec SdlAudioSpec
        wav_buffer &byte
        wav_length u32
        wav2_buffer &byte
        wav2_length u32
}

fn acb(userdata voidptr, stream &byte, _len int) {
        mut ctx := &AudioContext(userdata)
//        println('acb!!! wav_buffer=${ctx.wav_buffer} audio_len=${ctx.audio_len}')
        if ctx.audio_len == u32(0) {
                C.memset(stream, 0, _len)
                return
        }
        mut len := u32(_len)
        if len > ctx.audio_len { len = ctx.audio_len }
        C.memcpy(stream, ctx.audio_pos, len)
//      ctx.audio_pos = voidptr(u64(ctx.audio_pos) + u64(len))
        ctx.audio_pos += len
        ctx.audio_len -= len
}
/*
fn sdl_gl_fill_rect(screen &SdlSurface, rect &SdlRect, col &SdlColor) {
	ww := screen.w
	hh := screen.h
	r := f32(1)
	g := f32(0)
	b := f32(0)
	x := f32(2) * rect.x / (ww - 1) - 1
	y := f32(2) * ((hh - 1) - rect.y) / (hh - 1) - 1
	w := f32(2) * rect.w / ww
	h := f32(2) * rect.h / hh
	C.glMatrixMode(C.GL_MODELVIEW)
	C.glLoadIdentity()
	C.glBegin(C.GL_QUADS)
	C.glColor3f(r, g, b)
	C.glVertex2f(x, y)
	C.glVertex2f(x + w, y)
	C.glVertex2f(x + w, y - h)
	C.glVertex2f(x, y - h)
	C.glEnd()
}
*/
fn main() {
        println('hello SDL2 OpenGL V !!')
        w := 400
        h := 300
        bpp := 32
        sdl_window := *voidptr(0)
        sdl_renderer := *voidptr(0)
        C.SDL_Init(C.SDL_INIT_VIDEO | C.SDL_INIT_AUDIO)
        C.atexit(C.SDL_Quit)
        C.SDL_CreateWindowAndRenderer(w, h, 0, &sdl_window, &sdl_renderer)
//        println('renderer=$sdl_renderer')
        screen := C.SDL_CreateRGBSurface(0, w, h, bpp, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)
//        sdl_texture := C.SDL_CreateTexture(sdl_renderer, C.SDL_PIXELFORMAT_ARGB8888, C.SDL_TEXTUREACCESS_STREAMING, w, h)

	// OpenGL
	// Loosely followed the great SDL2+OpenGL2.1 tutorial here :
	// http://lazyfoo.net/tutorials/OpenGL/01_hello_opengl/index2.php
	gl_context := C.SDL_GL_CreateContext(sdl_window)
	if isnil(gl_context) {
		println('Couldn\'t create OpenGL context !')
	} else {
		println('Created OpenGL context.')
	}
	C.SDL_GL_SetSwapInterval(1)
	C.glMatrixMode(C.GL_PROJECTION)
	C.glLoadIdentity()
	C.glMatrixMode(C.GL_MODELVIEW)
	C.glLoadIdentity()
	C.glClearColor(0., 0., 0., 1.)

        mut actx := AudioContext{}
        C.SDL_zero(actx)
        C.SDL_LoadWAV('sounds/door2.wav', &actx.wav_spec, &actx.wav_buffer, &actx.wav_length)
        C.SDL_LoadWAV('sounds/single.wav', &actx.wav_spec, &actx.wav2_buffer, &actx.wav2_length)
        actx.wav_spec.callback = acb
        actx.wav_spec.userdata = &actx
        if C.SDL_OpenAudio(&actx.wav_spec, 0) < 0 {
                println('couldn\'t open audio')
                return
        }
        mut quit := false
        mut ballx := 0
        bally := h / 2
        balld := 10
        ballm := balld / 2
        mut balldir := ballm
	mut nangle := 0
        for !quit {
                ev := SdlEvent{}
                for !!C.SDL_PollEvent(&ev) {
                        switch int(ev._type) {
                                case C.SDL_QUIT:
                                        quit = true
                                        break
                                case C.SDL_KEYDOWN:
                                        switch int(ev.key.keysym.sym) {
                                                case C.SDLK_ESCAPE:
                                                        quit = true
                                                        break
                                                case C.SDLK_SPACE:
                                                        actx.audio_pos = actx.wav2_buffer
                                                        actx.audio_len = actx.wav2_length
                                                        C.SDL_PauseAudio(0)
                                        }
                        }
                }
                if quit {
                        break
                }
                ballx += balldir
                if balldir == ballm {
                        if ballx == w - balld * 4 {
                                actx.audio_pos = actx.wav2_buffer
//                                actx.audio_len = actx.wav2_length
                                C.SDL_PauseAudio(0)
                        } else if ballx >= w - balld {
                                balldir = -ballm
                                actx.audio_pos = actx.wav_buffer
                                actx.audio_len = actx.wav_length
                                C.SDL_PauseAudio(0)
                        }
                } else {
                        if ballx == balld * 4 {
                                actx.audio_pos = actx.wav2_buffer
//                                actx.audio_len = actx.wav2_length
                                C.SDL_PauseAudio(0)
                        } else if ballx <= 0 {
                                balldir = ballm
                                actx.audio_pos = actx.wav_buffer
                                actx.audio_len = actx.wav_length
                                C.SDL_PauseAudio(0)
                        }
                }
		C.glClear(C.GL_COLOR_BUFFER_BIT)

		// 3D part
		C.glMatrixMode(C.GL_MODELVIEW)
		C.glLoadIdentity()
		angle := f32(nangle) * 2
		nangle++
		C.glRotatef(angle,f32(1),f32(1),f32(1))
		C.glBegin(C.GL_QUADS)
		C.glColor3f(0., 0., 0.2)
		C.glVertex2f(-0.5, -0.5)
		C.glColor3f(1., 0., 0.2)
		C.glVertex2f(0.5, -0.5)
		C.glColor3f(1., 1., 0.2)
		C.glVertex2f(0.5, 0.5)
		C.glColor3f(0., 1., 0.2)
		C.glVertex2f(-0.5, 0.5)
		C.glEnd()

		// 2D part
		mut rect := SdlRect{}
		mut col := SdlColor{}
		rect = SdlRect {ballx, bally, balld, balld}
		col = SdlColor{byte(255), byte(0), byte(0), byte(0)}
//		vsdl2gl.fill_rect(screen, &rect, &col)
//		type sdl_fill_rect vsdl2gl.fill_rect
		sdl_fill_rect(screen, &rect, &col)

		C.SDL_GL_SwapWindow(sdl_window)

		C.SDL_Delay(10)
        }
        C.SDL_CloseAudio()
        if voidptr(actx.wav_buffer) != voidptr(0) {
                C.SDL_FreeWAV(actx.wav_buffer)
	}
}