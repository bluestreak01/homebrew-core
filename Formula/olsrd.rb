class Olsrd < Formula
  desc "Implementation of the optimized link state routing protocol"
  homepage "http://www.olsr.org"
  # olsr's website is "ill" and does not contain the latest release.
  # https://github.com/OLSR/olsrd/issues/48
  url "https://github.com/OLSR/olsrd/archive/v0.9.8.tar.gz"
  sha256 "ee9e524224e5d5304dcf61f1dc5485c569da09d382934ff85b233be3e24821a3"

  bottle do
    cellar :any_skip_relocation
    sha256 "95e531e19da3a6e11bf48851691e411d3fb27acf7dc18ccf5bed5c32aa3df4ff" => :catalina
    sha256 "5ba1b0c584a2efe1d518be4032432818fca8bbccd3078e23ef7bbb3a9359a73e" => :mojave
    sha256 "70402085753c70fb12f3e0f249bf109ac77e0a22d7be890ac6484d7ffce8501f" => :high_sierra
  end

  depends_on "coreutils" => :build # needs GNU cp

  def install
    ENV.prepend_path "PATH", Formula["coreutils"].libexec/"gnubin"
    lib.mkpath
    args = %W[
      DESTDIR=#{prefix}
      USRDIR=#{prefix}
      LIBDIR=#{lib}
      ETCDIR=#{etc}
    ]
    system "make", "build_all", *args
    system "make", "install_all", *args
  end

  plist_options startup: true, manual: "olsrd -f #{HOMEBREW_PREFIX}/etc/olsrd.conf"

  def startup_plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{HOMEBREW_PREFIX}/sbin/olsrd</string>
            <string>-f</string>
            <string>#{etc}/olsrd.conf</string>
          </array>
          <key>KeepAlive</key>
          <dict>
            <key>NetworkState</key>
            <true/>
          </dict>
        </dict>
      </plist>
    EOS
  end

  test do
    assert_match version.to_s, pipe_output("#{sbin}/olsrd")
  end
end
