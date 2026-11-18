/*
 *
 * This file is part of NotepadMac.
 *
 * Copyright 2025-2026 Harry Dertin Sutisna Alsyundawy <alsyundawy@gmail.com>
 * https://github.com/alsyundawy/NotepadMac
 * ALSYUNDAWY IT SOLUTION <https://alsyundawy.com>
 *
 * NotepadMac is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * NotepadMac is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with NotepadMac.  If not, see <https://www.gnu.org/licenses/>.
 */

import Foundation

extension LexerRegistry {
    static let extendedLanguages: [LanguageDefinition] = [
        langAda, langAsm, langCobol, langCoffeeScript, langD,
        langDart, langDockerfile, langErlang, langFortran, langFsharp,
        langGdscript, langHaskell, langJulia, langKotlin, langLatex,
        langLisp, langMatlab, langNim, langNix, langOcaml,
        langPascal, langR, langScala, langTcl, langVerilog,
        langVhdl, langVb
    ]

    static let langAda = LanguageDefinition(
        id: "ada",
        displayName: "Ada",
        lexerID: "ada",
        fileExtensions: ["ada", "adb", "ads"],
        keywords: (
            "abort abs abstract accept access aliased all and array at begin " +
            "body case constant declare delay delta digits do else elsif end " +
            "entry exception exit for function generic goto if in interface " +
            "is limited loop mod new not null of or others out overriding " +
            "package pragma private procedure protected raise range record " +
            "rem renames requeue return reverse select separate some subtype " +
            "synchronized tagged task terminate then type until use when " +
            "while with xor"
        ),
        isFoldable: true
    )

    static let langAsm = LanguageDefinition(
        id: "asm",
        displayName: "Assembly (x86/x64/ARM)",
        lexerID: "asm",
        fileExtensions: ["asm", "s", "inc"],
        keywords: (
            "mov push pop add sub mul div jmp je jne jz jnz call ret cmp " +
            "test lea nop int and or xor not shl shr ror rol section segment " +
            "global extern byte word dword qword ptr equ org"
        ),
        isFoldable: false
    )

    static let langCobol = LanguageDefinition(
        id: "cobol",
        displayName: "COBOL",
        lexerID: "cobol",
        fileExtensions: ["cbl", "cob", "cpy"],
        keywords: (
            "identification division environment data procedure program-id " +
            "working-storage section pic value display accept stop run if " +
            "else perform until move add to compute evaluate when end-if"
        ),
        isFoldable: true
    )

    static let langCoffeeScript = LanguageDefinition(
        id: "coffeescript",
        displayName: "CoffeeScript",
        lexerID: "coffeescript",
        fileExtensions: ["coffee", "litcoffee"],
        keywords: (
            "and break by catch class continue default delete do else extend " +
            "finally for if in instanceof is isn't loop new no not of off on " +
            "or return super switch then this throw true try typeof unless " +
            "until when while yes"
        ),
        isFoldable: true
    )

    static let langD = LanguageDefinition(
        id: "d",
        displayName: "D",
        lexerID: "d",
        fileExtensions: ["d", "di"],
        keywords: (
            "abstract alias align asm assert auto bool break byte case cast " +
            "catch char class const continue debug default delegate delete " +
            "deprecated do double else enum export extern false final " +
            "finally float for foreach foreach_reverse function goto if " +
            "immutable import in inout int interface invariant is lazy " +
            "long mixin module new nothrow null out override package " +
            "pragma private protected public pure real ref return scope " +
            "shared short static struct super switch synchronized template " +
            "this throw true try typedef typeid typeof ubyte uint ulong " +
            "union unittest ushort version void volatile wchar while with"
        ),
        isFoldable: true
    )

    static let langDart = LanguageDefinition(
        id: "dart",
        displayName: "Dart",
        lexerID: "dart",
        fileExtensions: ["dart"],
        keywords: (
            "abstract as assert async await break case catch class const " +
            "continue covariant default deferred do dynamic else enum export " +
            "extends extension external factory false final finally for " +
            "Function get hide if implements import in inout interface is " +
            "late library mixin new null of on operator part required " +
            "rethrow return set show static super switch sync this throw " +
            "true try typedef var void while with yield"
        ),
        isFoldable: true
    )

    static let langDockerfile = LanguageDefinition(
        id: "dockerfile",
        displayName: "Dockerfile",
        lexerID: "bash",
        fileExtensions: ["dockerfile", "containerfile"],
        keywords: (
            "FROM MAINTAINER RUN CMD EXPOSE ENV ADD COPY ENTRYPOINT " +
            "VOLUME USER WORKDIR ARG ONBUILD STOPSIGNAL HEALTHCHECK SHELL"
        ),
        isFoldable: false
    )

    static let langErlang = LanguageDefinition(
        id: "erlang",
        displayName: "Erlang",
        lexerID: "erlang",
        fileExtensions: ["erl", "hrl"],
        keywords: (
            "after and andalso band bnot bor bsl bsr bxor case catch cond " +
            "div end fun if not of or orelse query receive rem try when xor"
        ),
        isFoldable: true
    )

    static let langFortran = LanguageDefinition(
        id: "fortran",
        displayName: "Fortran",
        lexerID: "fortran",
        fileExtensions: ["f", "for", "f90", "f95", "f03", "f08"],
        keywords: (
            "program module subroutine function end use implicit none integer " +
            "real double precision character logical if then else elseif " +
            "do while select case default allocate deallocate call return"
        ),
        isFoldable: true
    )

    static let langFsharp = LanguageDefinition(
        id: "fsharp",
        displayName: "F#",
        lexerID: "fsharp",
        fileExtensions: ["fs", "fsi", "fsx"],
        keywords: (
            "abstract and as assert base begin class default delegate do " +
            "done downcast downto elif else end exception extern false " +
            "finally for fun function if in inherit inline interface " +
            "internal lazy let match member module mutable namespace new " +
            "null of open or override private public rec return static " +
            "struct then to true try type upcast use val void when while " +
            "with yield"
        ),
        isFoldable: true
    )

    static let langGdscript = LanguageDefinition(
        id: "gdscript",
        displayName: "GDScript (Godot)",
        lexerID: "python",
        fileExtensions: ["gd"],
        keywords: (
            "if elif else for while match break continue pass return func " +
            "class class_name extends is as self tool signal enum const var " +
            "onready export setget breakpoint yield preload assert void"
        ),
        isFoldable: true
    )

    static let langHaskell = LanguageDefinition(
        id: "haskell",
        displayName: "Haskell",
        lexerID: "haskell",
        fileExtensions: ["hs", "lhs"],
        keywords: (
            "case class data default deriving do else if import in infix " +
            "infixl infixr instance let module newtype of then type where"
        ),
        isFoldable: true
    )

    static let langJulia = LanguageDefinition(
        id: "julia",
        displayName: "Julia",
        lexerID: "julia",
        fileExtensions: ["jl"],
        keywords: (
            "function macro return if elseif else while for in begin end " +
            "break continue catch try finally const global local struct " +
            "module using import export where mutable abstract primitive"
        ),
        isFoldable: true
    )

    static let langKotlin = LanguageDefinition(
        id: "kotlin",
        displayName: "Kotlin",
        lexerID: "cpp",
        fileExtensions: ["kt", "kts"],
        keywords: (
            "as as? break class continue do else false for fun if in !in " +
            "interface is !is null object package return super this throw " +
            "true try typealias val var when while by catch constructor " +
            "delegate dynamic field file finally get import init open " +
            "out param property receiver set setparam value where data " +
            "enum annotation sealed companion inline override private " +
            "protected public internal suspend"
        ),
        isFoldable: true
    )

    static let langLatex = LanguageDefinition(
        id: "latex",
        displayName: "LaTeX / TeX",
        lexerID: "latex",
        fileExtensions: ["tex", "latex", "sty", "cls", "bib"],
        keywords: (
            "begin end documentclass usepackage section subsection " +
            "subsubsection paragraph label ref cite textbf textit emph " +
            "item equation align table figure"
        ),
        isFoldable: true
    )

    static let langLisp = LanguageDefinition(
        id: "lisp",
        displayName: "Common Lisp / Scheme",
        lexerID: "lisp",
        fileExtensions: ["lisp", "lsp", "cl", "scm", "ss"],
        keywords: (
            "defun defmacro lambda let let* cond if when unless case loop " +
            "setq setf progn block return-from format print list cons car cdr"
        ),
        isFoldable: true
    )

    static let langMatlab = LanguageDefinition(
        id: "matlab",
        displayName: "MATLAB / GNU Octave",
        lexerID: "matlab",
        fileExtensions: ["m", "matlab"],
        keywords: (
            "break case catch classdef continue else elseif end for function " +
            "global if otherwise parfor persistent return spmd switch try while"
        ),
        isFoldable: true
    )

    static let langNim = LanguageDefinition(
        id: "nim",
        displayName: "Nim",
        lexerID: "nim",
        fileExtensions: ["nim", "nims"],
        keywords: (
            "addr and as asm bind block break case cast concept const " +
            "continue converter defer discard distinct div do elif else " +
            "end enum except export filter finally for from func if import " +
            "in include interface is isnot iterator let macro method mixin " +
            "mod nil not notin of or out proc ptr raise ref return shl shr " +
            "static template try tuple type using var when while xor yield"
        ),
        isFoldable: true
    )

    static let langNix = LanguageDefinition(
        id: "nix",
        displayName: "Nix Expression Language",
        lexerID: "nix",
        fileExtensions: ["nix"],
        keywords: "if then else let in inherit import with assert or rec true false null",
        isFoldable: true
    )

    static let langOcaml = LanguageDefinition(
        id: "ocaml",
        displayName: "OCaml",
        lexerID: "caml",
        fileExtensions: ["ml", "mli"],
        keywords: (
            "and as assert begin class constraint do done downto else end " +
            "exception external false for fun function functor if in include " +
            "inherit initializer lazy let match method module mutable new " +
            "object of open or private rec sig struct then to true try " +
            "type val virtual when while with"
        ),
        isFoldable: true
    )

    static let langPascal = LanguageDefinition(
        id: "pascal",
        displayName: "Pascal / Delphi",
        lexerID: "pascal",
        fileExtensions: ["pas", "pp", "dpr"],
        keywords: (
            "and array asm begin case const constructor destructor div do " +
            "downto else end file for function goto if implementation in " +
            "inherited inline interface label mod nil not object of or " +
            "packed procedure program record repeat set shl shr string then " +
            "to type unit until uses var while with xor"
        ),
        isFoldable: true
    )

    static let langR = LanguageDefinition(
        id: "r",
        displayName: "R",
        lexerID: "r",
        fileExtensions: ["r", "rdata", "rds", "rda"],
        keywords: (
            "if else repeat while function for in next break TRUE FALSE " +
            "NULL Inf NaN NA NA_integer_ NA_real_ NA_complex_ NA_character_"
        ),
        isFoldable: true
    )

    static let langScala = LanguageDefinition(
        id: "scala",
        displayName: "Scala",
        lexerID: "cpp",
        fileExtensions: ["scala", "sc"],
        keywords: (
            "abstract case catch class def do else extends false final " +
            "finally for forSome if implicit import lazy match new null " +
            "object override package private protected return sealed super " +
            "this throw trait true try type val var while with yield"
        ),
        isFoldable: true
    )

    static let langTcl = LanguageDefinition(
        id: "tcl",
        displayName: "Tcl / Tk",
        lexerID: "tcl",
        fileExtensions: ["tcl", "tk"],
        keywords: (
            "after append apply array break catch cd close concat continue " +
            "eof error eval exec exit expr fblocked fconfigure fcopy file " +
            "fileevent flush for foreach format gets glob global if incr " +
            "info interp join lappend lassign lindex linsert list llength " +
            "lmap load lrange lrepeat lreplace lreverse lsearch lset lsort " +
            "namespace open package pid proc puts pwd read rename return " +
            "scan seek set socket source split string subst switch tell " +
            "time trace unknown unset update uplevel upvar variable vwait while"
        ),
        isFoldable: true
    )

    static let langVerilog = LanguageDefinition(
        id: "verilog",
        displayName: "Verilog HDL",
        lexerID: "verilog",
        fileExtensions: ["v", "vh"],
        keywords: (
            "always and assign begin buf bufif0 bufif1 case casex casez cmos " +
            "deassign default defparam disable edge else end endcase " +
            "endfunction endmodule endprimitive endspecify endtable " +
            "endtask event for force forever fork function highz0 highz1 " +
            "if initial inout input integer join large macromodule medium " +
            "module nand negedge nmos nor not notif0 notif1 or output " +
            "parameter pmos posedge primitive pulldown pullup rcmos " +
            "real realtime reg release repeat rnmos rpmos rtran rtranif0 " +
            "rtranif1 scalared small specify specparam strong0 strong1 " +
            "supply0 supply1 table task time tran tranif0 tranif1 tri " +
            "tri0 tri1 triand trior trireg vectored wait wand weak0 weak1 " +
            "while wire wor xnor xor"
        ),
        isFoldable: true
    )

    static let langVhdl = LanguageDefinition(
        id: "vhdl",
        displayName: "VHDL",
        lexerID: "vhdl",
        fileExtensions: ["vhd", "vhdl"],
        keywords: (
            "access after alias all and architecture array assert attribute " +
            "begin block body buffer bus case component configuration " +
            "constant disconnect downto else elsif end entity exit file " +
            "for function generate generic group guarded if impure in " +
            "inertial inout is label library linkage literal loop map mod " +
            "nand new next nor not null of on open or others out package " +
            "port postponed procedure process pure range record register " +
            "reject rem report return rol ror select severity signal " +
            "shared sla sll sra srl subtype then to transport type " +
            "unaffected units until use variable wait when while with xnor xor"
        ),
        isFoldable: true
    )

    static let langVb = LanguageDefinition(
        id: "vb",
        displayName: "Visual Basic (.NET / VBScript)",
        lexerID: "vb",
        fileExtensions: ["vb", "vbs", "bas"],
        keywords: (
            "AddHandler AddressOf Alias And AndAlso As Boolean ByRef Byte " +
            "ByVal Call Case Catch CBool CByte CChar CDate CDbl CDec Char " +
            "CInt Class CLng CObj Const Continue CSByte CShort CSng CStr " +
            "CType CUInt CULng CUShort Date Decimal Declare Default " +
            "Delegate Dim DirectCast Do Double Each Else ElseIf End EndIf " +
            "Enum Erase Error Event Exit False Finally For Friend Function " +
            "Get GetType Global GoSub GoTo Handles If Implements Imports " +
            "In Inherits Integer Interface Is IsNot Let Lib Like Long Loop " +
            "Me Mod Module MustInherit MustOverride MyBase MyClass " +
            "Namespace Narrowing New Next Not Nothing NotInheritable " +
            "NotOverridable Object Of On Operator Option Optional Or " +
            "OrElse Out Overloads Overridable Overrides ParamArray Partial " +
            "Private Property Protected Public RaiseEvent ReadOnly ReDim " +
            "REM RemoveHandler Resume Return SByte Select Set Shadows " +
            "Shared Short Single Static Step Stop String Structure Sub " +
            "SyncLock Then Throw To True Try TryCast TypeOf UInteger " +
            "ULong UShort Using Variant Wend When While Widening With " +
            "WithEvents WriteOnly Xor"
        ),
        isFoldable: true
    )
}
