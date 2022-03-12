// Tool types
#define TOOL_CROWBAR 		1
#define TOOL_MULTITOOL 		2
#define TOOL_SCREWDRIVER 	3
#define TOOL_WIRECUTTER 	4
#define TOOL_WRENCH 		5
#define TOOL_WELDER 		6
#define TOOL_ANALYZER		7
#define TOOL_MINING			8
#define TOOL_SHOVEL			9
#define TOOL_RETRACTOR	 	10
#define TOOL_HEMOSTAT 		11
#define TOOL_CAUTERY 		12
#define TOOL_DRILL			13
#define TOOL_SCALPEL		14
#define TOOL_SAW			15
#define TOOL_BLOODFILTER	16
// If delay between the start and the end of tool operation is less than MIN_TOOL_SOUND_DELAY,
// tool sound is only played when op is started. If not, it's played twice.
#define MIN_TOOL_SOUND_DELAY 20

/// When a tooltype_act proc is successful
#define TOOL_ACT_TOOLTYPE_SUCCESS (1<<0)
/// When [COMSIG_ATOM_TOOL_ACT] blocks the act
#define TOOL_ACT_SIGNAL_BLOCKING (1<<1)
