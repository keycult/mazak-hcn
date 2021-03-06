/**
  Copyright (C) 2012-2021 by Autodesk, Inc.
  All rights reserved.

  Mazak post processor configuration.

  Subsequent additions by Zach Allaun & Keycult.
*/

// ATTENTION:
//   Parameter F86.6 must be on for G43.4
//   Parameter RB8.2 must be on for spiral chip conveyor

// include("post-utilities.cps");
!(function (global) {
  var _ = {};

  /* General JavaScript Utilities */

  _.map = function (arr, f) {
    arr = arr || [];
    var result = [];
    for (var i = 0; i < arr.length; i++) {
      result.push(f(arr[i], i));
    }
    return result;
  };

  _.filter = function (arr, pred) {
    arr = arr || [];
    var result = [];
    for (var i = 0; i < arr.length; i++) {
      var element = arr[i];
      if (pred(element, i)) {
        result.push(element);
      }
    }
    return result;
  };

  _.find = function (arr, pred) {
    arr = arr || [];
    for (var i = 0; i < arr.length; i++) {
      var element = arr[i];
      if (pred(element, i)) {
        return element;
      }
    }
    return undefined;
  };

  _.any = function (arr, pred) {
    return !!_.find(arr, pred);
  };

  _.every = function (arr, pred) {
    return arr.length === _.filter(arr, pred).length;
  };

  _.forEach = function (arr, f) {
    _.map(arr, f);
  };

  _.take = function (obj, n) {
    return obj.slice(0, n);
  };

  _.drop = function (obj, n) {
    return obj.slice(n, arr.length);
  };

  _.apply = function (f, list, thisArg) {
    return f.apply(thisArg, list);
  };

  _.reverse = function (list) {
    return [].concat(list).reverse();
  };

  var objStringChecker = function (s) {
    return function (obj) {
      return Object.prototype.toString.call(obj) === '[object ' + s + ']';
    };
  };

  _.isBoolean = objStringChecker('Boolean');
  _.isFunction = objStringChecker('Function');
  _.isString = objStringChecker('String');
  _.isNumber = objStringChecker('Number');
  _.isDate = objStringChecker('Date');
  _.isArray = Array.isArray || objStringChecker('Array');

  _.isEqual = function (o1, o2) {
    return o1 === o2;
  };

  _.ensureArray = function (obj) {
    return _.isArray(obj) ? obj : [obj];
  };

  _.memoize = function (f) {
    var cache = {};

    return function (key) {
      var address = '' + key;

      if (!cache.hasOwnProperty(address)) {
        cache[address] = f(key);
      }

      return cache[address];
    };
  };

  /* Post API Utilities */

  _.allSections = _.memoize(function () {
    var result = [];

    for (var i = 0; i < global.getNumberOfSections(); i++) {
      result.push(global.getSection(i));
    }

    return result;
  });

  _.allTools = _.memoize(function () {
    var result = [];
    var tools = global.getToolTable();

    for (var i = 0; i < tools.getNumberOfTools(); i++) {
      result.push(tools.getTool(i));
    }

    return result;
  });

  _.sectionsAfter = function (s1) {
    return _.filter(_.allSections(), function (s2) {
      return s2.getId() > s1.getId();
    });
  };

  _.sectionsBefore = function (s1) {
    return _.filter(_.allSections(), function (s2) {
      return s2.getId() < s1.getId();
    });
  };

  global._ = _;
})(this);

description = 'Mazak HCN (Keycult)';
vendor = 'Mazak';
vendorUrl = 'http://www.autodesk.com';
legal = 'Copyright (C) 2012-2021 by Autodesk, Inc.';
certificationLevel = 2;
minimumRevision = 45702;

longDescription = 'Milling post for Mazak HCN, with customizations by Keycult';

extension = 'eia';
programNameIsInteger = false;
setCodePage('ascii');

capabilities = CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
probeMultipleFeatures = true;
mapWorkOrigin = false;

groupDefinitions = {
  keycult: { title: 'Keycult', order: 0 },
  postControl: { title: 'Post Processor Features', order: 1 },
  utilities: { title: 'Program Utilities', order: 2 },
  controlFeatures: { title: 'Control Features', order: 3 },
  documentation: { title: 'Documentation', order: 4, collapsed: true },
  formatting: { title: 'Formatting', order: 5, collapsed: true },
};

properties = {
  // Keycult-specific Features
  blockSkipControls: {
    group: 'keycult',
    title: 'Block skip controls: Enable',
    description:
      'Control which pallet stations programs run on with block skip',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  incPartsCount: {
    group: 'keycult',
    title: 'Block skip controls: Enable part count',
    description: 'Increment part count for each skip used',
    type: 'boolean',
    value: false,
    scope: 'post',
  },
  incPartsCountBy: {
    group: 'keycult',
    title: 'Block skip controls: Part count',
    description: 'If enabled, increment by part count by this amount',
    type: 'integer',
    value: 1,
    scope: 'post',
  },

  // Post Processor Features
  enableMachiningModes: {
    group: 'postControl',
    title: 'Enable machining modes defined per operation',
    description:
      'Machining modes are specified in the operation dialogue Post Processing tab',
    type: 'boolean',
    value: true,
    scope: 'post',
  },

  // Program Utilities
  ncPassThrough: {
    group: 'utilities',
    title: 'Program start NC pass through',
    type: 'string',
    value: 'M98 <KEYCULT_SET_SCHUNK_OFFSETS>',
    scope: 'post',
  },
  optionalStop: {
    group: 'utilities',
    title: 'Optional stop before tool change',
    description: 'Outputs optional stop code before each tool change.',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  singleResultsFile: {
    group: 'utilities',
    title: 'Inspection: Create single results file',
    description:
      'Set to false if you want to store the measurement results for each probe / inspection toolpath in separate files',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  enableMistCollector: {
    group: 'utilities',
    title: 'Enable mist collector',
    description:
      'Turns on the mist collector at the beginning of operation and off at the end of the program',
    type: 'boolean',
    value: false,
    scope: 'post',
  },
  breakDetectEnable: {
    group: 'utilities',
    title: 'Tool breakage detection: Enable',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  breakDetectPassThrough: {
    group: 'utilities',
    title: 'Tool breakage detection: Pass through',
    description:
      'Block to pass through to perform tool breakage detection on tool currently in spindle',
    type: 'string',
    value: 'G65 <KEYCULT_TOOL_BREAKAGE_DETECT>',
    scope: 'post',
  },
  positionXYWithABC: {
    group: 'utilities',
    title: 'Position XY with ABC for non-multi-axis sections',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  ensureToolLength: {
    group: 'utilities',
    title: 'Ensure tool length',
    description:
      'Ensure that the length of the tool in the spindle is greater than or equal to the programmed length',
    type: 'boolean',
    value: true,
    scope: 'post',
  },

  // Control Features
  preloadTool: {
    group: 'controlFeatures',
    title: 'Preload next tool',
    description: 'Preloads the next tool at a tool change (if any).',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  useRadius: {
    group: 'controlFeatures',
    title: 'Use radius arcs instead of IJK',
    description:
      'If yes is selected, arcs are outputted using radius values rather than IJK.',
    type: 'boolean',
    value: false,
    scope: 'post',
  },
  useParametricFeed: {
    group: 'controlFeatures',
    title: 'Use Q-value parametric feed',
    description:
      'Specifies the feed value that should be output using a Q value.',
    type: 'boolean',
    value: false,
    scope: 'post',
  },
  useG54x4: {
    group: 'controlFeatures',
    title: 'Use G54.4 for angular probing',
    description: 'Use G54.4 workpiece error compensation for angular probing.',
    type: 'boolean',
    value: false,
    scope: 'post',
  },
  safePositionMethod: {
    group: 'controlFeatures',
    title: 'Safe retract method',
    description:
      "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    type: 'enum',
    values: [
      // {title: "G28", id: "G28"},
      { title: 'G53', id: 'G53' },
      { title: 'Clearance Height', id: 'clearanceHeight' },
      { title: 'G30 P4', id: 'G30P4' },
    ],
    value: 'G53',
    scope: 'post',
  },
  useToolIdentifiers: {
    group: 'controlFeatures',
    title: 'Use tool identifiers',
    description:
      'Uses alphanumeric tool identifiers instead of tool numbers to call tools.',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  useG117: {
    group: 'controlFeatures',
    title: 'Use G117',
    description:
      'Uses G117 to execute some auxiliary functions during axis movement (spindle, coolant, etc.)',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  syncTappingReturnSpeed: {
    group: 'controlFeatures',
    title: 'Synchronous tapping return speed (%)',
    description: 'Controls the return speed as a percentage of tapping speed',
    type: 'integer',
    value: 200,
    scope: 'post',
  },
  niagaraCoolant: {
    group: 'controlFeatures',
    title: 'Niagara coolant at end of program (seconds)',
    description: 'Number of seconds to run Niagara coolant (zero to disable)',
    type: 'integer',
    value: 0,
    scope: 'post',
  },

  // Documentation
  writeTools: {
    group: 'documentation',
    title: 'Write tool list',
    description: 'Output a tool list in the header of the code.',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  showNotes: {
    group: 'documentation',
    title: 'Write operation notes',
    description: 'Writes operation notes as comments in the outputted code.',
    type: 'boolean',
    value: true,
    scope: 'post',
  },
  showToolComments: {
    group: 'documentation',
    title: 'Write tool comments',
    description: 'Writes tool comments after a tool change.',
    type: 'boolean',
    value: false,
    scope: 'post',
  },

  // Formatting
  separateWordsWithSpace: {
    group: 'formatting',
    title: 'Separate words with space',
    description: "Adds spaces between words if 'yes' is selected.",
    type: 'boolean',
    value: true,
    scope: 'post',
  },

  // Operation properties
  machiningMode: {
    title: 'Machining mode',
    description: 'Sets the machining mode for the operation',
    type: 'enum',
    values: [
      { title: 'Auto', id: 'auto' },
      { title: 'G61.1 P0 (Rough)', id: 'P0' },
      { title: 'G61.1 P1 (Semi-Rough)', id: 'P1' },
      { title: 'G61.1 P2 (Smooth)', id: 'P2' },
      { title: 'G61.1 P3 (Accurate)', id: 'P3' },
      { title: 'G63 (Tapping)', id: 'tapping' },
      { title: 'G64 (Cutting)', id: 'cutting' },
    ],
    value: 'auto',
    scope: 'operation',
  },
  highSpeedMode: {
    title: 'Enable high speed mode',
    description:
      'Enables G5 P2 for this operation (not applicable for probing, tapping, etc.)',
    type: 'boolean',
    value: false,
    scope: 'operation',
  },
  tscPressure: {
    title: 'Through-spindle coolant pressure',
    description: 'Sets the high-pressure (Super Flow) system pressure level',
    type: 'enum',
    values: [
      { title: 'Default', id: '107' },
      { title: 'Level 1', id: '100' },
      { title: 'Level 2', id: '101' },
      { title: 'Level 3', id: '102' },
      { title: 'Level 4', id: '103' },
      { title: 'Level 5', id: '104' },
      { title: 'Level 6', id: '105' },
      { title: 'Level 7', id: '106' },
    ],
    value: '107',
    scope: 'operation',
  },
  keycultSerialization: {
    title: 'Serialization: Enable',
    description:
      "Warning: Don't use unless you understand the serialization macro",
    type: 'boolean',
    value: false,
    scope: 'operation',
  },
  keycultSerializationMacro: {
    title: 'Serialization: Macro',
    description:
      "Warning: Don't use unless you understand the serialization macro",
    type: 'string',
    value: 'Serialize-Qanelas-2mm',
    scope: 'operation',
  },
  keycultSerializationMacroPassthrough: {
    title: 'Serialization: Macro passthrough',
    description:
      "Warning: Don't use unless you understand the serialization macro",
    type: 'string',
    value: '',
    scope: 'operation',
  },
  revSpinChipBreak: {
    title: 'Reverse spindle rotation before tool change to remove chips',
    type: 'boolean',
    value: false,
    scope: 'operation',
  },
};

var coolantOffCodes = [9];
var coolants = [
  { id: COOLANT_FLOOD, codes: [8] },
  { id: COOLANT_MIST, codes: [7] },
  { id: COOLANT_THROUGH_TOOL, codes: [131] },
  { id: COOLANT_FLOOD_THROUGH_TOOL, codes: [8, 131] },
  { id: COOLANT_AIR_THROUGH_TOOL, codes: [132] },

  // Currently unsupported
  // { id: COOLANT_AIR },
  // { id: COOLANT_SUCTION },
  // { id: COOLANT_FLOOD_MIST },
];

var permittedCommentChars =
  ' ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz.,=_-:#';
var permittedToolIdentifierChars =
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-_.';

var gFormat = createFormat({ prefix: 'G', decimals: 1 });
var mFormat = createFormat({ prefix: 'M', decimals: 0 });
var hFormat = createFormat({ prefix: 'H', decimals: 0 });
var dFormat = createFormat({ prefix: 'D', decimals: 0 });
var probeWCSFormat = createFormat({ decimals: 0, forceDecimal: true });

var xyzFormat = createFormat({
  decimals: unit == MM ? 3 : 4,
  forceDecimal: true,
});
var ijkFormat = createFormat({ decimals: 6, forceDecimal: true }); // unitless
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({ decimals: 3, forceDecimal: true, scale: DEG });
var feedFormat = createFormat({
  decimals: unit == MM ? 2 : 3,
  forceDecimal: true,
});
var pitchFormat = createFormat({
  decimals: unit == MM ? 3 : 4,
  forceDecimal: true,
});
var toolFormat = createFormat({ decimals: 0 });
var rpmFormat = createFormat({ decimals: 0 });
var secFormat = createFormat({ decimals: 3, forceDecimal: true }); // seconds - range 0.001-99999.999
var milliFormat = createFormat({ decimals: 0 }); // milliseconds // range 1-99999999
var taperFormat = createFormat({ decimals: 1, scale: DEG });
var oFormat4 = createFormat({ width: 4, zeropad: true, decimals: 0 });
var oFormat8 = createFormat({ width: 8, zeropad: true, decimals: 0 });

var xOutput = createVariable({ prefix: 'X' }, xyzFormat);
var yOutput = createVariable({ prefix: 'Y' }, xyzFormat);
var zOutput = createVariable(
  {
    onchange: function () {
      retracted = false;
    },
    prefix: 'Z',
  },
  xyzFormat
);
var aOutput = createVariable({ prefix: 'A' }, abcFormat);
var bOutput = createVariable({ prefix: 'B' }, abcFormat);
var cOutput = createVariable({ prefix: 'C' }, abcFormat);
var feedOutput = createVariable({ prefix: 'F' }, feedFormat);
var pitchOutput = createVariable({ prefix: 'F', force: true }, pitchFormat);
var sOutput = createVariable({ prefix: 'S', force: true }, rpmFormat);

// circular output
var iOutput = createReferenceVariable({ prefix: 'I', force: true }, xyzFormat);
var jOutput = createReferenceVariable({ prefix: 'J', force: true }, xyzFormat);
var kOutput = createReferenceVariable({ prefix: 'K', force: true }, xyzFormat);

var gMotionModal = createModal({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal(
  {
    onchange: function () {
      gMotionModal.reset();
    },
  },
  gFormat
); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = gMotionModal;
var gRetractModal = createModal({}, gFormat); // modal group 10 // G98-99
var gRotationModal = createModal(
  {
    onchange: function () {
      if (probeVariables.probeAngleMethod == 'G68') {
        probeVariables.outputRotationCodes = true;
      }
    },
  },
  gFormat
); // modal group 16 // G68-G69

// fixed settings
var firstFeedParameter = 100;
var useMultiAxisFeatures = true;
var forceMultiAxisIndexing = false; // force multi-axis indexing for 3D programs
var cancelTiltFirst = true; // cancel G68.2 with G69 prior to G54-G59 WCS block
var useABCPrepositioning = true; // position ABC axes prior to G68.2 block

var WARNING_WORK_OFFSET = 0;

var allowIndexingWCSProbing = false; // specifies that probe WCS with tool orientation is supported
var probeVariables = {
  outputRotationCodes: false, // defines if it is required to output rotation codes
  probeAngleMethod: 'OFF', // OFF, AXIS_ROT, G68, G54.4
  compensationXY: undefined,
  probeOn: false,
};

// collected state
var currentWorkOffset;
var forceSpindleSpeed = false;
var activeMovements; // do not use by default
var currentFeedId;
var maximumCircularRadiiDifference = toPreciseUnit(0.005, MM);
var retracted = false; // specifies that the tool has been retracted to the safe plane
var prepositionedXY = false;
var blockSkipController;

// Machine configuration
var compensateToolLength = false; // add the tool length to the pivot distance for nonTCP rotary heads
var virtualTooltip = false; // translate the pivot point to the virtual tool tip for nonTCP rotary heads
// internal variables, do not change
var receivedMachineConfiguration;
var tcpIsSupported;

// onRewindMachine configuration
var performRewinds = false; // only use this setting with hardcoded machine configurations, set to true to enable the rewind/reconfigure logic
var stockExpansion = new Vector(
  toPreciseUnit(0.1, IN),
  toPreciseUnit(0.1, IN),
  toPreciseUnit(0.1, IN)
); // expand stock XYZ values
var safeRetractDistance = unit == IN ? 1 : 25; // additional distance to retract out of stock
var safeRetractFeed = unit == IN ? 20 : 500; // retract feed rate
var safePlungeFeed = unit == IN ? 10 : 250; // plunge feed rate

function writeBlock() {
  if (!formatWords(arguments)) {
    return;
  }
  writeWords(arguments);
}

function writeOptionalBlock() {
  writeWords2('/', arguments);
}

function formatComment(text) {
  return '(' + filterText(text, permittedCommentChars) + ')';
}

function writeComment(text) {
  writeln(formatComment(text));
}

function formatWorkOffset(workOffset) {
  if (workOffset > 6) {
    return gFormat.format(54.1) + ' P' + (workOffset - 6);
  } else {
    return gFormat.format(53 + workOffset);
  }
}

function formatToolForSummary(tool, zRanges) {
  var comment = '';

  if (getProperty(properties.useToolIdentifiers) && tool.description) {
    comment += 'T-ID: ';
  } else {
    comment += 'T';
  }

  comment += formatToolNumber(tool);

  if (zRanges) {
    var zRange = zRanges[tool.number];
    if (zRange) {
      comment += ' Zmin=' + xyzFormat.format(zRange.getMinimum());
    }
  }

  if (tool.type === TOOL_PROBE) {
    comment += ' - Probe';
  } else {
    comment += ' - Len=' + parseFloat(tool.getBodyLength().toFixed(4));
  }

  return comment;
}

function writeHeader() {
  writeComment(programName);
  programComment && writeComment('  ' + programComment);
  writeComment('  ' + formatPostDateTime(new Date()));
  writeComment(
    '  Machine Configuration: ' +
      machineConfiguration.getVendor() +
      ' ' +
      machineConfiguration.getModel()
  );
  writeln('');

  writePostFeatures();
  writeln('');

  if (getProperty(properties.writeTools)) {
    writeToolSummary();
    writeln('');
  }
}

function writeMachineSummary() {
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();

  if (vendor || model) {
    writeComment('Machine Configuration: ' + vendor + ' ' + model);
  }
}

function writePostFeatures() {
  writeComment('Enabled Program Features:');

  var features = [];

  if (getProperty(properties.breakDetectEnable)) {
    features.push('  Tool breakage detection');
  }

  if (getProperty(properties.ensureToolLength)) {
    features.push('  Ensure tool len is greater than CAM len');
  }

  if (blockSkipController.isEnabled()) {
    features.push('  Block skip controls:');
    features.push('    Skip 1 - Run pallet side 1');
    features.push('    Skip 2 - Run pallet side 2');
    features.push('    Skip 3 - Run pallet side 3');
    features.push('    Skip 8 - Skip all probing operations');
    features.push('    Skip 9 - Swap to other pallet at end and continue');
  }

  if (features.length === 0) {
    writeComment('  None');
  } else {
    _.forEach(features, writeComment);
  }
}

function writeToolSummary() {
  writeComment('Tools:');

  var zRanges = {};
  if (is3D()) {
    _.forEach(_.allSections(), function (section) {
      var zRange = section.getGlobalZRange();
      var tool = section.getTool();
      if (zRanges[tool.number]) {
        zRanges[tool.number].expandToRange(zRange);
      } else {
        zRanges[tool.number] = zRange;
      }
    });
  }

  _.forEach(_.allTools(), function (tool) {
    writeComment('  ' + formatToolForSummary(tool, zRanges));
  });
}

function activateMachine() {
  _.forEach([aOutput, bOutput, cOutput], function (output, i) {
    machineConfiguration.isMachineCoordinate(i) || output.disable();
  });

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // don't need to modify any settings for 3-axis machines
  }

  tcpIsSupported = false;
  _.forEach(
    [
      machineConfiguration.getAxisU(),
      machineConfiguration.getAxisV(),
      machineConfiguration.getAxisW(),
    ],
    function (axis) {
      if (axis.isEnabled() && axis.isTCPEnabled()) {
        tcpIsSupported = true;
      }
    }
  );

  if (machineConfiguration.performRewinds() || performRewinds) {
    machineConfiguration.enableMachineRewinds();
    machineConfiguration.setRewindStockExpansion(stockExpansion);
  }

  if (!receivedMachineConfiguration) {
    setMachineConfiguration(machineConfiguration);
  }

  if (machineConfiguration.isHeadConfiguration()) {
    machineConfiguration.setVirtualTooltip(virtualTooltip);
  }

  setFeedrateMode();

  if (machineConfiguration.isHeadConfiguration() && compensateToolLength) {
    _.forEach(_.allSections(), function (section) {
      if (section.isMultiAxis()) {
        machineConfiguration.getToolLength(section.getTool().getBodyLength());
        section.optimizeMachineAnglesByMachine(
          machineConfiguration,
          tcpIsSupported ? 0 : 1
        );
      }
    });
  } else {
    optimizeMachineAngles2(tcpIsSupported ? 0 : 1);
  }
}

function setFeedrateMode(reset) {
  if (
    (tcpIsSupported && !reset) ||
    !machineConfiguration.isMultiAxisConfiguration()
  ) {
    return;
  }
  machineConfiguration.setMultiAxisFeedrate(
    tcpIsSupported ? FEED_FPM : FEED_INVERSE_TIME,
    9999.99, // maximum output value for inverse time feed rates
    INVERSE_MINUTES, // can be INVERSE_SECONDS or DPM_COMBINATION for DPM feeds
    0.5, // tolerance to determine when the DPM feed has changed
    1.0 // ratio of rotary accuracy to linear accuracy for DPM calculations
  );
  if (!receivedMachineConfiguration || revision < 45765) {
    setMachineConfiguration(machineConfiguration);
  }
}

function writeSafeStartModals() {
  var words = [];

  gUnitModal.reset() &&
    words.push(unit === IN ? gUnitModal.format(20) : gUnitModal.format(21));
  gAbsIncModal.reset() && words.push(gAbsIncModal.format(90));
  gFeedModeModal.reset() && words.push(gFeedModeModal.format(94));
  gPlaneModal.reset() && words.push(gPlaneModal.format(17));
  gCycleModal.reset() && words.push(gCycleModal.format(80));

  words.push(gFormat.format(40));

  return _.apply(writeBlock, words);
}

function onOpen() {
  blockSkipController = new BlockSkipController();

  receivedMachineConfiguration =
    typeof machineConfiguration.isReceived === 'function'
      ? machineConfiguration.isReceived()
      : machineConfiguration.getDescription() !== '' ||
        machineConfiguration.isMultiAxisConfiguration();

  activateMachine();

  if (getProperty(properties.useRadius)) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }

  gRotationModal.format(69); // Default to G69 Rotation Off

  if (!getProperty(properties.separateWordsWithSpace)) {
    setWordSeparator('');
  }

  validate(programName, 'Program name has not been specified.');

  writeHeader();

  if (getNumberOfSections() > 0 && getSection(0).workOffset === 0) {
    var nonZeroOffset = _.any(_.allSections(), function (section) {
      return section.workOffset > 0;
    });

    if (nonZeroOffset) {
      error(
        'Using multiple work offsets is not possible if the initial work offset is 0.'
      );
    }
  }

  if (blockSkipController.isEnabled()) {
    blockSkipController.writeBlockSkipInit();
  }

  //Probing Surface Inspection
  if (typeof inspectionWriteVariables == 'function') {
    inspectionWriteVariables();
    writeln('');
  }

  if (getProperty(properties.ncPassThrough)) {
    writeBlock(getProperty(properties.ncPassThrough));
    writeln('');
  }

  writeSafeStartModals();

  if (getProperty(properties.enableMistCollector)) {
    writeBlock(mFormat.format(613));
  }

  onCommand(COMMAND_START_CHIP_TRANSPORT);
}

function onComment(message) {
  writeComment(message);
}

function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

/** Disables length compensation if currently active or if forced. */
var lengthCompensationActive = false;
function disableLengthCompensation(force) {
  if (lengthCompensationActive || force) {
    validate(
      retracted,
      'Cannot cancel length compensation if the machine is not fully retracted.'
    );
    writeBlock(gFormat.format(49));
    lengthCompensationActive = false;
  }
}

function getOffsetCode() {
  var offsetCode = 43;
  if (currentSection.isMultiAxis()) {
    if (machineConfiguration.isMultiAxisConfiguration() && tcpIsSupported) {
      offsetCode = 43.4;
    } else if (!machineConfiguration.isMultiAxisConfiguration()) {
      offsetCode = 43.5;
    }
  }
  return offsetCode;
}

function FeedContext(id, description, feed) {
  this.id = id;
  this.description = description;
  this.feed = feed;
}

function getFeed(f) {
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, f)) {
        if (feedContext.id == currentFeedId) {
          return ''; // nothing has changed
        }
        forceFeed();
        currentFeedId = feedContext.id;
        return 'F#' + (firstFeedParameter + feedContext.id);
      }
    }
    currentFeedId = undefined; // force Q feed next time
  }
  return feedOutput.format(f); // use feed value
}

function initializeActiveFeeds() {
  activeMovements = new Array();
  var movements = currentSection.getMovements();

  var id = 0;
  var activeFeeds = new Array();
  if (hasParameter('operation:tool_feedCutting')) {
    if (
      movements &
      ((1 << MOVEMENT_CUTTING) |
        (1 << MOVEMENT_LINK_TRANSITION) |
        (1 << MOVEMENT_EXTENDED))
    ) {
      var feedContext = new FeedContext(
        id,
        localize('Cutting'),
        getParameter('operation:tool_feedCutting')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_CUTTING] = feedContext;
      activeMovements[MOVEMENT_LINK_TRANSITION] = feedContext;
      activeMovements[MOVEMENT_EXTENDED] = feedContext;
    }
    ++id;
    if (movements & (1 << MOVEMENT_PREDRILL)) {
      feedContext = new FeedContext(
        id,
        localize('Predrilling'),
        getParameter('operation:tool_feedCutting')
      );
      activeMovements[MOVEMENT_PREDRILL] = feedContext;
      activeFeeds.push(feedContext);
    }
    ++id;
  }

  if (hasParameter('operation:finishFeedrate')) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(
        id,
        localize('Finish'),
        getParameter('operation:finishFeedrate')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  } else if (hasParameter('operation:tool_feedCutting')) {
    if (movements & (1 << MOVEMENT_FINISH_CUTTING)) {
      var feedContext = new FeedContext(
        id,
        localize('Finish'),
        getParameter('operation:tool_feedCutting')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_FINISH_CUTTING] = feedContext;
    }
    ++id;
  }

  if (hasParameter('operation:tool_feedEntry')) {
    if (movements & (1 << MOVEMENT_LEAD_IN)) {
      var feedContext = new FeedContext(
        id,
        localize('Entry'),
        getParameter('operation:tool_feedEntry')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_IN] = feedContext;
    }
    ++id;
  }

  if (hasParameter('operation:tool_feedExit')) {
    if (movements & (1 << MOVEMENT_LEAD_OUT)) {
      var feedContext = new FeedContext(
        id,
        localize('Exit'),
        getParameter('operation:tool_feedExit')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LEAD_OUT] = feedContext;
    }
    ++id;
  }

  if (hasParameter('operation:noEngagementFeedrate')) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(
        id,
        localize('Direct'),
        getParameter('operation:noEngagementFeedrate')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  } else if (
    hasParameter('operation:tool_feedCutting') &&
    hasParameter('operation:tool_feedEntry') &&
    hasParameter('operation:tool_feedExit')
  ) {
    if (movements & (1 << MOVEMENT_LINK_DIRECT)) {
      var feedContext = new FeedContext(
        id,
        localize('Direct'),
        Math.max(
          getParameter('operation:tool_feedCutting'),
          getParameter('operation:tool_feedEntry'),
          getParameter('operation:tool_feedExit')
        )
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_LINK_DIRECT] = feedContext;
    }
    ++id;
  }

  if (hasParameter('operation:reducedFeedrate')) {
    if (movements & (1 << MOVEMENT_REDUCED)) {
      var feedContext = new FeedContext(
        id,
        localize('Reduced'),
        getParameter('operation:reducedFeedrate')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_REDUCED] = feedContext;
    }
    ++id;
  }

  if (hasParameter('operation:tool_feedRamp')) {
    if (
      movements &
      ((1 << MOVEMENT_RAMP) |
        (1 << MOVEMENT_RAMP_HELIX) |
        (1 << MOVEMENT_RAMP_PROFILE) |
        (1 << MOVEMENT_RAMP_ZIG_ZAG))
    ) {
      var feedContext = new FeedContext(
        id,
        localize('Ramping'),
        getParameter('operation:tool_feedRamp')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_RAMP] = feedContext;
      activeMovements[MOVEMENT_RAMP_HELIX] = feedContext;
      activeMovements[MOVEMENT_RAMP_PROFILE] = feedContext;
      activeMovements[MOVEMENT_RAMP_ZIG_ZAG] = feedContext;
    }
    ++id;
  }
  if (hasParameter('operation:tool_feedPlunge')) {
    if (movements & (1 << MOVEMENT_PLUNGE)) {
      var feedContext = new FeedContext(
        id,
        localize('Plunge'),
        getParameter('operation:tool_feedPlunge')
      );
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_PLUNGE] = feedContext;
    }
    ++id;
  }
  if (true) {
    // high feed
    if (
      movements & (1 << MOVEMENT_HIGH_FEED) ||
      highFeedMapping != HIGH_FEED_NO_MAPPING
    ) {
      var feed;
      if (
        hasParameter('operation:highFeedrateMode') &&
        getParameter('operation:highFeedrateMode') != 'disabled'
      ) {
        feed = getParameter('operation:highFeedrate');
      } else {
        feed = this.highFeedrate;
      }
      var feedContext = new FeedContext(id, localize('High Feed'), feed);
      activeFeeds.push(feedContext);
      activeMovements[MOVEMENT_HIGH_FEED] = feedContext;
      activeMovements[MOVEMENT_RAPID] = feedContext;
    }
    ++id;
  }

  for (var i = 0; i < activeFeeds.length; ++i) {
    var feedContext = activeFeeds[i];
    writeBlock(
      '#' +
        (firstFeedParameter + feedContext.id) +
        '=' +
        feedFormat.format(feedContext.feed),
      formatComment(feedContext.description)
    );
  }
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function cancelWorkPlane(force) {
  if (force) {
    gRotationModal.reset();
  }
  writeBlock(gRotationModal.format(69)); // cancel frame
  forceWorkPlane();
}

function setWorkPlane(abc, initialPosition) {
  if (
    !forceMultiAxisIndexing &&
    is3D() &&
    !machineConfiguration.isMultiAxisConfiguration()
  ) {
    return; // ignore
  }

  if (
    !(
      currentWorkPlaneABC == undefined ||
      abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
      abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
      abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z)
    )
  ) {
    return; // no change
  }

  onCommand(COMMAND_UNLOCK_MULTI_AXIS);
  if (!retracted) {
    writeRetract(Z);
  }

  if (useMultiAxisFeatures) {
    if (cancelTiltFirst) {
      cancelWorkPlane();
    }
    if (machineConfiguration.isMultiAxisConfiguration()) {
      var machineABC = abc.isNonZero()
        ? getWorkPlaneMachineABC(currentSection.workPlane, false, false)
        : abc;
      if (useABCPrepositioning || abc.isZero()) {
        gMotionModal.reset();
        var commands = [
          gMotionModal.format(0),
          conditional(
            machineConfiguration.isMachineCoordinate(0),
            'A' + abcFormat.format(machineABC.x)
          ),
          conditional(
            machineConfiguration.isMachineCoordinate(1),
            'B' + abcFormat.format(machineABC.y)
          ),
          conditional(
            machineConfiguration.isMachineCoordinate(2),
            'C' + abcFormat.format(machineABC.z)
          ),
        ];

        if (
          getProperty(properties.positionXYWithABC) &&
          initialPosition &&
          abc.isZero()
        ) {
          commands.push(xOutput.format(initialPosition.x));
          commands.push(yOutput.format(initialPosition.y));
          prepositionedXY = true;
        }

        _.apply(writeBlock, commands);
      }
      setCurrentABC(machineABC); // required for machine simulation
    }
    if (abc.isNonZero()) {
      gRotationModal.reset();
      var xyz = { x: 0, y: 0, z: 0 };

      if (!mapWorkOrigin) {
        xyz = currentSection.getWorkOrigin();
      }

      writeBlock(
        gRotationModal.format(68.2),
        'X' + xyzFormat.format(xyz.x),
        'Y' + xyzFormat.format(xyz.y),
        'Z' + xyzFormat.format(xyz.z),
        'I' + abcFormat.format(abc.x),
        'J' + abcFormat.format(abc.y),
        'K' + abcFormat.format(abc.z)
      );
      if (!useABCPrepositioning) {
        writeBlock(gFormat.format(53.1)); // turn machine
      }
    } else {
      if (!cancelTiltFirst) {
        cancelWorkPlane();
      }
    }
  } else {
    writeBlock(
      gMotionModal.format(0),
      conditional(
        machineConfiguration.isMachineCoordinate(0),
        'A' + abcFormat.format(abc.x)
      ),
      conditional(
        machineConfiguration.isMachineCoordinate(1),
        'B' + abcFormat.format(abc.y)
      ),
      conditional(
        machineConfiguration.isMachineCoordinate(2),
        'C' + abcFormat.format(abc.z)
      )
    );
    setCurrentABC(abc); // required for machine simulation
  }

  onCommand(COMMAND_LOCK_MULTI_AXIS);

  currentWorkPlaneABC = abc;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane, _setWorkPlane, rotate) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }

  try {
    abc = machineConfiguration.remapABC(abc);
    if (_setWorkPlane) {
      currentMachineABC = abc;
    }
  } catch (e) {
    error(
      localize('Machine angles not supported') +
        ':' +
        conditional(
          machineConfiguration.isMachineCoordinate(0),
          ' A' + abcFormat.format(abc.x)
        ) +
        conditional(
          machineConfiguration.isMachineCoordinate(1),
          ' B' + abcFormat.format(abc.y)
        ) +
        conditional(
          machineConfiguration.isMachineCoordinate(2),
          ' C' + abcFormat.format(abc.z)
        )
    );
  }

  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize('Orientation not supported.'));
  }

  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize('Work plane is not supported') +
        ':' +
        conditional(
          machineConfiguration.isMachineCoordinate(0),
          ' A' + abcFormat.format(abc.x)
        ) +
        conditional(
          machineConfiguration.isMachineCoordinate(1),
          ' B' + abcFormat.format(abc.y)
        ) +
        conditional(
          machineConfiguration.isMachineCoordinate(2),
          ' C' + abcFormat.format(abc.z)
        )
    );
  }

  if (rotate) {
    var tcp = false;
    if (tcp) {
      setRotation(W); // TCP mode
    } else {
      var O = machineConfiguration.getOrientation(abc);
      var R = machineConfiguration.getRemainingOrientation(abc, W);
      setRotation(R);
    }
  }

  return abc;
}

function printProbeResults() {
  return currentSection.getParameter('printResults', 0) == 1;
}

var probeOutputWorkOffset = 1;

function onParameter(name, value) {
  switch (name) {
    case 'probe-output-work-offset':
      probeOutputWorkOffset = value > 0 ? value : 1;
      return;
  }
}

function onManualNC(command, value) {
  return expandManualNC(command, value);
}

function writeSectionSummary() {
  var sectionNumber = parseInt(currentSection.getId(), 10) + 1;
  var firstLine =
    'Section' +
    sectionNumber +
    ' - ' +
    formatWorkOffset(currentSection.workOffset);

  if (hasParameter('operation-comment')) {
    firstLine += ' - ' + getParameter('operation-comment');
  }

  writeComment(firstLine);
  writeComment(formatToolForSummary(currentSection.getTool()));
}

var MACHINING_MODES = {
  auto: gFormat.format(61.1),
  P0: gFormat.format(61.1) + ' P0',
  P1: gFormat.format(61.1) + ' P1',
  P2: gFormat.format(61.1) + ' P2',
  P3: gFormat.format(61.1) + ' P3',
  // tapping: gFormat.format(63), // G61.1 will automatically suspend during tapping
  cutting: gFormat.format(64),
  probing: 'probing', // Not output
};

var machiningModeState = {
  currentMode: 'cutting',
};

function isTappingCycle() {
  var currentCycle =
    hasParameter('operation:cycleType') && getParameter('operation:cycleType');
  var tappingCycles = [
    'tapping',
    'tapping-with-chip-breaking',
    'left-tapping',
    'left-tapping-with-chip-breaking',
    'right-tapping',
    'right-tapping-with-chip-breaking',
  ];

  return (
    currentCycle &&
    _.any(tappingCycles, function (tappingCycle) {
      return currentCycle === tappingCycle;
    })
  );
}

function getMachiningMode() {
  if (isProbeOperation()) {
    return 'probing';
  } else if (isTappingCycle()) {
    return 'auto';
  } else {
    return currentSection.getProperty(properties.machiningMode);
  }
}

function usingHighSpeedMode() {
  return (
    getProperty(properties.highSpeedMode, currentSection.getId()) &&
    !isProbeOperation() &&
    !isTappingCycle()
  );
}

function enableHighSpeedMode() {
  writeBlock(gFormat.format(5), 'P2');
}

function disableHighSpeedMode() {
  writeBlock(gFormat.format(5), 'P0');
}

function setMachiningMode() {
  var mode = getMachiningMode();

  if (mode === undefined) {
    return;
  }

  var modeCode = MACHINING_MODES[mode];
  validate(
    modeCode,
    'Post processor does not support machining mode: ' + String(mode)
  );

  if (mode !== machiningModeState.currentMode && mode !== 'probing') {
    if (
      mode === 'auto' &&
      MACHINING_MODES[machiningModeState.currentMode].substring(0, 5) ===
        'G61.1'
    ) {
      writeBlock(MACHINING_MODES.cutting);
    }

    machiningModeState.currentMode = mode;
    writeBlock(modeCode);
  }
}

var tscPressureModal = createModal({}, mFormat);
tscPressureModal.format(107); // Off by default

function setTSCPressure() {
  var tscPressure = parseInt(
    getProperty(properties.tscPressure, currentSection.getId()),
    10
  );
  writeBlock(tscPressureModal.format(tscPressure));
}

function writeToolCall(tool) {
  forceWorkPlane();

  if (!isFirstSection() && getProperty(properties.optionalStop)) {
    onCommand(COMMAND_OPTIONAL_STOP);
  }

  if (tool.number > 99999999) {
    warning(localize('Tool number exceeds maximum value.'));
  }

  var nextTool;
  if (getProperty(properties.preloadTool)) {
    nextTool = getNextTool(tool.number) || getSection(0).getTool();
  }

  writeBlock(
    mFormat.format(6),
    'T' + formatToolNumber(tool),
    conditional(
      nextTool && nextTool.number !== tool.number,
      'T' + formatToolNumber(nextTool)
    )
  );

  if (getProperty(properties.showToolComments) && tool.comment) {
    writeComment(tool.comment);
  }

  if (getProperty(properties.ensureToolLength) && !isProbeOperation()) {
    writeToolCall._formatEnsureH = createFormat({
      prefix: 'H',
      decimals: 4,
      forceDecimal: true,
    });

    writeBlock(
      gFormat.format(65),
      '<ENSURE_TOOL_LENGTH>',
      writeToolCall._formatEnsureH.format(
        tool.getBodyLength() + tool.getHolderLength()
      )
    );
  }

  coolantState.currentMode = COOLANT_OFF;
}

function onSection() {
  retracted = false;
  prepositionedXY = false;

  var previousSection = isFirstSection() ? undefined : getPreviousSection();
  var previousTool = previousSection && previousSection.getTool();

  var insertToolCall =
    !previousSection ||
    (currentSection.getForceToolChange &&
      currentSection.getForceToolChange()) ||
    tool.number !== previousTool.number;

  var newWorkOffset =
    !previousSection ||
    previousSection.workOffset !== currentSection.workOffset;

  var newWorkPlane =
    !previousSection ||
    !isSameDirection(
      previousSection.getGlobalFinalToolAxis(),
      currentSection.getGlobalInitialToolAxis()
    ) ||
    (currentSection.isOptimizedForMachine() &&
      previousSection.isOptimizedForMachine() &&
      Vector.diff(
        previousSection.getFinalToolAxisABC(),
        currentSection.getInitialToolAxisABC()
      ).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() &&
      currentSection.isMultiAxis()) ||
    (!previousSection.isMultiAxis() && currentSection.isMultiAxis()) ||
    (previousSection.isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations

  writeln('');

  writeSectionSummary();

  if (getProperty(properties.showNotes) && hasParameter('notes')) {
    var notes = getParameter('notes');
    if (notes) {
      var lines = String(notes).split('\n');
      var r1 = new RegExp('^[\\s]+', 'g');
      var r2 = new RegExp('[\\s]+$', 'g');
      for (line in lines) {
        var comment = lines[line].replace(r1, '').replace(r2, '');
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

  if (isProbeOperation()) {
    blockSkipController.writeProbeSkip();
  }

  // Force work offset when changing tool
  if (insertToolCall) {
    currentWorkOffset = undefined;
  }

  var workOffset = currentSection.workOffset;
  validate(
    workOffset >= 0,
    'Negative work offset not supported: ' + workOffset
  );

  if (workOffset === 0) {
    warningOnce(
      'Work offset has not been specified. Using G54 as WCS.',
      WARNING_WORK_OFFSET
    );
    workOffset = 1;
  }

  if (insertToolCall || newWorkOffset || newWorkPlane) {
    writeRetract(Z);
  }

  if (workOffset !== currentWorkOffset) {
    if (cancelTiltFirst) {
      cancelWorkPlane();
    }
  }

  if (insertToolCall) {
    if (
      previousSection &&
      previousSection.getProperty(properties.revSpinChipBreak)
    ) {
      var prevTool = previousSection.getTool();
      writeBlock(
        mFormat.format(prevTool.clockwise ? 4 : 3),
        rpmFormat.format(prevTool.getSpindleRPM())
      );
      writeBlock(gFormat.format(4), 'X1.5');
    }

    writeToolCall(tool);
  }

  if (isProbeOperation()) {
    validate(
      probeVariables.probeAngleMethod !== 'G68',
      'You cannot probe while G68 Rotation is in effect.'
    );
    validate(
      probeVariables.probeAngleMethod !== 'G54.4',
      'You cannot probe while workpiece setting error compensation G54.4 is enabled.'
    );

    onCommand(COMMAND_PROBE_ON);
    inspectionCreateResultsFileHeader();
  } else if (
    isInspectionOperation() &&
    typeof inspectionProcessSectionStart == 'function'
  ) {
    inspectionProcessSectionStart();
  }

  var auxCodes = [];

  if (
    !isProbeOperation() &&
    (insertToolCall ||
      forceSpindleSpeed ||
      rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent()) ||
      !previousSection ||
      tool.clockwise !== previousSection.getTool().clockwise)
  ) {
    forceSpindleSpeed = false;

    validate(spindleSpeed >= 1, 'Spindle speed out of range: ' + spindleSpeed);

    if (spindleSpeed > 99999) {
      warning('Spindle speed exceeds maximum value.');
    }

    writeBlock(sOutput.format(spindleSpeed));

    if (!isTappingCycle()) {
      auxCodes.push(mFormat.format(tool.clockwise ? 3 : 4));
    }
  }

  if (toolUsesTSC(tool)) {
    setTSCPressure();
  }

  auxCodes = auxCodes.concat(enableCoolant(tool.coolant, true));

  if (useG117() && auxCodes.length > 0) {
    _.apply(writeBlock, [gFormat.format(117)].concat(auxCodes));
  } else {
    _.forEach(auxCodes, function (code) {
      writeBlock(code);
    });
  }

  if (workOffset !== currentWorkOffset) {
    forceWorkPlane();

    writeBlock(formatWorkOffset(workOffset));

    currentWorkOffset = workOffset;
  }

  if (getProperty(properties.enableMachiningModes)) {
    setMachiningMode();
  }

  if (blockSkipController.isEnabled()) {
    blockSkipController.writeSkip(currentSection.workOffset);
  }

  forceXYZ();
  defineWorkPlane(currentSection, true);

  setProbeAngle(); // output probe angle rotations if required

  forceAny();
  gMotionModal.reset();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted && !insertToolCall) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    }
  }

  if (
    insertToolCall ||
    !lengthCompensationActive ||
    retracted ||
    (previousSection && previousSection.isMultiAxis())
  ) {
    gMotionModal.reset();
    writeBlock(gPlaneModal.format(17));

    // cancel compensation prior to enabling it, required when switching G43/G43.4 modes
    disableLengthCompensation(false);

    if (!machineConfiguration.isHeadConfiguration()) {
      if (!prepositionedXY) {
        writeBlock(
          gAbsIncModal.format(90),
          gMotionModal.format(0),
          xOutput.format(initialPosition.x),
          yOutput.format(initialPosition.y)
        );
      }
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        gFormat.format(getOffsetCode()),
        zOutput.format(initialPosition.z),
        formatToolH(tool)
      );
      lengthCompensationActive = true;
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        gFormat.format(getOffsetCode()),
        xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z),
        hFormat.format(lengthOffset)
      );
      lengthCompensationActive = true;
    }
    gMotionModal.reset();
  } else {
    writeBlock(
      gAbsIncModal.format(90),
      gMotionModal.format(0),
      xOutput.format(initialPosition.x),
      yOutput.format(initialPosition.y)
    );
  }

  validate(
    lengthCompensationActive,
    'Length compensation should not be active.'
  );

  if (usingHighSpeedMode()) {
    enableHighSpeedMode();
  }

  if (
    getProperty(properties.useParametricFeed) &&
    hasParameter('operation-strategy') &&
    getParameter('operation-strategy') !== 'drill' && // legacy
    !(currentSection.hasAnyCycle && currentSection.hasAnyCycle())
  ) {
    if (
      !insertToolCall &&
      activeMovements &&
      previousSection &&
      previousSection.getPatternId() !== 0 &&
      previousSection.getPatternId() === currentSection.getPatternId()
    ) {
      // use the current feeds
    } else {
      initializeActiveFeeds();
    }
  } else {
    activeMovements = undefined;
  }

  if (currentSection.getProperty(properties.keycultSerialization)) {
    writeSerializationMacroCall(currentSection);
    return skipRemainingSection();
  }

  return undefined;
}

function writeSerializationMacroCall(section) {
  var macroName = section.getProperty(properties.keycultSerializationMacro);
  validate(macroName, 'Macro name required for serialization macro');

  var passThrough = section.getProperty(
    properties.keycultSerializationMacroPassthrough
  );
  validate(passThrough, 'Passthrough options required for serialization macro');

  writeBlock(
    gFormat.format(65),
    '<' + macroName + '>',
    'I' + xyzFormat.format(0),
    'J' + xyzFormat.format(0),
    'K' + xyzFormat.format(0),
    passThrough
  );
}

function defineWorkPlane(_section, _setWorkPlane) {
  var abc = new Vector(0, 0, 0);
  if (
    forceMultiAxisIndexing ||
    !is3D() ||
    machineConfiguration.isMultiAxisConfiguration()
  ) {
    // use 5-axis indexing for multi-axis mode
    // set working plane after datum shift

    if (_section.isMultiAxis()) {
      cancelTransformation();
      if (_setWorkPlane) {
        forceWorkPlane();
      }
      gMotionModal.reset();
      if (machineConfiguration.isMultiAxisConfiguration()) {
        abc = _section.getInitialToolAxisABC();
        if (_setWorkPlane) {
          if (!retracted) {
            writeRetract(Z);
          }
          onCommand(COMMAND_UNLOCK_MULTI_AXIS);
          writeBlock(
            gMotionModal.format(0),
            conditional(
              machineConfiguration.isMachineCoordinate(0),
              'A' + abcFormat.format(abc.x)
            ),
            conditional(
              machineConfiguration.isMachineCoordinate(1),
              'B' + abcFormat.format(abc.y)
            ),
            conditional(
              machineConfiguration.isMachineCoordinate(2),
              'C' + abcFormat.format(abc.z)
            )
          );
        }
      } else {
        if (_setWorkPlane) {
          var d = _section.getGlobalInitialToolAxis();
          // position
          writeBlock(
            gAbsIncModal.format(90),
            gMotionModal.format(0),
            'I' + xyzFormat.format(d.x),
            'J' + xyzFormat.format(d.y),
            'K' + xyzFormat.format(d.z)
          );
        }
      }
    } else {
      if (useMultiAxisFeatures) {
        var euler = _section.workPlane.getEuler2(EULER_ZXZ_R);
        abc = new Vector(euler.x, euler.y, euler.z);
        cancelTransformation();
      } else {
        abc = getWorkPlaneMachineABC(_section.workPlane, _setWorkPlane, true);
      }
      if (_setWorkPlane) {
        setWorkPlane(abc, getFramePosition(_section.getInitialPosition()));
      }
    }
  } else {
    // pure 3D
    var remaining = _section.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize('Tool orientation is not supported.'));
      return abc;
    }
    setRotation(remaining);
  }
  return abc;
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize('Dwelling time is out of range.'));
  }
  seconds = clamp(0.001, seconds, 99999.999);
  writeBlock(
    gFeedModeModal.format(94),
    gFormat.format(4),
    'P' + milliFormat.format(seconds * 1000)
  );
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}

function onCycle() {
  writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r) {
  forceXYZ(); // force xyz on first drill hole of any cycle
  return [
    xOutput.format(x),
    yOutput.format(y),
    zOutput.format(z),
    'R' + xyzFormat.format(r),
  ];
}

/** Convert approach to sign. */
function approach(value) {
  validate(value == 'positive' || value == 'negative', 'Invalid approach.');
  return value == 'positive' ? 1 : -1;
}

function setProbeAngleMethod() {
  probeVariables.probeAngleMethod =
    machineConfiguration.getNumberOfAxes() < 5 || is3D()
      ? getProperty(properties.useG54x4)
        ? 'G54.4'
        : 'G68'
      : 'UNSUPPORTED';
  var axes = [
    machineConfiguration.getAxisU(),
    machineConfiguration.getAxisV(),
    machineConfiguration.getAxisW(),
  ];
  for (var i = 0; i < axes.length; ++i) {
    if (
      axes[i].isEnabled() &&
      isSameDirection(axes[i].getAxis().getAbsolute(), new Vector(0, 0, 1)) &&
      axes[i].isTable()
    ) {
      probeVariables.probeAngleMethod = 'AXIS_ROT';
      break;
    }
  }
  probeVariables.outputRotationCodes = true;
}

/** Output rotation offset based on angular probing cycle. */
function setProbeAngle() {
  if (probeVariables.outputRotationCodes) {
    validate(
      probeOutputWorkOffset <= 6,
      'Angular Probing only supports work offsets 1-6.'
    );
    if (
      probeVariables.probeAngleMethod == 'G68' &&
      Vector.diff(
        currentSection.getGlobalInitialToolAxis(),
        new Vector(0, 0, 1)
      ).length > 1e-4
    ) {
      error(
        localize(
          'You cannot use multi axis toolpaths while G68 Rotation is in effect.'
        )
      );
    }
    var validateWorkOffset = false;
    switch (probeVariables.probeAngleMethod) {
      case 'G54.4':
        var param = 5801 + probeOutputWorkOffset * 10;
        writeBlock('#' + param + '=#135');
        writeBlock('#' + (param + 1) + '=#136');
        writeBlock('#' + (param + 5) + '=#144');
        writeBlock(gFormat.format(54.4), 'P' + probeOutputWorkOffset);
        break;
      case 'G68':
        gRotationModal.reset();
        gAbsIncModal.reset();
        var n = xyzFormat.format(0);
        writeBlock(
          gRotationModal.format(68),
          gAbsIncModal.format(90),
          probeVariables.compensationXY,
          'Z' + n,
          'I' + n,
          'J' + n,
          'K' + xyzFormat.format(1),
          'R[#144]'
        );
        validateWorkOffset = true;
        break;
      case 'AXIS_ROT':
        var param = 5200 + probeOutputWorkOffset * 20 + 5;
        writeBlock('#' + param + ' = ' + '[#' + param + ' + #144]');
        forceWorkPlane(); // force workplane to rotate ABC in order to apply rotation offsets
        currentWorkOffset = undefined; // force WCS output to make use of updated parameters
        validateWorkOffset = true;
        break;
      default:
        error(
          localize(
            'Angular Probing is not supported for this machine configuration.'
          )
        );
        return;
    }
    if (validateWorkOffset) {
      for (var i = currentSection.getId(); i < getNumberOfSections(); ++i) {
        if (getSection(i).workOffset != currentSection.workOffset) {
          error(
            localize(
              'WCS offset cannot change while using angle rotation compensation.'
            )
          );
          return;
        }
      }
    }
    probeVariables.outputRotationCodes = false;
  }
}

function protectedProbeMove(_cycle, x, y, z) {
  var _x = xOutput.format(x);
  var _y = yOutput.format(y);
  var _z = zOutput.format(z);
  if (_z && z >= getCurrentPosition().z) {
    writeBlock(gFormat.format(65), 'P' + 9810, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
  if (_x || _y) {
    writeBlock(gFormat.format(65), 'P' + 9810, _x, _y, getFeed(highFeedrate)); // protected positioning move
  }
  if (_z && z < getCurrentPosition().z) {
    writeBlock(gFormat.format(65), 'P' + 9810, _z, getFeed(cycle.feedrate)); // protected positioning move
  }
}

function onCyclePoint(x, y, z) {
  if (cycleType == 'inspect') {
    if (typeof inspectionCycleInspect == 'function') {
      inspectionCycleInspect(cycle, x, y, z);
      return;
    } else {
      cycleNotSupported();
    }
  }
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCyclePoint(x, y, z);
    return;
  }

  if (isProbeOperation()) {
    if (
      !useMultiAxisFeatures &&
      !isSameDirection(currentSection.workPlane.forward, new Vector(0, 0, 1))
    ) {
      if (!allowIndexingWCSProbing && currentSection.strategy == 'probe') {
        error(
          localize(
            'Updating WCS / work offset using probing is only supported by the CNC in the WCS frame.'
          )
        );
        return;
      }
    }
    if (printProbeResults()) {
      writeProbingToolpathInformation(z - cycle.depth + tool.diameter / 2);
      inspectionWriteCADTransform();
      inspectionWriteWorkplaneTransform();
      if (typeof inspectionWriteVariables == 'function') {
        inspectionVariables.pointNumber += 1;
      }
    }
    protectedProbeMove(cycle, x, y, z);
  }

  gRetractModal.reset();
  if (isFirstCyclePoint() || isProbeOperation()) {
    if (!isProbeOperation()) {
      repositionToCycleClearance(cycle, x, y, z);
    }

    // return to initial Z which is clearance plane and set absolute mode

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : clamp(1, cycle.dwell * 1000, 99999999); // in milliseconds

    switch (cycleType) {
      case 'drilling': // use G82
      case 'counter-boring':
        var d0 = cycle.retract - cycle.stock;
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(82),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, 'P' + milliFormat.format(P)),
          feedOutput.format(F),
          conditional(d0 > 0, 'D' + milliFormat.format(d0))
        );
        break;
      case 'chip-breaking':
        if (cycle.accumulatedDepth < cycle.depth) {
          expandCyclePoint(x, y, z);
        } else {
          var tz = cycle.incrementalDepth;
          // var d0 = (cycle.chipBreakDistance != undefined) ? cycle.chipBreakDistance : machineParameters.chipBreakingDistance;
          var k0 = cycle.retract - cycle.stock;
          // d0 not supported
          writeBlock(
            gRetractModal.format(98),
            gAbsIncModal.format(90),
            gCycleModal.format(73),
            getCommonCycle(x, y, z, cycle.retract),
            'Q' + xyzFormat.format(tz),
            conditional(P > 0, 'P' + milliFormat.format(P)),
            feedOutput.format(F),
            // conditional(d0 > 0, "D" + xyzFormat.format(d0)), // use parameter F12
            conditional(k0 > 0, 'K' + xyzFormat.format(k0))
          );
        }
        break;
      case 'deep-drilling':
        var tz = cycle.incrementalDepth;
        var k0 = cycle.retract - cycle.stock;
        // d0 not supported
        if (cycle.dwell > 0) {
          // not supported by cycle
          expandCyclePoint(x, y, z);
        } else {
          writeBlock(
            gRetractModal.format(98),
            gAbsIncModal.format(90),
            gCycleModal.format(83),
            getCommonCycle(x, y, z, cycle.retract),
            'Q' + xyzFormat.format(tz),
            feedOutput.format(F),
            conditional(k0 > 0, 'K' + xyzFormat.format(k0))
          );
        }
        break;
      case 'tapping':
      case 'left-tapping':
      case 'right-tapping':
        var tappingCycle;

        if (
          cycleType === 'right-tapping' ||
          tool.type === TOOL_TAP_RIGHT_HAND
        ) {
          tappingCycle = 84;
        } else if (
          cycleType === 'left-tapping' ||
          tool.type === TOOL_TAP_LEFT_HAND
        ) {
          tappingCycle = 74;
        } else {
          error('Unknown tapping cycle');
        }

        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(tappingCycle),
          pitchOutput.format(tool.threadPitch),
          'H' + getProperty(properties.syncTappingReturnSpeed),
          conditional(P > 0, 'P' + milliFormat.format(P)),
          getCommonCycle(x, y, z, cycle.retract)
        );
        break;
      case 'fine-boring':
        // TAG: add support for counterclockwise direction
        var d0 = cycle.retract - cycle.stock;
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(76),
          getCommonCycle(x, y, z, cycle.retract),
          conditional(P > 0, 'P' + milliFormat.format(P)),
          'Q' + xyzFormat.format(cycle.shift),
          feedOutput.format(F),
          conditional(d0 > 0, 'D' + xyzFormat.format(d0))
        );
        break;
      case 'back-boring':
        var dx = gPlaneModal.getCurrent() == 19 ? cycle.backBoreDistance : 0;
        var dy = gPlaneModal.getCurrent() == 18 ? cycle.backBoreDistance : 0;
        var dz = gPlaneModal.getCurrent() == 17 ? cycle.backBoreDistance : 0;
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(87),
          getCommonCycle(x - dx, y - dy, z - dz, cycle.bottom),
          feedOutput.format(F),
          conditional(P > 0, 'P' + milliFormat.format(P)),
          'Q' + xyzFormat.format(cycle.shift)
        );
        break;
      case 'reaming':
        var d0 = cycle.retract - cycle.stock;
        var f1 = cycle.retractFeedrate;
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F),
          conditional(P > 0, 'P' + milliFormat.format(P)),
          conditional(f1 != F, 'E' + feedFormat.format(f1)),
          conditional(d0 > 0, 'D' + xyzFormat.format(d0))
        );
        break;
      case 'stop-boring':
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(86),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F),
          conditional(P > 0, 'P' + milliFormat.format(P))
        );
        break;
      case 'manual-boring':
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(88),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F),
          conditional(P > 0, 'P' + milliFormat.format(P))
        );
        break;
      case 'boring':
        writeBlock(
          gRetractModal.format(98),
          gAbsIncModal.format(90),
          gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F),
          conditional(P > 0, 'P' + milliFormat.format(P))
        );
        break;
      case 'probing-x':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9811,
          'X' +
            xyzFormat.format(
              x +
                approach(cycle.approach1) *
                  (cycle.probeClearance + tool.diameter / 2)
            ),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-y':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9811,
          'Y' +
            xyzFormat.format(
              y +
                approach(cycle.approach1) *
                  (cycle.probeClearance + tool.diameter / 2)
            ),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-z':
        // NOTE: This seems unnecessary
        // protectedProbeMove(cycle, x, y, Math.min(z - cycle.depth + cycle.probeClearance, cycle.retract));
        writeBlock(
          gFormat.format(65),
          'P' + 9811,
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-x-wall':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'X' + xyzFormat.format(cycle.width1),
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-y-wall':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Y' + xyzFormat.format(cycle.width1),
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-x-channel':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'X' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-x-channel-with-island':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'X' + xyzFormat.format(cycle.width1),
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-y-channel':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Y' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-y-channel-with-island':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Y' + xyzFormat.format(cycle.width1),
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-circular-boss':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9814,
          'D' + xyzFormat.format(cycle.width1),
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-circular-partial-boss':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9823,
          'A' + xyzFormat.format(cycle.partialCircleAngleA),
          'B' + xyzFormat.format(cycle.partialCircleAngleB),
          'C' + xyzFormat.format(cycle.partialCircleAngleC),
          'D' + xyzFormat.format(cycle.width1),
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-circular-hole':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9814,
          'D' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-circular-partial-hole':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9823,
          'A' + xyzFormat.format(cycle.partialCircleAngleA),
          'B' + xyzFormat.format(cycle.partialCircleAngleB),
          'C' + xyzFormat.format(cycle.partialCircleAngleC),
          'D' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-circular-hole-with-island':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9814,
          'Z' + xyzFormat.format(z - cycle.depth),
          'D' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-circular-partial-hole-with-island':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9823,
          'Z' + xyzFormat.format(z - cycle.depth),
          'A' + xyzFormat.format(cycle.partialCircleAngleA),
          'B' + xyzFormat.format(cycle.partialCircleAngleB),
          'C' + xyzFormat.format(cycle.partialCircleAngleC),
          'D' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-rectangular-hole':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'X' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Y' + xyzFormat.format(cycle.width2),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          // not required "R" + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-rectangular-boss':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Z' + xyzFormat.format(z - cycle.depth),
          'X' + xyzFormat.format(cycle.width1),
          'R' + xyzFormat.format(cycle.probeClearance),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Z' + xyzFormat.format(z - cycle.depth),
          'Y' + xyzFormat.format(cycle.width2),
          'R' + xyzFormat.format(cycle.probeClearance),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-rectangular-hole-with-island':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Z' + xyzFormat.format(z - cycle.depth),
          'X' + xyzFormat.format(cycle.width1),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        writeBlock(
          gFormat.format(65),
          'P' + 9812,
          'Z' + xyzFormat.format(z - cycle.depth),
          'Y' + xyzFormat.format(cycle.width2),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(-cycle.probeClearance),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-inner-corner':
        var cornerX =
          x +
          approach(cycle.approach1) *
            (cycle.probeClearance + tool.diameter / 2);
        var cornerY =
          y +
          approach(cycle.approach2) *
            (cycle.probeClearance + tool.diameter / 2);
        var cornerI = 0;
        var cornerJ = 0;
        if (cycle.probeSpacing !== undefined) {
          cornerI = cycle.probeSpacing;
          cornerJ = cycle.probeSpacing;
        }
        if (cornerI != 0 && cornerJ != 0) {
          if (currentSection.strategy == 'probe') {
            setProbeAngleMethod();
            probeVariables.compensationXY = 'X[#135] Y[#136]';
          }
        }
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9815,
          xOutput.format(cornerX),
          yOutput.format(cornerY),
          conditional(cornerI != 0, 'I' + xyzFormat.format(cornerI)),
          conditional(cornerJ != 0, 'J' + xyzFormat.format(cornerJ)),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-xy-outer-corner':
        var cornerX =
          x +
          approach(cycle.approach1) *
            (cycle.probeClearance + tool.diameter / 2);
        var cornerY =
          y +
          approach(cycle.approach2) *
            (cycle.probeClearance + tool.diameter / 2);
        var cornerI = 0;
        var cornerJ = 0;
        if (cycle.probeSpacing !== undefined) {
          cornerI = cycle.probeSpacing;
          cornerJ = cycle.probeSpacing;
        }
        if (cornerI != 0 && cornerJ != 0) {
          if (currentSection.strategy == 'probe') {
            setProbeAngleMethod();
            probeVariables.compensationXY = 'X[#135] Y[#136]';
          }
        }
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9816,
          xOutput.format(cornerX),
          yOutput.format(cornerY),
          conditional(cornerI != 0, 'I' + xyzFormat.format(cornerI)),
          conditional(cornerJ != 0, 'J' + xyzFormat.format(cornerJ)),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, true)
        );
        break;
      case 'probing-x-plane-angle':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9843,
          'X' +
            xyzFormat.format(
              x +
                approach(cycle.approach1) *
                  (cycle.probeClearance + tool.diameter / 2)
            ),
          'D' + xyzFormat.format(cycle.probeSpacing),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'A' +
            xyzFormat.format(
              cycle.nominalAngle != undefined ? cycle.nominalAngle : 90
            ),
          getProbingArguments(cycle, false)
        );
        if (currentSection.strategy == 'probe') {
          setProbeAngleMethod();
          probeVariables.compensationXY =
            'X' + xyzFormat.format(0) + ' Y' + xyzFormat.format(0);
        }
        break;
      case 'probing-y-plane-angle':
        protectedProbeMove(cycle, x, y, z - cycle.depth);
        writeBlock(
          gFormat.format(65),
          'P' + 9843,
          'Y' +
            xyzFormat.format(
              y +
                approach(cycle.approach1) *
                  (cycle.probeClearance + tool.diameter / 2)
            ),
          'D' + xyzFormat.format(cycle.probeSpacing),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'A' +
            xyzFormat.format(
              cycle.nominalAngle != undefined ? cycle.nominalAngle : 0
            ),
          getProbingArguments(cycle, false)
        );
        if (currentSection.strategy == 'probe') {
          setProbeAngleMethod();
          probeVariables.compensationXY =
            'X' + xyzFormat.format(0) + ' Y' + xyzFormat.format(0);
        }
        break;
      case 'probing-xy-pcd-hole':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9819,
          'A' + xyzFormat.format(cycle.pcdStartingAngle),
          'B' + xyzFormat.format(cycle.numberOfSubfeatures),
          'C' + xyzFormat.format(cycle.widthPCD),
          'D' + xyzFormat.format(cycle.widthFeature),
          'K' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          getProbingArguments(cycle, false)
        );
        if (cycle.updateToolWear) {
          error(
            localize(
              'Action -Update Tool Wear- is not supported with this cycle.'
            )
          );
          return;
        }
        break;
      case 'probing-xy-pcd-boss':
        protectedProbeMove(cycle, x, y, z);
        writeBlock(
          gFormat.format(65),
          'P' + 9819,
          'A' + xyzFormat.format(cycle.pcdStartingAngle),
          'B' + xyzFormat.format(cycle.numberOfSubfeatures),
          'C' + xyzFormat.format(cycle.widthPCD),
          'D' + xyzFormat.format(cycle.widthFeature),
          'Z' + xyzFormat.format(z - cycle.depth),
          'Q' + xyzFormat.format(cycle.probeOvertravel),
          'R' + xyzFormat.format(cycle.probeClearance),
          getProbingArguments(cycle, false)
        );
        if (cycle.updateToolWear) {
          error(
            localize(
              'Action -Update Tool Wear- is not supported with this cycle.'
            )
          );
          return;
        }
        break;
      default:
        expandCyclePoint(x, y, z);
    }
  } else {
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else {
      var _x = xOutput.format(x);
      var _y = yOutput.format(y);
      var _z = zOutput.format(z);
      if (!_x && !_y && !_z) {
        switch (gPlaneModal.getCurrent()) {
          case 17: // XY
            xOutput.reset(); // at least one axis is required
            _x = xOutput.format(x);
            break;
          case 18: // ZX
            zOutput.reset(); // at least one axis is required
            _z = zOutput.format(z);
            break;
          case 19: // YZ
            yOutput.reset(); // at least one axis is required
            _y = yOutput.format(y);
            break;
        }
      }
      writeBlock(_x, _y, _z);
    }
  }
}

function getProbingArguments(cycle, updateWCS) {
  var outputWCSCode = updateWCS && currentSection.strategy == 'probe';
  if (outputWCSCode) {
    validate(probeOutputWorkOffset <= 99, 'Work offset is out of range.');
    var nextWorkOffset = hasNextSection()
      ? getNextSection().workOffset == 0
        ? 1
        : getNextSection().workOffset
      : -1;
    if (probeOutputWorkOffset == nextWorkOffset) {
      // NOTE: Can't figure out why this was needed but it causes a lot of seemingly unnecessary
      // retractions/etc. Getting rid of it.
      // currentWorkOffset = undefined;
    }
  }
  return [
    cycle.angleAskewAction == 'stop-message'
      ? 'B' + xyzFormat.format(cycle.toleranceAngle ? cycle.toleranceAngle : 0)
      : undefined,
    cycle.updateToolWear && cycle.toolWearErrorCorrection < 100
      ? 'F' +
        xyzFormat.format(
          cycle.toolWearErrorCorrection
            ? cycle.toolWearErrorCorrection / 100
            : 100
        )
      : undefined,
    cycle.wrongSizeAction == 'stop-message'
      ? 'H' + xyzFormat.format(cycle.toleranceSize ? cycle.toleranceSize : 0)
      : undefined,
    cycle.outOfPositionAction == 'stop-message'
      ? 'M' +
        xyzFormat.format(cycle.tolerancePosition ? cycle.tolerancePosition : 0)
      : undefined,
    cycle.updateToolWear && cycleType == 'probing-z'
      ? 'T' + xyzFormat.format(cycle.toolLengthOffset)
      : undefined,
    cycle.updateToolWear && cycleType !== 'probing-z'
      ? 'T' + xyzFormat.format(cycle.toolDiameterOffset)
      : undefined,
    cycle.updateToolWear
      ? 'V' +
        xyzFormat.format(
          cycle.toolWearUpdateThreshold ? cycle.toolWearUpdateThreshold : 0
        )
      : undefined,
    cycle.printResults
      ? 'W' + xyzFormat.format(1 + cycle.incrementComponent)
      : undefined, // 1 for advance feature, 2 for reset feature count and advance component number. first reported result in a program should use W2.
    conditional(
      outputWCSCode,
      'S' +
        probeWCSFormat.format(
          probeOutputWorkOffset > 6
            ? probeOutputWorkOffset - 6 + 100
            : probeOutputWorkOffset
        )
    ),
  ];
}

function onCycleEnd() {
  if (isProbeOperation()) {
    zOutput.reset();
    gMotionModal.reset();
    writeBlock(gFormat.format(65), 'P' + 9810, zOutput.format(cycle.retract)); // protected retract move
  } else {
    if (!cycleExpanded) {
      writeBlock(gCycleModal.format(80));
      gMotionModal.reset();
    }
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(
        localize(
          'Radius compensation mode cannot be changed at rapid traversal.'
        )
      );
      return;
    }
    writeBlock(gMotionModal.format(0), x, y, z);
    forceFeed();
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      writeBlock(gPlaneModal.format(17));
      switch (radiusCompensation) {
        case RADIUS_COMPENSATION_LEFT:
          writeBlock(
            gMotionModal.format(1),
            gFormat.format(41),
            x,
            y,
            z,
            formatToolD(tool),
            f
          );
          break;
        case RADIUS_COMPENSATION_RIGHT:
          writeBlock(
            gMotionModal.format(1),
            gFormat.format(42),
            x,
            y,
            z,
            formatToolD(tool),
            f
          );
          break;
        default:
          writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) {
      // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (pendingRadiusCompensation >= 0) {
    error(
      localize('Radius compensation mode cannot be changed at rapid traversal.')
    );
    return;
  }
  if (!currentSection.isOptimizedForMachine()) {
    forceXYZ();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = currentSection.isOptimizedForMachine()
    ? aOutput.format(_a)
    : 'I' + ijkFormat.format(_a);
  var b = currentSection.isOptimizedForMachine()
    ? bOutput.format(_b)
    : 'J' + ijkFormat.format(_b);
  var c = currentSection.isOptimizedForMachine()
    ? cOutput.format(_c)
    : 'K' + ijkFormat.format(_c);

  writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
  forceFeed();
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed, feedMode) {
  if (pendingRadiusCompensation >= 0) {
    error(
      localize(
        'Radius compensation cannot be activated/deactivated for 5-axis move.'
      )
    );
    return;
  }
  if (!currentSection.isOptimizedForMachine()) {
    forceXYZ();
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = currentSection.isOptimizedForMachine()
    ? aOutput.format(_a)
    : 'I' + ijkFormat.format(_a);
  var b = currentSection.isOptimizedForMachine()
    ? bOutput.format(_b)
    : 'J' + ijkFormat.format(_b);
  var c = currentSection.isOptimizedForMachine()
    ? cOutput.format(_c)
    : 'K' + ijkFormat.format(_c);
  if (feedMode == FEED_INVERSE_TIME) {
    forceFeed();
  }
  var f = getFeed(feed);
  var fMode = feedMode == FEED_INVERSE_TIME ? 93 : 94;

  if (x || y || z || a || b || c) {
    writeBlock(
      gFeedModeModal.format(fMode),
      gMotionModal.format(1),
      x,
      y,
      z,
      a,
      b,
      c,
      f
    );
  } else if (f) {
    if (getNextRecord().isMotion()) {
      // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gFeedModeModal.format(fMode), gMotionModal.format(1), f);
    }
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (isSpiral()) {
    var startRadius = getCircularStartRadius();
    var endRadius = getCircularRadius();
    var dr = Math.abs(endRadius - startRadius);
    if (dr > maximumCircularRadiiDifference) {
      // maximum limit
      linearize(tolerance); // or alternatively use other G-codes for spiral motion
      return;
    }
  }

  if (pendingRadiusCompensation >= 0) {
    error(
      localize(
        'Radius compensation cannot be activated/deactivated for a circular move.'
      )
    );
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (getProperty(properties.useRadius) || isHelical()) {
      // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
      case PLANE_XY:
        writeBlock(
          gPlaneModal.format(17),
          gMotionModal.format(clockwise ? 2 : 3),
          iOutput.format(cx - start.x, 0),
          jOutput.format(cy - start.y, 0),
          getFeed(feed)
        );
        break;
      case PLANE_ZX:
        writeBlock(
          gPlaneModal.format(18),
          gMotionModal.format(clockwise ? 2 : 3),
          iOutput.format(cx - start.x, 0),
          kOutput.format(cz - start.z, 0),
          getFeed(feed)
        );
        break;
      case PLANE_YZ:
        writeBlock(
          gPlaneModal.format(19),
          gMotionModal.format(clockwise ? 2 : 3),
          jOutput.format(cy - start.y, 0),
          kOutput.format(cz - start.z, 0),
          getFeed(feed)
        );
        break;
      default:
        linearize(tolerance);
    }
  } else if (!getProperty(properties.useRadius)) {
    switch (getCircularPlane()) {
      case PLANE_XY:
        writeBlock(
          gPlaneModal.format(17),
          gMotionModal.format(clockwise ? 2 : 3),
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          iOutput.format(cx - start.x, 0),
          jOutput.format(cy - start.y, 0),
          getFeed(feed)
        );
        break;
      case PLANE_ZX:
        writeBlock(
          gPlaneModal.format(18),
          gMotionModal.format(clockwise ? 2 : 3),
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          iOutput.format(cx - start.x, 0),
          kOutput.format(cz - start.z, 0),
          getFeed(feed)
        );
        break;
      case PLANE_YZ:
        writeBlock(
          gPlaneModal.format(19),
          gMotionModal.format(clockwise ? 2 : 3),
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          jOutput.format(cy - start.y, 0),
          kOutput.format(cz - start.z, 0),
          getFeed(feed)
        );
        break;
      default:
        linearize(tolerance);
    }
  } else {
    // use radius mode
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > 180 + 1e-9) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
      case PLANE_XY:
        writeBlock(
          gPlaneModal.format(17),
          gMotionModal.format(clockwise ? 2 : 3),
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          'R' + rFormat.format(r),
          getFeed(feed)
        );
        break;
      case PLANE_ZX:
        writeBlock(
          gPlaneModal.format(18),
          gMotionModal.format(clockwise ? 2 : 3),
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          'R' + rFormat.format(r),
          getFeed(feed)
        );
        break;
      case PLANE_YZ:
        writeBlock(
          gPlaneModal.format(19),
          gMotionModal.format(clockwise ? 2 : 3),
          xOutput.format(x),
          yOutput.format(y),
          zOutput.format(z),
          'R' + rFormat.format(r),
          getFeed(feed)
        );
        break;
      default:
        linearize(tolerance);
    }
  }
}

var coolantState = {
  currentMode: COOLANT_OFF,
};

function toolUsesTSC(tool) {
  return (
    tool.coolant === COOLANT_THROUGH_TOOL ||
    tool.coolant === COOLANT_FLOOD_THROUGH_TOOL
  );
}

function formatCoolantCodes(codes) {
  return _.map(codes, function (code) {
    return mFormat.format(code);
  });
}

function enableCoolant(coolantMode, suppressWrite) {
  // Turn off coolant if we're changing coolant modes
  if (
    coolantState.currentMode !== COOLANT_OFF &&
    coolantMode !== coolantState.currentMode &&
    !isFirstSection()
  ) {
    writeBlock(formatCoolantCodes(coolantOffCodes).join(getWordSeparator()));
  }

  var mCodes = coolantCodesToEnable(coolantMode);
  !suppressWrite && writeBlock(mCodes.join(getWordSeparator()));

  coolantState.currentMode = coolantMode;
  return mCodes;
}

function disableCoolant(suppressWrite) {
  if (coolantState.currentMode === COOLANT_OFF) {
    return [];
  }

  var mCodes = formatCoolantCodes(coolantOffCodes);
  !suppressWrite && writeBlock(mCodes.join(getWordSeparator()));

  coolantState.currentMode = COOLANT_OFF;
  return mCodes;
}

function coolantCodesToEnable(coolantMode) {
  // Nothing to enable if not changing mode or if turning coolant off
  if (coolantMode === COOLANT_OFF || coolantMode === coolantState.currentMode) {
    return [];
  }

  var coolant = _.find(coolants, function (c) {
    return c.id === coolantMode;
  });
  validate(
    !!coolant,
    'Post processor does not support coolant mode: ' + coolantMode
  );

  return formatCoolantCodes(coolant.codes);
}

var mapCommand = {
  COMMAND_STOP: 0,
  COMMAND_OPTIONAL_STOP: 1,
  COMMAND_END: 2,
  COMMAND_SPINDLE_CLOCKWISE: 3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE: 4,
  COMMAND_STOP_SPINDLE: 5,
  COMMAND_LOAD_TOOL: 6,
  COMMAND_ORIENTATE_SPINDLE: 19,
};

function onCommand(command) {
  switch (command) {
    case COMMAND_STOP:
      writeBlock(mFormat.format(0));
      forceSpindleSpeed = true;
      return;

    case COMMAND_COOLANT_ON:
      enableCoolant(COOLANT_FLOOD);
      return;

    case COMMAND_COOLANT_OFF:
      disableCoolant();
      return;

    case COMMAND_START_SPINDLE:
      onCommand(
        tool.clockwise
          ? COMMAND_SPINDLE_CLOCKWISE
          : COMMAND_SPINDLE_COUNTERCLOCKWISE
      );
      return;

    case COMMAND_BREAK_CONTROL:
      if (getProperty(properties.breakDetectEnable)) {
        if (gRotationModal.getCurrent() === 68.2) {
          cancelWorkPlane();
        }
        writeBlock(getProperty(properties.breakDetectPassThrough));
        sOutput.reset();
      }
      return;

    case COMMAND_PROBE_ON:
      if (!probeVariables.probeOn) {
        writeBlock(gFormat.format(65), 'P' + 9832);
        probeVariables.probeOn = true;
      }
      return;

    case COMMAND_PROBE_OFF:
      if (probeVariables.probeOn) {
        writeBlock(gFormat.format(65), 'P' + 9833);
        probeVariables.probeOn = false;
      }
      return;

    case COMMAND_START_CHIP_TRANSPORT:
      writeBlock(mFormat.format(43));
      return;

    case COMMAND_STOP_CHIP_TRANSPORT:
    case COMMAND_TOOL_MEASURE:
    case COMMAND_UNLOCK_MULTI_AXIS:
    case COMMAND_LOCK_MULTI_AXIS:
      return;
  }

  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  var tool = currentSection.getTool();
  var nextSection = getNextSection();
  var nextTool = nextSection && nextSection.getTool();

  if (getProperty(properties.enableMachiningModes)) {
    usingHighSpeedMode() && disableHighSpeedMode();
  }

  if (typeof inspectionProcessSectionEnd == 'function') {
    inspectionProcessSectionEnd();
  }

  if (currentSection.isMultiAxis()) {
    writeBlock(gFeedModeModal.format(94)); // inverse time feed off
  }

  writeBlock(gPlaneModal.format(17));

  if (blockSkipController.isEnabled()) {
    blockSkipController.writeN(nextSection);
  }

  if (isProbeOperation()) {
    if (!nextSection || nextTool.type !== TOOL_PROBE) {
      onCommand(COMMAND_PROBE_OFF);
    }

    if (probeVariables.probeAngleMethod != 'G68') {
      setProbeAngle(); // output probe angle rotations if required
    }
  }

  // Run break control on last section or if the tool is changing
  if (
    tool.getBreakControl() &&
    (isLastSection() || tool.number !== nextTool.number)
  ) {
    onCommand(COMMAND_BREAK_CONTROL);
  }

  // the code below gets the machine angles from previous operation.  closestABC must also be set to true
  if (currentSection.isMultiAxis() && currentSection.isOptimizedForMachine()) {
    currentMachineABC = currentSection.getFinalToolAxisABC();
  }

  forceAny();

  if (blockSkipController.isEnabled() && isProbeOperation()) {
    blockSkipController.writeProbeN();
  }
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  var words = []; // store all retracted axes in an array
  var retractAxes = new Array(false, false, false);
  var method = getProperty(properties.safePositionMethod);
  if (method == 'clearanceHeight') {
    if (!is3D()) {
      error(
        localize(
          "Retract option 'Clearance Height' is not supported for multi-axis machining."
        )
      );
    }
    return;
  }
  validate(arguments.length != 0, 'No axis specified for writeRetract().');

  for (i in arguments) {
    retractAxes[arguments[i]] = true;
  }
  if ((retractAxes[0] || retractAxes[1]) && !retracted) {
    // retract Z first before moving to X/Y home
    error(
      localize(
        'Retracting in X/Y is not possible without being retracted in Z.'
      )
    );
    return;
  }
  // special conditions
  /*
  if (retractAxes[2]) { // Z doesn't use G53
    method = "G28";
  }
  */
  if (gRotationModal.getCurrent() == 68) {
    // cancel G68 before retracting
    cancelWorkPlane(true);
  }

  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method === 'G28' || method === 'G30P4') {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    _xHome = machineConfiguration.hasHomePositionX()
      ? machineConfiguration.getHomePositionX()
      : toPreciseUnit(0, MM);
    _yHome = machineConfiguration.hasHomePositionY()
      ? machineConfiguration.getHomePositionY()
      : toPreciseUnit(0, MM);
    _zHome =
      machineConfiguration.getRetractPlane() != 0
        ? machineConfiguration.getRetractPlane()
        : toPreciseUnit(0, MM);
  }
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
      case X:
        words.push('X' + xyzFormat.format(_xHome));
        xOutput.reset();
        break;
      case Y:
        words.push('Y' + xyzFormat.format(_yHome));
        yOutput.reset();
        break;
      case Z:
        words.push('Z' + xyzFormat.format(_zHome));
        zOutput.reset();
        retracted = true;
        break;
      default:
        error(localize('Unsupported axis specified for writeRetract().'));
        return;
    }
  }
  if (words.length > 0) {
    switch (method) {
      case 'G28':
        gMotionModal.reset();
        gAbsIncModal.reset();
        writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
        writeBlock(gAbsIncModal.format(90));
        break;
      case 'G30P4':
        gMotionModal.reset();
        gAbsIncModal.reset();
        writeBlock(gFormat.format(30), 'P4', gAbsIncModal.format(91), words);
        writeBlock(gAbsIncModal.format(90));
        break;
      case 'G53':
        gMotionModal.reset();
        writeBlock(
          gAbsIncModal.format(90),
          gFormat.format(53),
          gMotionModal.format(0),
          words
        );
        break;
      default:
        error(localize('Unsupported safe position method.'));
        return;
    }
  }
}

var isDPRNTopen = false;
function inspectionCreateResultsFileHeader() {
  if (isDPRNTopen) {
    if (!getProperty(properties.singleResultsFile)) {
      writeln('DPRNT[END]');
      writeBlock('PCLOS');
      isDPRNTopen = false;
    }
  }

  if (isProbeOperation() && !printProbeResults()) {
    return; // if print results is not desired by probe/ probeWCS
  }

  if (!isDPRNTopen) {
    writeBlock('PCLOS');
    writeBlock('POPEN');
    // check for existence of none alphanumeric characters but not spaces
    var resFile;
    if (getProperty(properties.singleResultsFile)) {
      resFile = getParameter('job-description') + '-RESULTS';
    } else {
      resFile = getParameter('operation-comment') + '-RESULTS';
    }
    resFile = resFile.replace(/:/g, '-');
    resFile = resFile.replace(/[^a-zA-Z0-9 -]/g, '');
    resFile = resFile.replace(/\s/g, '-');
    writeln('DPRNT[START]');
    writeln('DPRNT[RESULTSFILE*' + resFile + ']');
    if (hasGlobalParameter('document-id')) {
      writeln('DPRNT[DOCUMENTID*' + getGlobalParameter('document-id') + ']');
    }
    if (hasGlobalParameter('model-version')) {
      writeln(
        'DPRNT[MODELVERSION*' + getGlobalParameter('model-version') + ']'
      );
    }
  }
  if (isProbeOperation() && printProbeResults()) {
    isDPRNTopen = true;
  }
}

function getPointNumber() {
  if (typeof inspectionWriteVariables == 'function') {
    return inspectionVariables.pointNumber;
  } else {
    return '#122[60]';
  }
}

function inspectionWriteCADTransform() {
  var cadOrigin = currentSection.getModelOrigin();
  var cadWorkPlane = currentSection.getModelPlane().getTransposed();
  var cadEuler = cadWorkPlane.getEuler2(EULER_XYZ_S);
  writeln(
    'DPRNT[G331' +
      '*N' +
      getPointNumber() +
      '*A' +
      abcFormat.format(cadEuler.x) +
      '*B' +
      abcFormat.format(cadEuler.y) +
      '*C' +
      abcFormat.format(cadEuler.z) +
      '*X' +
      xyzFormat.format(-cadOrigin.x) +
      '*Y' +
      xyzFormat.format(-cadOrigin.y) +
      '*Z' +
      xyzFormat.format(-cadOrigin.z) +
      ']'
  );
}

function inspectionWriteWorkplaneTransform() {
  var orientation =
    machineConfiguration.isMultiAxisConfiguration() &&
    currentMachineABC != undefined
      ? machineConfiguration.getOrientation(currentMachineABC)
      : currentSection.workPlane;
  var abc = orientation.getEuler2(EULER_XYZ_S);
  writeln(
    'DPRNT[G330' +
      '*N' +
      getPointNumber() +
      '*A' +
      abcFormat.format(abc.x) +
      '*B' +
      abcFormat.format(abc.y) +
      '*C' +
      abcFormat.format(abc.z) +
      '*X0*Y0*Z0*I0*R0]'
  );
}

function writeProbingToolpathInformation(cycleDepth) {
  writeln('DPRNT[TOOLPATHID*' + getParameter('autodeskcam:operation-id') + ']');
  if (isInspectionOperation()) {
    writeln('DPRNT[TOOLPATH*' + getParameter('operation-comment') + ']');
  } else {
    writeln('DPRNT[CYCLEDEPTH*' + xyzFormat.format(cycleDepth) + ']');
  }
}

/** Allow user to override the onRewind logic. */
function onRewindMachineEntry(_a, _b, _c) {
  return false;
}

/** Retract to safe position before indexing rotaries. */
function onMoveToSafeRetractPosition() {
  writeRetract(Z);
  // cancel TCP so that tool doesn't follow rotaries
  if (currentSection.isMultiAxis() && tcpIsSupported) {
    disableLengthCompensation(false, 'TCPC OFF');
  }
}

/** Rotate axes to new position above reentry position */
function onRotateAxes(_x, _y, _z, _a, _b, _c) {
  // position rotary axes
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  invokeOnRapid5D(_x, _y, _z, _a, _b, _c);
  setCurrentABC(new Vector(_a, _b, _c));
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();
}

/** Return from safe position after indexing rotaries. */
function onReturnFromSafeRetractPosition(_x, _y, _z) {
  // reinstate TCP / tool length compensation
  if (!lengthCompensationActive) {
    writeBlock(
      gFormat.format(getOffsetCode()),
      hFormat.format(tool.lengthOffset)
    );
    lengthCompensationActive = true;
  }

  // position in XY
  forceXYZ();
  xOutput.reset();
  yOutput.reset();
  zOutput.disable();
  invokeOnRapid(_x, _y, _z);

  // position in Z
  zOutput.enable();
  invokeOnRapid(_x, _y, _z);
}
// End of onRewindMachine logic

function onPassThrough(text) {
  var commands = String(text).split(',');
  for (text in commands) {
    writeBlock(commands[text]);
  }
}

function onClose() {
  if (isDPRNTopen) {
    writeln('DPRNT[END]');
    writeBlock('PCLOS');
    isDPRNTopen = false;
    if (typeof inspectionProcessSectionEnd == 'function') {
      inspectionProcessSectionEnd();
    }
  }

  cancelWorkPlane();

  writeBlock(
    gAbsIncModal.format(90),
    gFormat.format(53),
    gFormat.format(0),
    'Z' + xyzFormat.format(0),
    mFormat.format(5),
    mFormat.format(9)
  );

  if (probeVariables.probeAngleMethod == 'G54.4') {
    writeBlock(gFormat.format(54.4), 'P0');
  }

  if (getProperty(properties.enableMistCollector)) {
    writeBlock(mFormat.format(614));
  }

  if (getProperty(properties.niagaraCoolant) > 0) {
    writeln('');
    writeComment('Niagara coolant');
    writeBlock(mFormat.format(130));
    writeBlock(
      gFormat.format(4),
      'X' + secFormat.format(getProperty(properties.niagaraCoolant))
    );
    writeBlock(mFormat.format(9));
  }

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);

  if (blockSkipController.isEnabled()) {
    writeln('');
    writeln('(Check part count before pallet swap)');
    if (getProperty(properties.incPartsCount)) {
      writeln('#3901 = #3901 + ' + blockSkipController.partsActiveVar);
    }
    writeln('IF [#3902 EQ 0.] GOTO 99999');
    writeln('IF [#3901 GE #3902] THEN');
    writeln('  M30');
    writeln('ENDIF');
    writeln('');
    writeln('N99999');
    writeln('/9 M30');
    writeln('G65 <SWAP_PALLET>');
    writeln('M998 Q0');
  } else {
    writeBlock(mFormat.format(30));
  }
}

function setProperty(property, value) {
  properties[property].current = value;
}

function formatToolIdentifier(tool) {
  var identifier = tool.description;

  if (!identifier) {
    return tool.number;
  }

  validate(
    identifier.length <= 32,
    'Tool description must be less than 32 characters when tool identifiers are used: ' +
      tool.description
  );
  validate(
    identifier === filterText(identifier, permittedToolIdentifierChars),
    "Tool description can only contain '" +
      permittedToolIdentifierChars +
      "': '" +
      identifier +
      "'"
  );

  return '<' + identifier + '>';
}

function formatToolNumber(tool) {
  if (getProperty(properties.useToolIdentifiers)) {
    return formatToolIdentifier(tool);
  } else {
    return toolFormat.format(tool.number);
  }
}

function formatToolH(tool) {
  return hFormat.format(tool.lengthOffset);
}

function formatToolD(tool) {
  return dFormat.format(tool.diameterOffset);
}

function useG117() {
  return (
    getProperty(properties.useG117) && gRotationModal.getCurrent() !== 68.2
  );
}

function formatPostDateTime(d) {
  // MM.DD.YYYY, HH.MMz
  return (
    '' +
    (d.getMonth() + 1) +
    '.' +
    d.getDate() +
    '.' +
    d.getFullYear() +
    ', ' +
    (d.getHours() === 0 || d.getHours() === 12 ? 12 : d.getHours() % 12) +
    ':' +
    (d.getMinutes() < 10 ? '0' + d.getMinutes() : d.getMinutes()) +
    (d.getHours() >= 12 ? 'pm' : 'am')
  );
}

var BLOCK_SKIP_TO_WCS = {
  1: [7, 10], // Side 1, G54.1 P1 & P4
  2: [8, 11], // Side 2, G54.1 P2 & P5
  3: [9, 12], // Side 3, G54.1 P3 & P6
};

function BlockSkipController() {
  this.currentN = 90000;
  this.currentOffset = undefined;
  this.wcsToBlockSkip = {};

  this.currentProbeN = 95000;

  this.partsActiveVar = '#19';
  this._skipsUsed = {};

  var that = this;
  for (var blockSkip in BLOCK_SKIP_TO_WCS) {
    _.forEach(BLOCK_SKIP_TO_WCS[blockSkip], function (offset) {
      that.wcsToBlockSkip[offset] = blockSkip;
    });
  }
}

BlockSkipController.prototype.nextN = function () {
  return ++this.currentN;
};

BlockSkipController.prototype.writeSkip = function (offset) {
  var blockSkip = this.wcsToBlockSkip[offset];

  if (!blockSkip) {
    // Unsupported WCS
    return undefined;
  }

  if (offset !== this.currentOffset) {
    this.currentOffset = offset;
    writeln('/' + blockSkip + ' GOTO ' + this.nextN());
  }

  if (!this._skipsUsed[blockSkip]) {
    this._skipsUsed[blockSkip] = true;
  }

  return undefined;
};

BlockSkipController.prototype.writeN = function (nextSection) {
  if (!nextSection || nextSection.workOffset !== this.currentOffset) {
    writeln('N' + this.currentN);
  }
};

BlockSkipController.prototype.writeProbeSkip = function () {
  writeln('IF [#908 EQ 1] GOTO ' + this.currentProbeN);
};

BlockSkipController.prototype.writeProbeN = function (nextSection) {
  writeln('N' + this.currentProbeN);
  this.currentProbeN += 1;
};

BlockSkipController.prototype.writeBlockSkipInit = function () {
  writeln('G65 <SET_BSKIP_VARS> V900');
  writeln('IF [[#901 + #902 + #903] EQ 0] THEN');
  writeln('  #3000 = 21(*ERR*NO*BLOCK*SKIP*DETECTED)');
  writeln('ENDIF');
  writeln('');

  if (getProperty(properties.incPartsCount)) {
    writeln('(Inc part count by this amount at end of program)');
    writeln(
      this.partsActiveVar +
        ' = [#901 + #902 + #903] * ' +
        getProperty(properties.incPartsCountBy)
    );
    writeln('');
  }
};

BlockSkipController.prototype.isEnabled = function () {
  return getProperty(properties.blockSkipControls);
};
