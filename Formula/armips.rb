class Armips < Formula
  desc "Assembler for various ARM and MIPS platforms"
  homepage "https://github.com/Kingcom/armips"
  license "MIT"
  head ENV.fetch("HOMEBREW_OOTR_ARMIPS_HEAD_URL", "https://github.com/Kingcom/armips.git")

  depends_on "cmake" => :build

  def install
    source_root = if ENV["HOMEBREW_OOTR_ARMIPS_SOURCE_DIR"].to_s.empty?
      find_armips_source_root(buildpath)
    else
      stage_local_source(ENV.fetch("HOMEBREW_OOTR_ARMIPS_SOURCE_DIR"))
    end

    cd source_root do
      system "cmake", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      bin.install "build/armips"
    end
  end

  test do
    (testpath/"test.asm").write(".notice \"hello from armips\"")
    assert_equal "test.asm(1) notice: hello from armips", shell_output("#{bin}/armips test.asm").strip
  end

  private

  def stage_local_source(source_value)
    source = Pathname(source_value).expand_path
    odie "Local armips source directory does not exist: #{source}" unless source.directory?
    source = source.realpath

    staged = buildpath/"local-armips-source"
    rm_rf staged
    staged.mkpath
    source.children.each do |entry|
      next if %w[.git .brew_home __MACOSX].include?(entry.basename.to_s)
      cp_r entry, staged
    end
    find_armips_source_root(staged)
  end

  def find_armips_source_root(base)
    candidates = [base]
    candidates.concat(Dir.glob((base/"**/CMakeLists.txt").to_s).map { |path| Pathname(path).dirname })
    source_root = candidates.uniq.find { |candidate| (candidate/"CMakeLists.txt").file? }
    odie "Could not find an armips source root under #{base}" unless source_root
    source_root
  end
end
