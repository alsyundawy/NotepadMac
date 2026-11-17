//
//  ScintillaBridge.h
//  NotepadMac
//
//  Bridging header exposing ScintillaView and Lexilla to Swift.
//

#ifndef ScintillaBridge_h
#define ScintillaBridge_h

#import <Cocoa/Cocoa.h>
#include <stdint.h>
#include <stddef.h>

#import "Scintilla.h"
#import "Sci_Position.h"
#import "InfoBarCommunicator.h"
#import "ScintillaView.h"

#ifdef __cplusplus
extern "C" {
#endif

/// Instantiates a lexer from Lexilla by its canonical ID (e.g. "cpp", "python", "bash", "hypertext", "yaml", "markdown")
void * _Nullable ScintillaCreateLexer(const char * _Nonnull name);

/// Applies a lexer to a ScintillaView instance via SCI_SETILEXER
void ScintillaSetLexer(ScintillaView * _Nonnull view, const char * _Nonnull lexerName);

#ifdef __cplusplus
}
#endif

#endif /* ScintillaBridge_h */
