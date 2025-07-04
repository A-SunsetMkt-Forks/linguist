require_relative "./helper"

class TestHeuristics < Minitest::Test
  include Linguist

  def fixture(name)
    File.read(File.join(samples_path, name))
  end

  def file_blob(name, alt_name=nil)
    path = File.exist?(name) ? name : File.join(samples_path, name)
    blob = FileBlob.new(path)
    if !alt_name.nil?
      blob.instance_variable_set("@path", alt_name)
    end
    blob
  end

  def all_fixtures(language_name, file="*")
    fixs = Dir.glob("#{samples_path}/#{language_name}/#{file}") +
           Dir.glob("#{fixtures_path}/#{language_name}/#{file}") -
           ["#{samples_path}/#{language_name}/filenames"]
    fixs = fixs.reject { |f| File.symlink?(f) }
    assert !fixs.empty?, "no fixtures for #{language_name} #{file}"
    fixs
  end

  def test_no_match
    language = []
    results = Heuristics.call(file_blob("JavaScript/namespace.js"), language)
    assert_equal [], results
  end

  def test_symlink_empty
    assert_equal [], Heuristics.call(file_blob("Markdown/symlink.md"), [Language["Markdown"]])
  end

  def test_no_match_if_regexp_timeout
    skip("This test requires Ruby 3.2.0 or later") if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.2.0')

    Regexp.any_instance.stubs(:match?).raises(Regexp::TimeoutError)
    assert_equal [], Heuristics.call(file_blob("#{fixtures_path}/Generic/stl/STL/cube1.stl"), [Language["STL"]])
  end

  # alt_name is a file name that will be used instead of the file name of the
  # original sample. This is used to force a sample to go through a specific
  # heuristic even if its extension doesn't match.
  def assert_heuristics(hash, alt_name=nil)
    candidates = hash.keys.map { |l| Language[l] }

    hash.each do |language, blobs|
      blobs = Array(blobs)
      assert blobs.length >= 1, "Expected at least 1 blob for #{language}"
      blobs.each do |blob|
        result = Heuristics.call(file_blob(blob, alt_name), candidates)
        if language.nil?
          expected = []
        elsif language.is_a?(Array)
          expected = language.map{ |l| Language[l] }
        else
          expected = [Language[language]]
        end
        assert_equal expected, result, "Failed for #{blob}"
      end
    end
  end

  def test_detect_still_works_if_nothing_matches
    blob = Linguist::FileBlob.new(File.join(samples_path, "Objective-C/hello.m"))
    match = Linguist.detect(blob)
    assert_equal Language["Objective-C"], match
  end

  def test_all_extensions_are_listed
    Heuristics.all.all? do |rule|
      rule.languages.each do |lang|
        unlisted = rule.extensions.reject do |ext|
          lang.extensions.include?(ext) or
          lang.filenames.select {|n| n.downcase.end_with? ext.downcase}
        end
        assert_equal [], unlisted, (<<~EOF).chomp
          The extension '#{unlisted.first}' is not assigned to #{lang.name}.
          Add it to `languages.yml` or update the heuristic which uses it
        EOF
      end
    end
  end

  def test_1_by_heuristics
    n = 1
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
       nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_1in_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.1in")
  end

  def test_1m_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.1m")
  end

  def test_1x_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.1x")
  end

  def test_2_by_heuristics
    n = 2
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_3_by_heuristics
    n = 3
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_3in_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.3in")
  end

  def test_3m_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.3m")
  end

  def test_3p_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.3p")
  end

  def test_3pm_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.3pm")
  end

  def test_3qt_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.3qt")
  end

  def test_3x_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.3x")
  end

  def test_4_by_heuristics
    n = 4
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_5_by_heuristics
    n = 5
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_6_by_heuristics
    n = 6
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_7_by_heuristics
    n = 7
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_8_by_heuristics
    n = 8
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_9_by_heuristics
    n = 9
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff Manpage/*"),
      "Roff" =>  all_fixtures("Roff") + Dir.glob("#{fixtures_path}/Generic/#{n}/Roff/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/#{n}/nil/*")
    }, alt_name="man.#{n}")
  end

  def test_al_by_heuristics
    assert_heuristics({
      "AL" => all_fixtures("AL", "*.al"),
      "Perl" => all_fixtures("Perl", "*.al")
    })
  end

  def test_app_by_heuristics
    assert_heuristics({
      "Erlang" => Dir.glob("#{fixtures_path}/Generic/app/Erlang/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/app/nil/*")
    })
  end

  def test_as_by_heuristics
    assert_heuristics({
      "ActionScript" => all_fixtures("ActionScript", "*.as"),
      nil => all_fixtures("AngelScript", "*.as")
    })
  end

  def test_asc_by_heuristics
    assert_heuristics({
      "AsciiDoc" => all_fixtures("AsciiDoc"),
      "AGS Script" => all_fixtures("AGS Script"),
      "Public Key" => all_fixtures("Public Key")
    }, "test.asc")
  end

  def test_asm_by_heuristics
    assert_heuristics({
      "Motorola 68K Assembly" => all_fixtures("Motorola 68K Assembly", "*.asm"),
      "Assembly" => all_fixtures("Assembly", "*.asm")
    })
  end

  def test_asy_by_heuristics
    assert_heuristics({
      "Asymptote" => all_fixtures("Asymptote", "*.asy"),
      "LTspice Symbol" => all_fixtures("LTspice Symbol", "*.asy")
    })
  end

  def test_bas_by_heuristics
    assert_heuristics({
      "B4X" => all_fixtures("B4X", "*.bas"),
      "FreeBASIC" => all_fixtures("FreeBASIC", "*.bas"),
      "BASIC" => all_fixtures("BASIC", "*.bas"),
      "VBA" => all_fixtures("VBA", "*.bas"),
      "Visual Basic 6.0" => all_fixtures("Visual Basic 6.0", "*.bas"),
      "QuickBASIC" => all_fixtures("QuickBASIC", "*.bas")
    })
  end

  def test_bb_by_heuristics
    assert_heuristics({
      "BitBake" => all_fixtures("BitBake", "*.bb"),
      "BlitzBasic" => all_fixtures("BlitzBasic", "*.bb")
    })
  end

  def test_bf_by_heuristics
    assert_heuristics({
      "Beef" => all_fixtures("Beef", "*.bf"),
      "Brainfuck" => all_fixtures("Brainfuck", "*.bf"),
      "HyPhy" => all_fixtures("HyPhy", "*.bf"),
      nil => all_fixtures("Befunge", "*.bf"),
    })
  end

  def test_bi_by_heuristics
    assert_heuristics({
      "FreeBASIC" => all_fixtures("FreeBASIC", "*.bi")
    })
  end

  def test_bs_by_heuristics
    assert_heuristics({
      "BrighterScript" => all_fixtures("BrighterScript", "*.bs"),
      "Bikeshed" => all_fixtures("Bikeshed", "*.bs")
    })
  end

  def test_bst_by_heuristics
    assert_heuristics({
      "BibTeX Style" => all_fixtures("BibTeX Style", "*.bst"),
      "BuildStream" => all_fixtures("BuildStream", "*.bst")
    })
  end

  def test_builds_by_heuristics
    assert_heuristics({
      nil => all_fixtures("Text"),
      "XML" => all_fixtures("XML", "*.builds")
    }, "test.builds")
  end

  def test_cairo_by_heuristics
    assert_heuristics({
      "Cairo Zero" => all_fixtures("Cairo Zero"),
      "Cairo" => all_fixtures("Cairo")
    })
  end

  def test_ch_by_heuristics
    assert_heuristics({
      "xBase" => all_fixtures("xBase", "*.ch"),
      # Missing heuristic for Charity
      nil => all_fixtures("Charity", "*.ch")
    })
  end

  def test_cl_by_heuristics
    assert_heuristics({
      "Common Lisp" => all_fixtures("Common Lisp", "*.cl"),
      "OpenCL" => all_fixtures("OpenCL", "*.cl")
    })
  end

  def test_cls_by_heuristics
    assert_heuristics({
      "Visual Basic 6.0" => all_fixtures("Visual Basic 6.0", "*.cls"),
      "VBA" => all_fixtures("VBA", "*.cls"),
      "TeX" => all_fixtures("TeX", "*.cls"),
      "ObjectScript" => all_fixtures("ObjectScript", "*.cls"),
      # Missing heuristics
      nil => all_fixtures("Apex", "*.cls") + all_fixtures("OpenEdge ABL", "*.cls"),
    })
  end

  def test_cmp_by_heuristics
    assert_heuristics({
      "Gerber Image" => all_fixtures("Gerber Image", "*"),
      nil => all_fixtures("Text", "*"),
    }, alt_name="test.cmp")
    assert_heuristics({
      "Gerber Image" => Dir.glob("#{fixtures_path}/Generic/cmp/Gerber Image/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/cmp/nil/*"),
    })
  end

  def test_cs_by_heuristics
    assert_heuristics({
      "C#" => all_fixtures("C#", "*.cs"),
      "Smalltalk" => all_fixtures("Smalltalk", "*.cs")
    })
  end

  def test_csc_by_heuristics
    assert_heuristics({
      "GSC" => all_fixtures("GSC", "*.csc")
    })
  end

  def test_csl_by_heuristics
    assert_heuristics({
      "Kusto" => all_fixtures("Kusto", "*.csl"),
      "XML" => all_fixtures("XML", "*.csl")
    })
  end

  def test_d_by_heuristics
    assert_heuristics({
      "D" => all_fixtures("D", "*.d"),
      "DTrace" => all_fixtures("DTrace", "*.d"),
      "Makefile" => all_fixtures("Makefile", "*.d"),
    }, "test.d")
  end

  def test_dsp_by_heuristics
    assert_heuristics({
      "Faust" => all_fixtures("Faust", "*.dsp"),
      "Microsoft Developer Studio Project" => all_fixtures("Microsoft Developer Studio Project"),
    })
  end

  def test_e_by_heuristics
    assert_heuristics({
      "E" => all_fixtures("E", "*.E"),
      "Eiffel" => all_fixtures("Eiffel", "*.e"),
      "Euphoria" => all_fixtures("Euphoria", "*.e")
    })
  end

  def test_ecl_by_heuristics
    assert_heuristics({
      "ECL" => all_fixtures("ECL", "*.ecl"),
      "ECLiPSe" => all_fixtures("ECLiPSe", "*.ecl")
    })
  end

  def test_es_by_heuristics
    assert_heuristics({
      "Erlang" => all_fixtures("Erlang", "*.es"),
      "JavaScript" => all_fixtures("JavaScript", "*.es")
    })
  end

  def test_ex_by_heuristics
    assert_heuristics({
      "Elixir" => all_fixtures("Elixir", "*.ex"),
      "Euphoria" => all_fixtures("Euphoria", "*.ex")
    })
  end

  def test_f_by_heuristics
    assert_heuristics({
      "Fortran" => all_fixtures("Fortran", "*.f") + all_fixtures("Fortran", "*.for"),
      "Forth" => all_fixtures("Forth", "*.f") + all_fixtures("Forth", "*.for")
    }, alt_name="main.f")
  end

  def test_for_by_heuristics
    assert_heuristics({
      "Fortran" => all_fixtures("Fortran", "*.f") + all_fixtures("Fortran", "*.for"),
      "Forth" => all_fixtures("Forth", "*.f") + all_fixtures("Forth", "*.for"),
      nil => all_fixtures("Formatted", "*.for")
    }, alt_name="main.for")
  end

  def test_fr_by_heuristics
    assert_heuristics({
      "Frege" => all_fixtures("Frege", "*.fr"),
      "Forth" => all_fixtures("Forth", "*.fr"),
      "Text" => all_fixtures("Text", "*.fr")
    })
  end

  def test_frm_by_heuristics
    assert_heuristics({
      "VBA" => all_fixtures("VBA", "*.frm"),
      "Visual Basic 6.0" => all_fixtures("Visual Basic 6.0", "*.frm"),
      "INI" => all_fixtures("INI", "*.frm"),
    })
  end

  def test_fs_by_heuristics
    assert_heuristics({
      "F#" => all_fixtures("F#", "*.fs"),
      "Forth" => all_fixtures("Forth", "*.fs"),
      "GLSL" => all_fixtures("GLSL", "*.fs")
    })
  end

  def test_ftl_by_heuristics
    assert_heuristics({
      "Fluent" => all_fixtures("Fluent", "*.ftl"),
      "FreeMarker" => all_fixtures("FreeMarker", "*.ftl")
    }, alt_name="main.ftl")
  end

  def test_g_by_heuristics
    assert_heuristics({
      "GAP" => all_fixtures("GAP", "*.g*"),
      "G-code" => all_fixtures("G-code", "*.g")
    }, alt_name="test.g")
  end

  def test_gd_by_heuristics
    assert_heuristics({
      "GAP" => all_fixtures("GAP", "*.gd"),
      "GDScript" => all_fixtures("GDScript", "*.gd")
    })
  end

  def test_gml_by_heuristics
      assert_heuristics({
        "Game Maker Language" => all_fixtures("Game Maker Language", "*.gml"),
        "Graph Modeling Language" => all_fixtures("Graph Modeling Language", "*.gml"),
        "XML" => all_fixtures("XML", "*.gml")
      })
  end

  def test_gs_by_heuristics
    ambiguous = [
      "#{samples_path}/Genie/Class.gs",
      "#{samples_path}/Genie/Hello.gs",
    ]
    assert_heuristics({
      "GLSL" => all_fixtures("GLSL", "*.gs"),
      "Genie" => all_fixtures("Genie", "*.gs") - ambiguous,
      "Gosu" => all_fixtures("Gosu", "*.gs"),
    })
    assert_heuristics({
      nil => all_fixtures("JavaScript")
    }, alt_name="test.gs")
  end

  def test_gsc_by_heuristics
    assert_heuristics({
      "GSC" => all_fixtures("GSC", "*.gsc")
    })
  end

  def test_gsh_by_heuristics
    assert_heuristics({
      "GSC" => all_fixtures("GSC", "*.gsh")
    })
  end

  def test_gts_by_heuristics
    assert_heuristics({
      "Gerber Image" => all_fixtures("Gerber Image", "*.gts"),
      "Glimmer TS" => all_fixtures("Glimmer TS", "*.gts"),
    })
  end

  def test_h_by_heuristics
    assert_heuristics({
      "Objective-C" => all_fixtures("Objective-C", "*.h"),
      "C++" => all_fixtures("C++", "*.h"),
      # Default to C if the content is ambiguous
      "C" => all_fixtures("C", "*.h")
    })
  end

  def test_hh_by_heuristics
    assert_heuristics({
      "Hack" => all_fixtures("Hack", "*.hh"),
      nil => all_fixtures("C++", "*.hh")
    })
  end

  def test_html_by_heuristics
    assert_heuristics({
      "Ecmarkup" => all_fixtures("Ecmarkup", "*.html"),
      "HTML" => all_fixtures("HTML", "*.html")
    })
  end

  def test_i_by_heuristics
    assert_heuristics({
      "Motorola 68K Assembly" => all_fixtures("Motorola 68K Assembly", "*.i"),
      "SWIG" => all_fixtures("SWIG", "*.i"),
      "Assembly" => all_fixtures("Assembly", "*.i")
    })
  end

  def test_ice_by_heuristics
    assert_heuristics({
      "Slice" => all_fixtures("Slice", "*.ice"),
      "JSON" => all_fixtures("JSON", "*.ice")
    })
  end

  def test_inc_by_heuristics
    assert_heuristics({
      "Motorola 68K Assembly" => all_fixtures("Motorola 68K Assembly", "*.inc"),
      "NASL" => all_fixtures("NASL", "*.inc"),
      "Pascal" => all_fixtures("Pascal", "*.inc"),
      "PHP" => all_fixtures("PHP", "*.inc"),
      "POV-Ray SDL" => all_fixtures("POV-Ray SDL", "*.inc"),
      "SourcePawn" => all_fixtures("SourcePawn", "*.inc"),
      "Assembly" => all_fixtures("Assembly", "*.inc"),
      nil => all_fixtures("C++", "*.inc") +
        all_fixtures("HTML", "*.inc") +
        all_fixtures("Pawn", "*.inc") +
        all_fixtures("SQL", "*.inc")
    }, alt_name="foo.inc")
  end

  def test_json_by_heuristics
    assert_heuristics({
      "OASv2-json" => all_fixtures("OASv2-json", "*.json"),
      "OASv3-json" => all_fixtures("OASv3-json", "*.json"),
      "JSON" => all_fixtures("JSON", "*.json"),
    })
  end

  def test_l_by_heuristics
    assert_heuristics({
      "Common Lisp" => all_fixtures("Common Lisp", "*.l"),
      "Lex" => all_fixtures("Lex", "*.l"),
      "Roff" => all_fixtures("Roff", "*.l"),
      "PicoLisp" => all_fixtures("PicoLisp", "*.l")
    })
  end

  def test_lean_by_heuristics
    assert_heuristics({
      "Lean" => all_fixtures("Lean", "*.lean"),
      "Lean 4" => all_fixtures("Lean 4", "*.lean")
    })
  end

  def test_lisp_by_heuristics
    assert_heuristics({
      "Common Lisp" => all_fixtures("Common Lisp", "*.lisp") + all_fixtures("Common Lisp", "*.lsp"),
      "NewLisp" => all_fixtures("NewLisp", "*.lisp") + all_fixtures("NewLisp", "*.lsp")
    }, "main.lisp")
  end

  def test_lp_by_heuristics
    assert_heuristics({
      "Answer Set Programming" => all_fixtures("Answer Set Programming", "*.lp"),
      "Linear Programming" => all_fixtures("Linear Programming", "*.lp")
    })
  end

  def test_ls_by_heuristics
    assert_heuristics({
      "LiveScript" => all_fixtures("LiveScript", "*.ls"),
      "LoomScript" => all_fixtures("LoomScript", "*.ls")
    })
  end

  def test_lsp_by_heuristics
    assert_heuristics({
      "Common Lisp" => all_fixtures("Common Lisp", "*.lisp") + all_fixtures("Common Lisp", "*.lsp"),
      "NewLisp" => all_fixtures("NewLisp", "*.lisp") + all_fixtures("NewLisp", "*.lsp")
    }, "main.lsp")
  end

  def test_m4_by_heuristics
    assert_heuristics({
      "M4" => all_fixtures("M4", "*.m4"),
      "M4Sugar" => all_fixtures("M4Sugar", "*.m4")
    })
  end

  def test_m_by_heuristics
    ambiguous = all_fixtures("Objective-C", "cocoa_monitor.m")
    assert_heuristics({
      "Objective-C" => all_fixtures("Objective-C", "*.m") - ambiguous,
      "Mercury" => all_fixtures("Mercury", "*.m"),
      "MUF" => all_fixtures("MUF", "*.m"),
      "M" => all_fixtures("M", "MDB.m"),
      "Mathematica" => all_fixtures("Mathematica", "*.m") - all_fixtures("Mathematica", "Problem12.m"),
      "MATLAB" => all_fixtures("MATLAB", "create_ieee_paper_plots.m"),
      "Limbo" => all_fixtures("Limbo", "*.m"),
      nil => ambiguous
    })
  end

  def test_man_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" => all_fixtures("Roff")
    }, alt_name="man.man")
  end

  def test_mask_by_heuristics
    assert_heuristics({
      "Unity3D Asset" => all_fixtures("Unity3D Asset", "*.mask")
    })
  end

  def test_mc_by_heuristics
    assert_heuristics({
      "Monkey C" => all_fixtures("Monkey C", "*.mc"),
      "Win32 Message File" => all_fixtures("Win32 Message File", "*.mc")
    })
  end

  def test_md_by_heuristics
    assert_heuristics({
      "Markdown" => all_fixtures("Markdown", "*.md"),
      "GCC Machine Description" => all_fixtures("GCC Machine Description", "*.md")
    })
  end

  def test_mdoc_by_heuristics
    assert_heuristics({
      "Roff Manpage" => all_fixtures("Roff Manpage"),
      "Roff" =>  all_fixtures("Roff")
    }, alt_name="man.mdoc")
  end

  def test_ml_by_heuristics
    ambiguous = [
      "#{samples_path}/OCaml/date.ml",
      "#{samples_path}/OCaml/common.ml",
      "#{samples_path}/OCaml/sigset.ml",
      "#{samples_path}/Standard ML/Foo.sig",
    ]
    assert_heuristics({
      "OCaml" => all_fixtures("OCaml") - ambiguous,
      "Standard ML" => all_fixtures("Standard ML") - ambiguous,
      nil => ambiguous
    }, "test.ml")
  end

  def test_mod_by_heuristics
    assert_heuristics({
      "Modula-2" => all_fixtures("Modula-2", "*.mod"),
      "NMODL" => all_fixtures("NMODL", "*.mod"),
      "XML" => all_fixtures("XML", "*.mod"),
      ["Linux Kernel Module", "AMPL"] => all_fixtures("Linux Kernel Module", "*.mod"),
      ["Linux Kernel Module", "AMPL"] => all_fixtures("AMPL", "*.mod"),
    })
  end

  def test_mojo_by_heuristics
    assert_heuristics({
      "Mojo" => all_fixtures("Mojo", "*.mojo"),
      "XML" => all_fixtures("XML", "*.mojo"),
    })
  end

  def test_ms_by_heuristics
    assert_heuristics({
      "Roff" => all_fixtures("Roff", "*.ms"),
      "Unix Assembly" => all_fixtures("Unix Assembly", "*.ms"),
      "MAXScript" => all_fixtures("MAXScript", "*.ms")
    })
  end

  def test_msg_by_heuristics
    assert_heuristics({
      "OMNeT++ MSG" => all_fixtures("OMNeT++ MSG", "*.msg"),
    })
  end

  def test_n_by_heuristics
    assert_heuristics({
      "Roff" => all_fixtures("Roff", "*.n"),
      "Nemerle" => all_fixtures("Nemerle", "*.n")
    })
  end

  def test_ncl_by_heuristics
    assert_heuristics({
      "Gerber Image" => all_fixtures("Gerber Image", "*"),
      "XML" => all_fixtures("XML", "*.ncl"),
      "Text" => all_fixtures("Text", "*.ncl"),
      "Nickel" => all_fixtures("Nickel", "*.ncl"),
      "NCL" => all_fixtures("NCL", "*.ncl")
    }, alt_name="test.ncl")
  end

  def test_nl_by_heuristics
    assert_heuristics({
      "NewLisp" => all_fixtures("NewLisp", "*.nl"),
      "NL" => all_fixtures("NL", "*.nl")
    })
  end

  def test_nr_by_heuristics
    assert_heuristics({
      "Noir" => all_fixtures("Noir", "*.nr"),
      "Roff" => all_fixtures("Roff", "*.nr")
    })
  end

  def test_nu_by_heuristics
    assert_heuristics({
      "Nushell" => all_fixtures("Nushell", "*.nu"),
      "Nu" => all_fixtures("Nu", "*.nu")
    })
  end

  def test_odin_by_heuristics
    assert_heuristics({
      "Object Data Instance Notation" => all_fixtures("Object Data Instance Notation", "*.odin"),
      "Odin" => all_fixtures("Odin", "*.odin")
    })
  end

  def test_p_by_heuristics
    assert_heuristics({
      "Gnuplot" => all_fixtures("Gnuplot"),
      "OpenEdge ABL" => all_fixtures("OpenEdge ABL")
    }, alt_name="test.p")
  end

  def test_php_by_heuristics
    assert_heuristics({
      "Hack" => all_fixtures("Hack", "*.php"),
      "PHP" => all_fixtures("PHP", "*.php")
    })
  end

  def test_pkl_by_heuristics
    assert_heuristics({
      "Pkl" => all_fixtures("Pkl", "*.pkl"),
      "Pickle" => all_fixtures("Pickle", "*.pkl")
    })
  end

  def test_pl_by_heuristics
    assert_heuristics({
      "Prolog" => all_fixtures("Prolog", "*.pl"),
      "Perl" => ["Perl/oo1.pl", "Perl/oo2.pl", "Perl/oo3.pl", "Perl/fib.pl", "Perl/use5.pl"],
      "Raku" => all_fixtures("Raku", "*.pl")
    })
  end

  def test_plist_by_heuristics
    assert_heuristics({
      "OpenStep Property List" => all_fixtures("OpenStep Property List", "*.plist"),
      "XML Property List" => all_fixtures("XML Property List", "*.plist")
    })
  end

  def test_plt_by_heuristics
    assert_heuristics({
      "Prolog" => all_fixtures("Prolog", "*.plt"),
      # Gnuplot lacks a heuristic
      nil => all_fixtures("Gnuplot", "*.plt")
    })
  end

  def test_pm_by_heuristics
    assert_heuristics({
      "Perl" => all_fixtures("Perl", "*.pm"),
      "Raku" => all_fixtures("Raku", "*.pm"),
      "X PixMap" => all_fixtures("X PixMap")
    }, "test.pm")
  end

  def test_pod_by_heuristics
    assert_heuristics({
      "Pod" => all_fixtures("Pod", "*.pod"),
      "Pod 6" => all_fixtures("Pod 6", "*.pod")
    })
  end

  def test_pp_by_heuristics
    assert_heuristics({
      "Pascal" => all_fixtures("Pascal", "*.pp"),
      "Puppet" => all_fixtures("Puppet", "*.pp") - ["#{samples_path}/Puppet/stages-example.pp", "#{samples_path}/Puppet/hiera_include.pp"]
    })
  end

  def test_pro_by_heuristics
    assert_heuristics({
      "Proguard" => all_fixtures("Proguard", "*.pro"),
      "Prolog" => all_fixtures("Prolog", "*.pro"),
      "IDL" => all_fixtures("IDL", "*.pro"),
      "INI" => all_fixtures("INI", "*.pro"),
      "QMake" => all_fixtures("QMake", "*.pro")
    })
  end

  def test_properties_by_heuristics
    assert_heuristics({
      "INI" => all_fixtures("INI", "*.properties"),
      "Java Properties" => all_fixtures("Java Properties", "*.properties")
    })
  end

  def test_q_by_heuristics
    assert_heuristics({
      "q" => all_fixtures("q", "*.q"),
      "HiveQL" => all_fixtures("HiveQL", "*.q")
    })
  end

  def test_qs_by_heuristics
    assert_heuristics({
      "Q#" => all_fixtures("Q#", "*.qs"),
      "Qt Script" => all_fixtures("Qt Script", "*.qs")
    })
  end

  def test_r_by_heuristics
    assert_heuristics({
      "R" => all_fixtures("R", "*.r") + all_fixtures("R", "*.R"),
      "Rebol" => all_fixtures("Rebol", "*.r")
    })
  end

  def test_re_by_heuristics
    assert_heuristics({
      "C++" => all_fixtures("C++", "*.re"),
      "Reason" => all_fixtures("Reason", "*.re")
    })
  end

  def test_res_by_heuristics
    assert_heuristics({
      "ReScript" => all_fixtures("ReScript", "*.res"),
      nil => all_fixtures("XML", "*.res")
    })
  end

  def test_resource_by_heuristics
    assert_heuristics({
      "RobotFramework" => all_fixtures("RobotFramework", "*.resource")
    })
  end

  def test_rno_by_heuristics
    assert_heuristics({
      "RUNOFF" => all_fixtures("RUNOFF", "*.rno"),
      "Roff" => all_fixtures("Roff", "*.rno")
    })
  end

  def test_rpy_by_heuristics
    assert_heuristics({
      "Python" => all_fixtures("Python", "*.rpy"),
      "Ren'Py" => all_fixtures("Ren'Py", "*.rpy")
    })
  end

  def test_rs_by_heuristics
    assert_heuristics({
      "Rust" => all_fixtures("Rust", "*.rs"),
      "RenderScript" => all_fixtures("RenderScript", "*.rs")
    })
  end

  def test_s_by_heuristics
    assert_heuristics({
      "Motorola 68K Assembly" => all_fixtures("Motorola 68K Assembly", "*.s"),
      "Assembly" => all_fixtures("Assembly", "*.s"),
      "Unix Assembly" => all_fixtures("Unix Assembly", "*.s")
    })
  end

  def test_sc_by_heuristics
    assert_heuristics({
      "SuperCollider" => all_fixtures("SuperCollider", "*.sc"),
      "Scala" => all_fixtures("Scala", "*.sc")
    })
  end

  def test_scd_by_heuristics
    assert_heuristics({
      "SuperCollider" => all_fixtures("SuperCollider", "*"),
      "Markdown" => all_fixtures("Markdown", "*.scd")
    }, alt_name="test.scd")
  end

  def test_scm_by_heuristics
    assert_heuristics({
      "Scheme" => all_fixtures("Scheme", "*.scm"),
      "Tree-sitter Query" => all_fixtures("Tree-sitter Query", "*.scm")
    })
  end

  def test_sol_by_heuristics
    assert_heuristics({
      "Gerber Image" => Dir.glob("#{fixtures_path}/Generic/sol/Gerber Image/*"),
      "Solidity" => Dir.glob("#{fixtures_path}/Generic/sol/Solidity/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/sol/nil/*")
    })
  end

  def test_sql_by_heuristics
    assert_heuristics({
      "SQL" => ["SQL/create_stuff.sql", "SQL/db.sql", "SQL/dual.sql"],
      "PLpgSQL" => all_fixtures("PLpgSQL", "*.sql"),
      "SQLPL" => ["SQLPL/trigger.sql"],
      "PLSQL" => all_fixtures("PLSQL", "*.sql")
    })
  end

  def test_srt_by_heuristics
    assert_heuristics({
      "SubRip Text" => all_fixtures("SubRip Text", "*.srt")
    })
  end

  def test_st_by_heuristics
    assert_heuristics({
      "StringTemplate" => all_fixtures("StringTemplate", "*.st"),
      "Smalltalk" => all_fixtures("Smalltalk", "*.st")
    })
  end

  def test_star_by_heuristics
    assert_heuristics({
      "STAR" => all_fixtures("STAR", "*.star"),
      "Starlark" => all_fixtures("Starlark", "*.star")
    })
  end

  def test_stl_by_heuristics
    assert_heuristics({
      "STL" => Dir.glob("#{fixtures_path}/Generic/stl/STL/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/stl/nil/*")
    })
  end

  def test_svx_by_heuristics
    assert_heuristics({
      "Survex data" => all_fixtures("Survex data", "*.svx"),
      "mdsvex" => all_fixtures("mdsvex", "*.svx")
    })
  end

  def test_sw_by_heuristics
    assert_heuristics({
      "Sway" => all_fixtures("Sway", "*.sw"),
      "XML" => all_fixtures("XML", "*.sw")
    })
  end

  def test_t_by_heuristics
    # Turing not fully covered.
    assert_heuristics({
      "Turing" => all_fixtures("Turing", "*.t"),
      "Perl" => all_fixtures("Perl", "*.t"),
      "Raku" => ["Raku/01-dash-uppercase-i.t", "Raku/01-parse.t", "Raku/advent2009-day16.t",
                 "Raku/basic-open.t", "Raku/calendar.t", "Raku/for.t", "Raku/hash.t",
                 "Raku/listquote-whitespace.t"]
    })
  end

  def test_tact_by_heuristics
    assert_heuristics({
      "Tact" => all_fixtures("Tact", "*.tact"),
      "JSON" => all_fixtures("JSON", "*.tact"),
    })
  end

  def test_tag_by_heuristics
    assert_heuristics({
      "Java Server Pages" => Dir.glob("#{fixtures_path}/Generic/tag/Java Server Pages/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/tag/nil/*")
    })
  end

  def test_tlv_by_heuristics
    assert_heuristics({
      "TL-Verilog" => all_fixtures("TL-Verilog", "*.tlv"),
    })
  end

  def test_toc_by_heuristics
    assert_heuristics({
      "TeX" => all_fixtures("TeX", "*.toc"),
      "World of Warcraft Addon Data" => all_fixtures("World of Warcraft Addon Data", "*.toc")
    })
  end

  def test_ts_by_heuristics
    assert_heuristics({
      "TypeScript" => all_fixtures("TypeScript", "*.ts"),
      "XML" => all_fixtures("XML", "*.ts")
    })
  end

  def test_tsp_by_heuristics
    assert_heuristics({
      "TypeSpec" => all_fixtures("TypeSpec", "*.tsp"),
      "TSPLIB data" => all_fixtures("TSPLIB data", "*.tsp")
    })
  end

  def test_tst_by_heuristics
    assert_heuristics({
      "GAP" => all_fixtures("GAP", "*.tst"),
      "Scilab" => all_fixtures("Scilab", "*.tst")
    })
  end

  def test_tsx_by_heuristics
    assert_heuristics({
      "TSX" => all_fixtures("TSX", "*.tsx"),
      "XML" => all_fixtures("XML", "*.tsx")
    })
  end

  def test_txt_by_heuristics
    assert_heuristics({
      "Adblock Filter List" => all_fixtures("Adblock Filter List", "*.txt"),
      "Vim Help File" => all_fixtures("Vim Help File", "*.txt"),
      "Text" => all_fixtures("Text", "*.txt")
    })
  end

  def test_typ_by_heuristics
    assert_heuristics({
      "Typst" => all_fixtures("Typst", "*.typ"),
      "XML" => all_fixtures("XML", "*.typ")
    })
  end

  def test_url_by_heuristics
    assert_heuristics({
      "INI" => Dir.glob("#{fixtures_path}/Generic/url/INI/*"),
      nil => Dir.glob("#{fixtures_path}/Generic/url/nil/*")
    })
  end

  def test_v_by_heuristics
    assert_heuristics({
      "Rocq Prover" => all_fixtures("Rocq Prover", "*.v"),
      "V" => all_fixtures("V", "*.v"),
      "Verilog" => all_fixtures("Verilog", "*.v")
    })
  end

  def test_vba_by_heuristics
    assert_heuristics({
      "VBA" => all_fixtures("VBA", "*.vba"),
      "Vim Script" => all_fixtures("Vim Script", "*.vba")
    })
  end

  def test_vcf_by_heuristics
    assert_heuristics({
      "TSV" => all_fixtures("TSV", "*.vcf"),
      "vCard" => all_fixtures("vCard", "*.vcf")
    })
  end

  def test_w_by_heuristics
    assert_heuristics({
      "CWeb" => all_fixtures("CWeb", "*.w"),
      "OpenEdge ABL" => all_fixtures("OpenEdge ABL", "*.w")
    })
  end

  def test_x_by_heuristics
    # Logos not fully covered
    assert_heuristics({
      "DirectX 3D File" => all_fixtures("DirectX 3D File", "*.x"),
      "Linker Script" => all_fixtures("Linker Script", "*.x"),
      "RPC" => all_fixtures("RPC", "*.x")
    })
  end

  def test_yaml_by_heuristics
    assert_heuristics({
      "MiniYAML" => all_fixtures("MiniYAML", "*.yaml"),
      "OASv2-yaml" => all_fixtures("OASv2-yaml", "*.yaml"),
      "OASv3-yaml" => all_fixtures("OASv3-yaml", "*.yaml"),
      "YAML" => all_fixtures("YAML", "*.yaml"),
    })
  end

  def test_yml_by_heuristics
    assert_heuristics({
      "MiniYAML" => all_fixtures("MiniYAML", "*.yml"),
      "OASv2-yaml" => all_fixtures("OASv2-yaml", "*.yml"),
      "OASv3-yaml" => all_fixtures("OASv3-yaml", "*.yml"),
      "YAML" => all_fixtures("YAML", "*.yml"),
    })
  end

  def test_yy_by_heuristics
    assert_heuristics({
      "JSON" => all_fixtures("JSON", "*.yy"),
      "Yacc" => all_fixtures("Yacc", "*.yy")
    })
  end
end
