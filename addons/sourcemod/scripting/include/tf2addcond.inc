#if defined _tf2addcond_included
	#endinput
#endif

#define _tf2addcond_included

#include <tf2>

forward Action TF2_OnAddCond(int client, TFCond &cond, float &time, int &provider);

public SharedPlugin __pl_tf2addcond = {
	name = "tf2addcond",
	file = "tf2addcond.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};