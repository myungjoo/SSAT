# Build utility binaries for SSAT APIs.
project('ssat-util', 'c',
  version: '1.3.0',
  license: ['Apache-2.0'],
  meson_version: '>=0.50.0',
  default_options: [
    'werror=true',
    'warning_level=2',
    'c_std=gnu89',
    'cpp_std=c++14'
  ]
)

cc = meson.get_compiler('c')


#################################################
# bmp2png
#################################################
libpng_dep = dependency('libpng', required: true)
glib_dep = dependency('glib-2.0', required: true)
b2p = executable('bmp2png',
  'bmp2png.c',
  dependencies: [libpng_dep, glib_dep],
  install: true,
)
