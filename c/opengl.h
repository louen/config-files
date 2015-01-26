/*  ========================================================================= *
 *                               opengl.h                                     *
 *             openGL helper functions and macros for C and C++               *
 *                          Valentin Roussellet                               *
 *  ========================================================================= */

// This file contains helper functions related to openGL. Works with the macros
// defined in core.h

#ifndef OPEN_GL_H_
#define OPEN_GL_H_

// GL Assert macro to wrap openGL calls and intercept errors.

#if defined CORE_DEBUG
    #define GL_ASSERT( CODE )                                   \
    MACRO_START                                                 \
        CODE;                                                   \
        GLuint error = glGetError() ;                           \
        const char* ERR_STR = (const char*)gluErrorString(err); \
        if ( UNLIKELY (err != GL_NO_ERROR )){                   \
            fprintf( stderr,                                    \
            "%s:%i (`%s;`) OpenGL error :%s\n"                  \
            __FILE__, __LINE__, #CODE, ERR_STR );               \
            BREAKPOINT(0);                                      \
        }                                                       \
    MACRO_END
#else
    #define GL_ASSERT( CODE ) CODE
#endif


#endif // OPEN_GL_H_ include guard
