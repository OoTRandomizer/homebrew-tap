class N64 < Formula
  desc "C toolchain for the Nintendo 64"
  homepage "https://github.com/glankk/n64"
  if ENV["HOMEBREW_N64_HEAD_URL"]
    head ENV.fetch("HOMEBREW_N64_HEAD_URL")
  else
    head "https://github.com/glankk/n64.git"
  end

  depends_on "gcc" => :build
  depends_on "gmp"
  depends_on "gnu-sed" => :build
  depends_on "jansson"
  depends_on "libmpc"
  depends_on "libusb"
  depends_on "lua"
  depends_on "make" => :build
  depends_on "mpfr"
  depends_on "texinfo" => :build
  depends_on "wget" => :build
  depends_on "xz" => :build
  depends_on "zlib"

  def install
    gcc = Formula["gcc"]
    gcc_major = gcc.version.major
    ENV["CC"] = (gcc.opt_bin/"gcc-#{gcc_major}").to_s
    ENV["CXX"] = (gcc.opt_bin/"g++-#{gcc_major}").to_s
    ENV["HOMEBREW_PREFIX"] = HOMEBREW_PREFIX.to_s

    gnu_sed_bin = Formula["gnu-sed"].opt_libexec/"gnubin"
    odie "GNU sed compatibility directory was not found: #{gnu_sed_bin}" unless gnu_sed_bin.directory?
    ENV.prepend_path "PATH", gnu_sed_bin

    prepare_dependency_paths

    source_root = if ENV["HOMEBREW_N64_SOURCE_DIR"].to_s.empty?
      find_n64_source_root(buildpath)
    else
      stage_local_source(ENV.fetch("HOMEBREW_N64_SOURCE_DIR"))
    end

    configure_args = ["--prefix=#{prefix}"]
    configure_args << "--disable-toolchain-gdb" if OS.mac? && Hardware::CPU.arm?

    cd source_root do
      system "./configure", *configure_args

      if OS.mac? && Hardware::CPU.arm?
        jobs = ENV.fetch("HOMEBREW_N64_JOBS", "1")
        odie "HOMEBREW_N64_JOBS must be a positive integer" unless jobs.match?(/\A[1-9][0-9]*\z/)
        ENV.deparallelize
        make_args = ["-j#{jobs}"]
        system "gmake", *make_args, "toolchain-all"
        system "gmake", *make_args, "toolchain-install"
        system "gmake", *make_args
        system "gmake", *make_args, "install"
        system "gmake", *make_args, "install-sys"
      else
        system "gmake", "toolchain-all"
        system "gmake", "toolchain-install"
        system "gmake"
        system "gmake", "install"
        system "gmake", "install-sys"
      end
    end
  end

  test do
    assert_predicate bin/"mips64-gcc", :executable?
    assert_predicate bin/"mips64-as", :executable?
    assert_predicate bin/"mips64-ld", :executable?
    system bin/"mips64-gcc", "--version"
  end

  private

  def prepare_dependency_paths
    %w[gmp mpfr libmpc lua zlib jansson libusb].each do |name|
      dependency = Formula[name]
      include_dir = dependency.opt_include
      lib_dir = dependency.opt_lib
      if include_dir.directory?
        ENV.append_path "CPATH", include_dir
        ENV.append "CPPFLAGS", "-I#{include_dir}"
      end
      if lib_dir.directory?
        ENV.append_path "LIBRARY_PATH", lib_dir
        ENV.append "LDFLAGS", "-L#{lib_dir}"
      end
    end
  end

  def stage_local_source(source_value)
    source = Pathname(source_value).expand_path
    odie "Local n64 source directory does not exist: #{source}" unless source.directory?
    source = source.realpath

    staged = buildpath/"local-n64-source"
    rm_rf staged
    staged.mkpath
    source.children.each do |entry|
      next if %w[.git .brew_home __MACOSX].include?(entry.basename.to_s)
      cp_r entry, staged
    end
    find_n64_source_root(staged)
  end

  def find_n64_source_root(base)
    candidates = [base]
    candidates.concat(Dir.glob((base/"**/configure.ac").to_s).map { |path| Pathname(path).dirname })
    source_root = candidates.uniq.find do |candidate|
      (candidate/"configure.ac").file? && (candidate/"Makefile.in").file?
    end
    odie "Could not find an n64 source root under #{base}" unless source_root
    source_root
  end
end
