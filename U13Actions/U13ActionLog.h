//
//  U13ActionLog.h
//  U13Actions
//
//  Created by Chris Wright on 13-03-19.
//  Copyright (c) 2013 Universe 13. All rights reserved.
//

// Stub macros for improved logging.  See un1v3rse/U13Log for an implementation that fits nicely with this.  If U13Log is in the prefix file, LOG_E will already be defined.

#ifndef LOG_E

#include <mach/mach_time.h>

enum {
	LOG_LEVEL_VERBOSE = 0,
	LOG_LEVEL_DEBUG,
	LOG_LEVEL_INFO,
	LOG_LEVEL_PERFORMANCE,
	LOG_LEVEL_WARNING,
	LOG_LEVEL_ERROR,
    LOG_LEVEL_COUNT,
};

static int LOG_LEVEL = LOG_LEVEL_DEBUG;

#define LOG_SET_DEBUG_BREAK_ENABLED(enabled)

#define LOG_SET_LEVEL(level) FMDB_LOG_LEVEL = level

#define LOG(level,msg) if (level >= LOG_LEVEL) { NSLog(@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, msg); }
#define LOGF(level,fmt,...) if (level >= LOG_LEVEL) { NSLog(@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:fmt, __VA_ARGS__]); }

#define LOG_E(msg) LOG(LOG_LEVEL_ERROR,msg)
#define LOG_EF(fmt,...) LOGF(LOG_LEVEL_ERROR,fmt,__VA_ARGS__)
#define LOG_W(msg) LOG(LOG_LEVEL_WARNING,msg)
#define LOG_WF(fmt,...) LOGF(LOG_LEVEL_WARNING,fmt,__VA_ARGS__)
#define LOG_I(msg) LOG(LOG_LEVEL_INFO,msg)
#define LOG_IF(fmt,...) LOGF(LOG_LEVEL_INFO,fmt,__VA_ARGS__)

#ifdef DEBUG
#define LOG_D(msg) LOG(LOG_LEVEL_DEBUG,msg)
#define LOG_DF(fmt,...) LOGF(LOG_LEVEL_DEBUG,fmt,__VA_ARGS__)
#define LOG_V(msg) LOG(LOG_LEVEL_VERBOSE,msg)
#define LOG_VF(fmt,...) LOGF(LOG_LEVEL_VERBOSE,fmt,__VA_ARGS__)
#define LOG_A(condition, msg) if (!(condition)) { LOG_E(msg) ;}
#define LOG_AF(condition, fmt,...) if (!(condition)) { LOG_EF(fmt,__VA_ARGS__); }
#else
#define LOG_D(msg)
#define LOG_DF(fmt,...)
#define LOG_V(msg)
#define LOG_VF(fmt,...)
#define LOG_A(condition, msg)
#define LOG_AF(condition, fmt,...)
#endif

typedef uint64_t LOG_T_UNITS;
#define LOG_T_TIME() mach_absolute_time()
#define LOG_T(start,msg)
#define LOG_TF(start,fmt,...)
#define LOG_T_CUTOFF(cutoff,start,msg)
#define LOG_TF_CUTOFF(cutoff,start,fmt,...)

#endif
