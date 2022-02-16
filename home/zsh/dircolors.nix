{ lib, pkgs, ... }:

{
  config = {
    home.file.".dircolors".text = let
      executable = [ ".cmd" ".exe" ".com" ".btm" ".bat" ".bin" ".hex" ".elf" ];
      archive = [
        ".7z" ".ace" ".alz" ".apk" ".arc" ".arj" ".bz" ".bz2" ".bzip2" ".cab" ".cpio" ".deb" ".dwm"
        ".dz" ".ear" ".esd" ".gem" ".gz" ".jar" ".lha" ".lrz" ".lz" ".lz4" ".lzh" ".lzma" ".lzo"
        ".rar" ".rpm" ".rz" ".sar" ".swm" ".t7z" ".tar" ".taz" ".tbz" ".tbz2" ".tgz" ".tlz" ".txz"
        ".tz" ".tzo" ".tzst" ".war" ".wim" ".xz" ".z" ".Z" ".zip" ".zoo" ".zst"
      ];
      media = [
        ".aac" ".anx" ".asf" ".au" ".avi" ".axa" ".axv" ".bmp" ".cgm" ".CR2" ".divx" ".dl" ".emf"
        ".eps" ".flac" ".flc" ".fli" ".flv" ".gif" ".gl" ".ico" ".jpeg" ".jpg" ".JPG" ".m2ts"
        ".m2v" ".m4a" ".m4v" ".mid" ".midi" ".mjpeg" ".mjpg" ".mka" ".mkv" ".mng" ".mov" ".mp3"
        ".mp4" ".mp4v" ".mpc" ".mpeg" ".mpg" ".nuv" ".oga" ".ogg" ".ogm" ".ogv" ".ogx" ".opus"
        ".pbm" ".pcx" ".pgm" ".png" ".ppm" ".qt" ".ra" ".rm" ".rmvb" ".spx" ".svg" ".svgz" ".tga"
        ".tif" ".tiff" ".vob" ".wav" ".webm" ".webp" ".wmv" ".xbm" ".xcf" ".xpm" ".xspf" ".xwd"
        ".yuv"
      ];
      document = [
        ".pdf" ".ps" ".txt" ".html" ".css" ".rst" ".md" ".patch" ".diff" ".tex" ".xls" ".xlsx"
        ".doc" ".docx" ".ppt" ".pptx" ".key" ".ods" ".odt"
      ];
      template = [ ".pt" ".tmpl" ".in" ".ots" ".ott" ];
      configuration = [
        ".conf" ".config" ".cnf" ".cfg" ".ini" ".properties" ".yaml" ".vcl" ".nix"
      ];
      source_code = [
        ".c" ".cpp" ".cxx" ".cc" ".py" ".coffesscript" ".js" ".rb" ".sh" ".zsh" ".env" ".bash"
        ".php" ".java" ".zcml" ".pl" ".lua" ".clj" ".cs" ".fs" ".fsx" ".go" ".rs"
      ];
      data = [ ".db" ".sql" ".json" ".plist" ".xml" ];
      special = [
        ".tex" ".rdf" ".owl" ".n3" ".ttl" ".nt" ".torrent" ".xml" "*Makefile" "*makefile"
        "*Cargo.toml" "*Rakefile" "*build.xml" "*rc" ".nfo" "*README" "*README.txt" "*readme.txt"
        "*README.markdown" "*README.md" "*shell.nix"
      ];
      low_importance = [
        ".log" ".bak" ".aux" ".lof" ".lol" ".lot" ".out" ".toc" ".bbl" ".blg" "*~" "*#" ".part"
        ".incomplete" ".swp" ".tmp" ".temp" ".o" ".obj" ".pyc" ".pyo" ".class" ".cache" ".egg-info"
        "*Cargo.lock"
      ];

      group = l: c: lib.concatStringsSep "\n" (map (x: "${x} ${c}") l);
    in ''
      NORMAL 0
      FILE 0
      RESET 0
      DIR 38;5;4
      LINK 38;5;6;48;5;0;1
      MULTIHARDLINK 38;5;15;1
      FIFO 38;5;3;48;5;0;1
      SOCK 38;5;5;48;5;0;1
      DOOR 38;5;5;48;5;0;1
      BLK 38;5;7;48;5;0;1
      CHR 38;5;7;48;5;0;1
      ORPHAN 38;5;1;7
      MISSING 38;5;1;7
      SETUID 38;5;1;7
      SETGID 38;5;3;7
      CAPABILITY 38;5;1;7
      STICKY_OTHER_WRITABLE 38;5;2;7
      OTHER_WRITABLE 38;5;4;4
      STICKY 38;5;4;7
      EXEC 38;5;2

      ${group executable "38;5;2"}
      ${group archive "38;5;16"}
      ${group media "38;5;17"}
      ${group document "38;5;3"}
      ${group template "38;5;3;1"}
      ${group configuration "38;5;6"}
      ${group source_code "38;5;5"}
      ${group data "38;5;1"}
      ${group special "38;5;15"}
      ${group low_importance "38;5;7"}
    '';

    programs.zsh.initExtraBeforeCompInit = ''
      eval $(${pkgs.coreutils}/bin/dircolors -b ~/.dircolors)
    '';
  };
}
