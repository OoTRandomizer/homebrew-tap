class N64 < Formula
  desc "C toolchain for the Nintendo 64"
  head "https://github.com/glankk/n64.git"

  depends_on "gmp" => :build
  depends_on "gnu-sed" => :build
  depends_on "jansson" => :build
  depends_on "libusb" => :build
  depends_on "lua" => :build
  depends_on "make" => :build
  depends_on "texinfo" => :build
  depends_on "zlib" => :build

  def install
    ENV.prepend_path "PATH", Formula["gnu-sed"].libexec/"gnubin"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "gmake", "all-toolchain"
    system "gmake", "-j", "install-toolchain"
    system "gmake", "-j", "install-sys"
  end

  test do
    system "false" # TODO
  end
end
