//
//  ScintillaBridge.mm
//  NotepadMac
//

#import "ScintillaBridge.h"
#include "ILexer.h"

extern "C" Scintilla::ILexer5 *CreateLexer(const char *name);

void *ScintillaCreateLexer(const char *name) {
    if (!name) return nullptr;
    return (void *)CreateLexer(name);
}

void ScintillaSetLexer(ScintillaView *view, const char *lexerName) {
    if (!view || !lexerName) return;
    Scintilla::ILexer5 *lexer = CreateLexer(lexerName);
    if (lexer) {
        [view message:SCI_SETILEXER wParam:0 lParam:(sptr_t)lexer];
    }
}
