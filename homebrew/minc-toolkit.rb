require 'formula'


class MincToolkit < Formula
  homepage "https://github.com/BIC-MNI/minc-toolkit"
  #url "https://github.com/BIC-MNI/minc-toolkit/archive/release-1.9.07.tar.gz"
  #version "1.9.07"
  #sha256 "f1a4b86b72b9b8e42b034b9c05a4de8b2c3ee8951b56c9fb0fb2f8a380ca9312"
  head 'git@github.com:BIC-MNI/minc-toolkit.git',  :branch => "ITK4v2", :using => :git
  

  depends_on "cmake" => :build
  depends_on :x11 # if your formula requires any X11/XQuartz components
  depends_on 'imagemagick'
  

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    # Remove unrecognized options if warned by configure
    #system "./configure", "--disable-debug",
    #                      "--disable-dependency-tracking",
    #                      "--disable-silent-rules",
    #                      "--prefix=#{prefix}"
    cmake_args = std_cmake_args + %W[
      -DMT_BUILD_ITK_TOOLS:BOOL=ON 
      -DMT_BUILD_C3D:BOOL=ON
      -DMT_BUILD_ABC:BOOL=ON
      -DMT_BUILD_ANTS:BOOL=ON
      -DMT_BUILD_ELASTIX:BOOL=ON
      -DMT_BUILD_SHARED_LIBS:BOOL=ON 
      -DMT_BUILD_VISUAL_TOOLS:BOOL=ON
      -DBUILD_TESTING:BOOL=OFF
      -DCMAKE_INSTALL_PREFIX:PATH=${prefix}
      -DCMAKE_BUILD_TYPE:STRING=Release
    ]
    cmake_args << ".."

    mkdir 'itk-build' do
      system "cmake",  *cmake_args
      system "make"
      system "make", "install" # if this fails, try separate make/make install steps
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test minc-toolkit`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
