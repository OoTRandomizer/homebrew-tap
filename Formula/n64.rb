class N64 < Formula
  desc "C toolchain for the Nintendo 64"
  homepage "https://github.com/glankk/n64"
  head "https://github.com/glankk/n64.git"

  depends_on "diffutils" => :build
  depends_on "gcc" => :build
  depends_on "gmp" => :build
  depends_on "gnu-sed" => :build
  depends_on "jansson" => :build
  depends_on "libusb" => :build
  depends_on "lua@5.4" => :build
  depends_on "make" => :build
  depends_on "texinfo" => :build
  depends_on "wget" => :build
  depends_on "zlib" => :build

  def install
    gcc = Formula["gcc"]
    ENV["CC"] = gcc.opt_bin/"gcc-15"
    ENV["CXX"] = gcc.opt_bin/"g++-15"
    ENV["CPPFLAGS"] = "-DHAVE_LUA5_4_LUA_H -llua@5.4\
     -DHAVE_LIBUSB_1_0_LIBUSB_H -lusb-1.0\
      -I#{HOMEBREW_PREFIX}/include\
      -L#{HOMEBREW_PREFIX}/lib"

    ENV["BINUTILS_VERSION"] = "binutils-2.45.1"
    ENV["GCC_VERSION"] = "gcc-15.2.0"
    ENV["NEWLIB_VERSION"] = "newlib-4.6.0.20260123"
    ENV["GDB_VERSION"] = "gdb-17.1"

    ENV.prepend_path "PATH", Formula["gnu-sed"].libexec/"gnubin"

    system "./configure", "--prefix=#{prefix}"
    system "gmake", "toolchain-all"
    system "gmake", "toolchain-install"
    system "gmake"
    system "gmake", "install"
    system "gmake", "install-sys"
  end
end
