# Mazak Fusion 360 Post Processor

This post processor has been adapted by Keycult for use with an HCN-5000 horizontal machining center. Features applicable to other machine architectures may be changed or removed, and in any event, we have no way of testing them.

## Using this Post Processor

This project is developed using Keycult's [Post Utilities](https://github.com/keycult/post-utilities). The easiest way to use this post is to add both `mazak.cps` and `post-utilities.cps` to a single folder and then use `Link folder` (right-click on `Linked`) in the Post Library to ensure that the Mazak post processor is run in a context that includes the post utilities.

## TODO

- [x] Tool identifiers
- [x] Non-number program names
- [x] Remove naive smoothing implementation
- [x] Geometry compensation (G61.1)
- [x] Re-implement G5P2 (high speed smoothing, high speed machining)
- [x] High pressure coolant control (M100 - M106 to set coolant pressure levels)
- [x] G117 simultaneous operation (spindle accel/decel, through-spindle coolant)
- [x] Mist collection
- [x] Tool break detection
- [x] Remove M5 M9s before tool change
- [x] Figure out in-process probing
- [x] Include timestamp at top of program
- [x] Synchronous tapping
- [x] Automatic pallet change & program looping
- [x] Part counter support
- [x] Niagara coolant control (M130)
- [ ] Figure out why spindle doesn't start early on drilling cycles
- [ ] Add position for operator property at cycle end
- [ ] Retract to home 2 (tool change position) at end of program

## Post Properties

### Post Processing Control Properties

These properties provide high-level control over the way the post processor functions.

| Property | Type | Default |
| :--- | :---: | :---: |
| **Enable machining modes defined per operation** | Checkbox | ☑ |

Enables the use of per-operation machining mode properties to set `G61.1` Geometry Compensation, `G5 P2` High Speed Machining mode, etc. Please note that these per-operation control fields will still be present in the Post Properties tab of each operation dialogue, but nothing will be output unless this property is enabled. See the **Operation Properties** section for more.

### Documentation

These properties control comment documentation that is output with posted code.

| Property | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| **Write tool list** | Checkbox | ☑ | Output a tool list in a header comment near the top of the code |
| **Write operation notes** | Checkbox | ☑ | Output operation notes as comments near the beginning of each code section |
| **Write tool comments** | Checkbox | ☑ | Output tool comments after each tool change line |

### Formatting

These properties control the formatting of posted code.

| Property | Type | Default | Description |
| :--- | :---: | :---: | :--- |
| **Separate words with space** | Checkbox | ☑ | Separate words with spaces |

### General

All other properties that don't easily fit into one of the categories above.

**TODO**

    title: "Preload next tool",
    description: "Preloads the next tool at a tool change (if any).",

    title: "Optional stop before tool change",
    description: "Outputs optional stop code before each tool change.",

    title: "Use radius arcs instead of IJK",
    description: "If yes is selected, arcs are outputted using radius values rather than IJK.",

    title: "Use Q-value parametric feed",
    description: "Specifies the feed value that should be output using a Q value.",

    title: "Use pitch for tapping",
    description: "Enables the use of pitch instead of feed for the F-word in canned tapping cycles.",

    title: "Use G54.4 for angular probing",
    description: "Use G54.4 workpiece error compensation for angular probing.",

    title: "Safe retract method",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",

    title: "Inspection: Create single results file",
    description: "Set to false if you want to store the measurement results for each probe / inspection toolpath in separate files",

    title: "Use tool identifiers",
    description: "Uses alphanumeric tool identifiers instead of tool numbers to call tools.",

    title: "Use G117",
    description: "Uses G117 to execute some auxiliary functions during axis movement (spindle, coolant, etc.)",

### Operation properties

| Property | Type | Default |
| :--- | :---: | :---: |
| **Machining mode** | Dropdown | Auto |

| Property | Type | Default |
| :--- | :---: | :---: |
| **Enable high speed mode** | Checkbox | ☐ |

| Property | Type | Default |
| :--- | :---: | :---: |
| **Through-spindle coolant pressure** | Dropdown | Default (`M107`) |
