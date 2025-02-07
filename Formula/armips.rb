class Armips < Formula
  desc "Assembler for various ARM and MIPS platforms"
  license "MIT"
  head "https://github.com/Kingcom/armips.git"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    bin.install "build/armips"
  end

  test do
    (testpath/"test.asm").write(".notice \"hello from armips\"")
    assert_equal "test.asm(1) notice: hello from armips", shell_output("#{bin}/armips test.asm").strip
  end
end
